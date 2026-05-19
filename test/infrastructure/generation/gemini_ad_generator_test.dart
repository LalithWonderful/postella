import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postella/domain/categories/category.dart';
import 'package:postella/domain/categories/electronics.dart';
import 'package:postella/domain/generation/ad_generator.dart';
import 'package:postella/domain/models/ad_draft.dart';
import 'package:postella/domain/models/generated_ad.dart';
import 'package:postella/infrastructure/generation/gemini_ad_generator.dart';
import 'package:postella/infrastructure/generation/mock_ad_generator.dart';

class _CountingFallback implements AdGenerator {
  int calls = 0;
  @override
  Future<GeneratedAd> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    calls++;
    return MockAdGenerator.buildMockAd(draft: draft, category: category);
  }
}

const _draft = AdDraft(
  categoryId: 'electronics',
  details: {
    'brand': 'Apple',
    'model': 'iPhone 15',
    'condition': 'like_new',
    'asking_price': 600,
  },
);

String _envelope(Map<String, dynamic> innerJson) {
  return jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': jsonEncode(innerJson)},
          ],
        },
      },
    ],
  });
}

/// Enveloppe avec un texte brut (utile pour simuler un JSON tronqué ou
/// pour injecter un finishReason / usageMetadata). Renvoie une
/// [http.Response] encodée en UTF-8 — nécessaire dès qu'on injecte du
/// non-ASCII (em-dash, accents…) car le constructeur par défaut suppose
/// Latin-1.
http.Response _responseRaw({
  required String rawText,
  String? finishReason,
  Map<String, dynamic>? usageMetadata,
}) {
  final body = jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': rawText},
          ],
        },
        'finishReason': ?finishReason,
      },
    ],
    'usageMetadata': ?usageMetadata,
  });
  return http.Response.bytes(
    utf8.encode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('GeminiAdGenerator', () {
    test('appelle Gemini avec le bon endpoint et un body JSON valide', () async {
      late http.Request captured;
      final client = MockClient((req) async {
        captured = req;
        return http.Response(
          _envelope({
            'title': 'iPhone 15 — comme neuf',
            'description': 'Un téléphone bien entretenu.',
            'suggested_price': 590,
            'improvement_tips': ['Photo écran allumé.'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final gen = GeminiAdGenerator(
        apiKey: 'test-key',
        fallback: _CountingFallback(),
        httpClient: client,
      );

      final ad = await gen.generate(
        draft: _draft,
        category: electronicsCategory,
      );

      expect(captured.method, 'POST');
      expect(captured.url.host, 'generativelanguage.googleapis.com');
      expect(captured.url.queryParameters['key'], 'test-key');
      expect(captured.url.path, contains(':generateContent'));

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['generationConfig']['responseMimeType'], 'application/json');
      expect(body['generationConfig']['responseSchema'], isA<Map<String, dynamic>>());
      final parts = ((body['contents'] as List).first
          as Map<String, dynamic>)['parts'] as List;
      expect((parts.first as Map<String, dynamic>)['text'], contains('CATÉGORIE'));

      expect(ad.title, 'iPhone 15 — comme neuf');
      expect(ad.suggestedPrice, 590);
    });

    test('bascule sur le fallback si Gemini répond du JSON inexploitable', () async {
      final fallback = _CountingFallback();
      final client = MockClient((req) async {
        // Réponse 200 mais JSON sans le champ "title" requis.
        return http.Response(
          _envelope({'description': 'Pas de titre'}),
          200,
        );
      });

      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: fallback,
        httpClient: client,
      );

      final ad = await gen.generate(
        draft: _draft,
        category: electronicsCategory,
      );

      expect(fallback.calls, 1);
      // Le mock produit un titre depuis brand+model du draft.
      expect(ad.title, 'Apple iPhone 15');
    });

    test('bascule sur le fallback si l\'enveloppe Gemini est vide', () async {
      final fallback = _CountingFallback();
      final client = MockClient((req) async {
        return http.Response(jsonEncode({'candidates': []}), 200);
      });

      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: fallback,
        httpClient: client,
      );

      await gen.generate(draft: _draft, category: electronicsCategory);
      expect(fallback.calls, 1);
    });

    test('lance GenerationException sur statut HTTP != 200', () async {
      final client = MockClient((req) async => http.Response('boom', 500));
      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: _CountingFallback(),
        httpClient: client,
      );

      expect(
        () => gen.generate(draft: _draft, category: electronicsCategory),
        throwsA(
          isA<GenerationException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
    });

    test('retry une fois si la 1ère réponse est tronquée (MAX_TOKENS)', () async {
      // Reproduit le bug observé : Gemini répond HTTP 200, finishReason
      // MAX_TOKENS, JSON coupé au milieu. Le generator doit retenter avec
      // un schéma simplifié et plus de tokens, et réussir.
      final fallback = _CountingFallback();
      final calls = <Map<String, dynamic>>[];
      final client = MockClient((req) async {
        calls.add(jsonDecode(req.body) as Map<String, dynamic>);
        if (calls.length == 1) {
          return _responseRaw(
            rawText: '{\n  "title": "iPhone 15 — comme neuf",\n  "description": "Un téléphone',
            finishReason: 'MAX_TOKENS',
            usageMetadata: const {
              'promptTokenCount': 250,
              'candidatesTokenCount': 1500,
              'totalTokenCount': 1750,
            },
          );
        }
        return http.Response.bytes(
          utf8.encode(_envelope({
            'title': 'iPhone 15 — comme neuf',
            'description': 'Un téléphone bien entretenu.',
            'suggested_price': 590,
          })),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: fallback,
        httpClient: client,
      );

      final ad = await gen.generate(draft: _draft, category: electronicsCategory);

      expect(calls.length, 2, reason: 'doit avoir retenté exactement une fois');
      expect(fallback.calls, 0, reason: 'le retry a réussi, pas de fallback');
      expect(ad.title, 'iPhone 15 — comme neuf');
      expect(ad.suggestedPrice, 590);

      // Vérifie que le retry a bien simplifié le schéma et bumpé les tokens.
      final firstCfg = calls[0]['generationConfig'] as Map<String, dynamic>;
      final secondCfg = calls[1]['generationConfig'] as Map<String, dynamic>;
      expect(firstCfg['maxOutputTokens'], 1500);
      expect(secondCfg['maxOutputTokens'], 2000);
      final firstProps =
          (firstCfg['responseSchema'] as Map<String, dynamic>)['properties']
              as Map<String, dynamic>;
      final secondProps =
          (secondCfg['responseSchema'] as Map<String, dynamic>)['properties']
              as Map<String, dynamic>;
      expect(firstProps.containsKey('improvement_tips'), isTrue);
      expect(secondProps.containsKey('improvement_tips'), isFalse);
    });

    test('fallback si même le retry renvoie du JSON tronqué', () async {
      final fallback = _CountingFallback();
      var n = 0;
      final client = MockClient((req) async {
        n++;
        return _responseRaw(
          rawText: '{"title":"T","description":"D',
          finishReason: 'MAX_TOKENS',
        );
      });

      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: fallback,
        httpClient: client,
      );

      final ad = await gen.generate(draft: _draft, category: electronicsCategory);
      expect(n, 2, reason: 'tentative initiale + 1 retry');
      expect(fallback.calls, 1);
      // Le mock construit le titre depuis brand + model.
      expect(ad.title, 'Apple iPhone 15');
    });

    test('ne retry pas si la 1ère réponse est juste mal formée mais complète', () async {
      // JSON parfaitement clos mais sans champ "title" : pas de troncature,
      // pas de raison de retenter — on tombe direct sur le fallback.
      final fallback = _CountingFallback();
      var n = 0;
      final client = MockClient((req) async {
        n++;
        return http.Response(
          _envelope({'description': 'Pas de titre'}),
          200,
        );
      });

      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: fallback,
        httpClient: client,
      );

      await gen.generate(draft: _draft, category: electronicsCategory);
      expect(n, 1, reason: 'aucun retry attendu');
      expect(fallback.calls, 1);
    });

    test('lance GenerationException si le client HTTP timeout', () async {
      final client = MockClient((req) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('{}', 200);
      });
      final gen = GeminiAdGenerator(
        apiKey: 'k',
        fallback: _CountingFallback(),
        httpClient: client,
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        gen.generate(draft: _draft, category: electronicsCategory),
        throwsA(isA<GenerationException>()),
      );
    });
  });
}
