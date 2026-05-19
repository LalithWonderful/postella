import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:http/http.dart' as http;

import '../../domain/categories/category.dart';
import '../../domain/generation/ad_generator.dart';
import '../../domain/models/ad_draft.dart';
import '../../domain/models/generated_ad.dart';
import 'gemini_prompt.dart';
import 'gemini_response_parser.dart';

void _log(String msg) {
  if (kDebugMode) debugPrint('[Gemini] $msg');
}

/// Tronque pour éviter de polluer la console — utile pour les erreurs
/// Gemini qui peuvent renvoyer des messages très longs.
String _truncate(String s, [int max = 400]) =>
    s.length <= max ? s : '${s.substring(0, max)}…';

/// Modèle Gemini par défaut — flash 2.5 : latence basse et coût faible,
/// largement suffisant pour rédiger une annonce courte.
const String kGeminiDefaultModel = 'gemini-2.5-flash';

const String _kBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

/// Génération d'annonce via l'API REST Gemini (texte uniquement en lot 5A).
///
/// Stratégie d'erreur :
/// - Erreur réseau / HTTP / timeout → [GenerationException] avec message FR
///   lisible. Le quota a déjà été consommé, l'utilisateur le voit dans l'UI.
/// - Réponse 200 mais JSON Gemini inexploitable (texte vide, JSON malformé,
///   champs requis manquants) → fallback silencieux sur [fallback].
///   On préfère sortir une annonce moins bonne qu'une erreur, parce que le
///   quota est déjà consommé et qu'on a la matière côté draft.
class GeminiAdGenerator implements AdGenerator {
  GeminiAdGenerator({
    required this.apiKey,
    required this.fallback,
    this.model = kGeminiDefaultModel,
    this.timeout = const Duration(seconds: 30),
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final AdGenerator fallback;
  final String model;
  final Duration timeout;
  final http.Client _http;

  @override
  Future<GeneratedAd> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    // 1er essai : schéma complet, budget de tokens normal.
    final first = await _callGeminiOnce(
      draft: draft,
      category: category,
      includeTips: true,
      maxOutputTokens: 1500,
      attempt: 1,
    );
    if (first.ad != null) return first.ad!;

    // Retry unique si la troncature est probable (MAX_TOKENS ou texte qui
    // ne se termine pas par `}`). On simplifie le schéma (drop des tips)
    // et on remonte le budget pour limiter le risque de re-troncature.
    if (first.shouldRetry) {
      _log('RETRY 2/2 : schéma simplifié (sans improvement_tips), '
          'maxOutputTokens=2000');
      final second = await _callGeminiOnce(
        draft: draft,
        category: category,
        includeTips: false,
        maxOutputTokens: 2000,
        attempt: 2,
      );
      if (second.ad != null) return second.ad!;
      _log('FALLBACK : retry KO (${second.failureReason ?? "inconnu"})');
    } else {
      _log('FALLBACK : ${first.failureReason ?? "raison inconnue"}');
    }

    return fallback.generate(draft: draft, category: category);
  }

  Future<_GeminiAttempt> _callGeminiOnce({
    required AdDraft draft,
    required Category category,
    required bool includeTips,
    required int maxOutputTokens,
    required int attempt,
  }) async {
    final uri = Uri.parse('$_kBaseUrl/models/$model:generateContent?key=$apiKey');
    final body = _buildRequestBody(
      draft: draft,
      category: category,
      includeTips: includeTips,
      maxOutputTokens: maxOutputTokens,
    );
    // Jamais l'URI complète (contient ?key=...). Path uniquement, et longueur
    // du body pour estimer le poids du prompt.
    _log('POST attempt=$attempt path=${uri.path} model=$model '
        'bodyLen=${jsonEncode(body).length} maxOut=$maxOutputTokens '
        'tips=$includeTips');

    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      _log('ERROR timeout après ${timeout.inSeconds}s');
      throw GenerationException(
        'La génération a pris trop de temps. Vérifie ta connexion et réessaie.',
      );
    } on http.ClientException catch (e) {
      _log('ERROR ClientException: ${e.message}');
      throw GenerationException('Erreur réseau pendant la génération : ${e.message}');
    } catch (e) {
      _log('ERROR inattendue: $e');
      throw GenerationException('Erreur inattendue : $e');
    }

    _log('HTTP ${response.statusCode} bodyLen=${response.body.length}');

    if (response.statusCode != 200) {
      // Le body d'erreur Gemini contient le code (PERMISSION_DENIED,
      // INVALID_ARGUMENT, NOT_FOUND…) et un message — précieux pour
      // diagnostiquer modèle inaccessible / clé invalide / quota épuisé.
      _log('error body: ${_truncate(response.body)}');
      throw GenerationException(
        'Gemini a répondu ${response.statusCode}. Réessaie dans un instant.',
      );
    }

    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      _log('ÉCHEC enveloppe JSON invalide ($e)');
      _log('raw body: ${_truncate(response.body)}');
      return _GeminiAttempt.failed(
        failureReason: 'enveloppe JSON invalide',
        shouldRetry: false,
      );
    }

    final finishReason = extractFinishReason(envelope);
    final usage = extractUsageMetadata(envelope);
    final text = extractGeminiText(envelope);

    if (text == null || text.trim().isEmpty) {
      _log('ÉCHEC texte vide. finishReason=$finishReason usage=$usage '
          'envelope keys=${envelope.keys.toList()}');
      final feedback = envelope['promptFeedback'];
      if (feedback != null) {
        _log('promptFeedback: ${_truncate(jsonEncode(feedback))}');
      }
      // Si Gemini a coupé sur MAX_TOKENS avant même de produire du texte,
      // ça vaut le coup de retenter avec un budget plus large.
      return _GeminiAttempt.failed(
        failureReason: 'texte vide (finishReason=$finishReason)',
        shouldRetry: finishReason == 'MAX_TOKENS',
      );
    }

    try {
      final ad = parseGeminiAd(rawJson: text, draft: draft);
      _log('OK attempt=$attempt finishReason=$finishReason usage=$usage '
          'title="${_truncate(ad.title, 80)}" '
          'descLen=${ad.description.length} tips=${ad.improvementTips.length}');
      return _GeminiAttempt.ok(ad);
    } on GeminiResponseException catch (e) {
      // Symptôme principal observé en prod : JSON tronqué. On loggue tout
      // ce qui aide à diagnostiquer puis on signale si un retry vaut la peine.
      final truncated = looksTruncated(text: text, finishReason: finishReason);
      _log('ÉCHEC parseGeminiAd : ${e.reason}. '
          'finishReason=$finishReason usage=$usage truncated=$truncated');
      _log('raw text: ${_truncate(text)}');
      return _GeminiAttempt.failed(
        failureReason: 'parse KO (${e.reason})',
        shouldRetry: truncated,
      );
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required AdDraft draft,
    required Category category,
    required bool includeTips,
    required int maxOutputTokens,
  }) {
    final prompt = buildGeminiPrompt(
      draft: draft,
      category: category,
      includeTips: includeTips,
    );
    return {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topP': 0.9,
        'maxOutputTokens': maxOutputTokens,
        'responseMimeType': 'application/json',
        'responseSchema': includeTips ? _kResponseSchemaFull : _kResponseSchemaSlim,
      },
    };
  }
}

/// Résultat d'un essai Gemini. Soit on a une [GeneratedAd], soit on a
/// échoué — et dans ce cas on indique si un retry a une chance d'aider
/// (typiquement : troncature détectée).
class _GeminiAttempt {
  const _GeminiAttempt._({this.ad, this.failureReason, this.shouldRetry = false});
  factory _GeminiAttempt.ok(GeneratedAd ad) => _GeminiAttempt._(ad: ad);
  factory _GeminiAttempt.failed({
    required String failureReason,
    required bool shouldRetry,
  }) =>
      _GeminiAttempt._(failureReason: failureReason, shouldRetry: shouldRetry);

  final GeneratedAd? ad;
  final String? failureReason;
  final bool shouldRetry;
}

/// Schéma JSON imposé à Gemini via `responseSchema`. Garantit que la
/// réponse a la forme attendue par le parser, indépendamment du prompt.
const Map<String, dynamic> _kResponseSchemaFull = {
  'type': 'OBJECT',
  'properties': {
    'title': {'type': 'STRING'},
    'description': {'type': 'STRING'},
    'suggested_price': {
      'type': 'NUMBER',
      'nullable': true,
    },
    'improvement_tips': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
  },
  'required': ['title', 'description'],
};

/// Schéma de retry — on retire `improvement_tips` pour réduire la taille
/// de sortie et la probabilité d'une nouvelle troncature.
const Map<String, dynamic> _kResponseSchemaSlim = {
  'type': 'OBJECT',
  'properties': {
    'title': {'type': 'STRING'},
    'description': {'type': 'STRING'},
    'suggested_price': {
      'type': 'NUMBER',
      'nullable': true,
    },
  },
  'required': ['title', 'description'],
};
