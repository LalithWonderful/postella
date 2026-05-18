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
    final uri = Uri.parse('$_kBaseUrl/models/$model:generateContent?key=$apiKey');
    final body = _buildRequestBody(draft: draft, category: category);
    // Jamais l'URI complète (contient ?key=...). Path uniquement, et longueur
    // du body pour estimer le poids du prompt.
    _log('POST path=${uri.path} model=$model bodyLen=${jsonEncode(body).length}');

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
      _log('FALLBACK : enveloppe JSON invalide ($e)');
      _log('raw body: ${_truncate(response.body)}');
      return fallback.generate(draft: draft, category: category);
    }

    final text = extractGeminiText(envelope);
    if (text == null || text.trim().isEmpty) {
      _log('FALLBACK : extractGeminiText vide. '
          'envelope keys=${envelope.keys.toList()}');
      // Détail utile : Gemini renvoie souvent un finishReason ou un
      // promptFeedback (filtres safety) quand il refuse de générer.
      final candidates = envelope['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        _log('candidate[0]: ${_truncate(jsonEncode(candidates.first))}');
      }
      final feedback = envelope['promptFeedback'];
      if (feedback != null) {
        _log('promptFeedback: ${_truncate(jsonEncode(feedback))}');
      }
      return fallback.generate(draft: draft, category: category);
    }

    try {
      final ad = parseGeminiAd(rawJson: text, draft: draft);
      _log('OK title="${_truncate(ad.title, 80)}" '
          'descLen=${ad.description.length} tips=${ad.improvementTips.length}');
      return ad;
    } on GeminiResponseException catch (e) {
      _log('FALLBACK : parseGeminiAd a échoué (${e.reason})');
      _log('raw text: ${_truncate(text)}');
      return fallback.generate(draft: draft, category: category);
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required AdDraft draft,
    required Category category,
  }) {
    final prompt = buildGeminiPrompt(draft: draft, category: category);
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
        'maxOutputTokens': 1024,
        'responseMimeType': 'application/json',
        'responseSchema': _kResponseSchema,
      },
    };
  }
}

/// Schéma JSON imposé à Gemini via `responseSchema`. Garantit que la
/// réponse a la forme attendue par le parser, indépendamment du prompt.
const Map<String, dynamic> _kResponseSchema = {
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
