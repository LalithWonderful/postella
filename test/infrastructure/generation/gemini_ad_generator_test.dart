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
