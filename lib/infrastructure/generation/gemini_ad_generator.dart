import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/categories/category.dart';
import '../../domain/generation/ad_generator.dart';
import '../../domain/models/ad_draft.dart';
import '../../domain/models/generated_ad.dart';
import 'gemini_prompt.dart';
import 'gemini_response_parser.dart';

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
      throw GenerationException(
        'La génération a pris trop de temps. Vérifie ta connexion et réessaie.',
      );
    } on http.ClientException catch (e) {
      throw GenerationException('Erreur réseau pendant la génération : ${e.message}');
    } catch (e) {
      throw GenerationException('Erreur inattendue : $e');
    }

    if (response.statusCode != 200) {
      throw GenerationException(
        'Gemini a répondu ${response.statusCode}. Réessaie dans un instant.',
      );
    }

    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return fallback.generate(draft: draft, category: category);
    }

    final text = extractGeminiText(envelope);
    if (text == null || text.trim().isEmpty) {
      return fallback.generate(draft: draft, category: category);
    }

    try {
      return parseGeminiAd(rawJson: text, draft: draft);
    } on GeminiResponseException {
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
