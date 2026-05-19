import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:postella/domain/models/ad_draft.dart';
import 'package:postella/infrastructure/generation/gemini_response_parser.dart';

void main() {
  const draftWithPrice = AdDraft(
    categoryId: 'electronics',
    details: {
      'condition': 'like_new',
      'asking_price': 500,
    },
  );

  group('parseGeminiAd', () {
    test('parse une réponse Gemini bien formée', () {
      final raw = jsonEncode({
        'title': 'iPhone 15 Pro 256 Go',
        'description': 'Très bon état général. Vendu avec sa boîte.',
        'suggested_price': 750,
        'improvement_tips': ['Ajoute une photo écran allumé.'],
      });

      final ad = parseGeminiAd(rawJson: raw, draft: draftWithPrice);

      expect(ad.title, 'iPhone 15 Pro 256 Go');
      expect(ad.description, startsWith('Très bon état'));
      expect(ad.suggestedPrice, 750);
      // Le condition vient TOUJOURS du draft, pas de Gemini.
      expect(ad.condition, 'like_new');
      expect(ad.improvementTips, ['Ajoute une photo écran allumé.']);
    });

    test('utilise le prix du draft si Gemini renvoie null', () {
      final raw = jsonEncode({
        'title': 'iPhone',
        'description': 'Tel quel.',
        'suggested_price': null,
      });

      final ad = parseGeminiAd(rawJson: raw, draft: draftWithPrice);

      expect(ad.suggestedPrice, 500); // fallback sur asking_price du draft
    });

    test('renvoie 0 si ni Gemini ni le draft n\'ont de prix', () {
      final raw = jsonEncode({
        'title': 'Truc',
        'description': 'Bidule',
      });
      const emptyDraft = AdDraft(categoryId: 'other');

      final ad = parseGeminiAd(rawJson: raw, draft: emptyDraft);

      expect(ad.suggestedPrice, 0);
    });

    test('ignore les tips vides ou null', () {
      final raw = jsonEncode({
        'title': 'T',
        'description': 'D',
        'improvement_tips': ['Bon conseil', '', null, '   '],
      });

      final ad = parseGeminiAd(rawJson: raw, draft: draftWithPrice);

      expect(ad.improvementTips, ['Bon conseil']);
    });

    test('throw GeminiResponseException sur JSON malformé', () {
      expect(
        () => parseGeminiAd(rawJson: '{not json', draft: draftWithPrice),
        throwsA(isA<GeminiResponseException>()),
      );
    });

    test('throw GeminiResponseException sur JSON tronqué (cas réel Gemini)', () {
      // Symptôme observé en prod : Gemini répond HTTP 200 mais le JSON est
      // coupé au milieu (MAX_TOKENS). Le parser doit lever, jamais retourner
      // de GeneratedAd partielle.
      const truncated = '{\n'
          '  "title": "Vêtement femme taille 36 - Neuf sans étiquette",\n'
          '  "description": "Très joli haut, jamais porté, taille 36';
      expect(
        () => parseGeminiAd(rawJson: truncated, draft: draftWithPrice),
        throwsA(
          isA<GeminiResponseException>().having(
            (e) => e.reason,
            'reason',
            contains('JSON invalide'),
          ),
        ),
      );
    });

    test('throw GeminiResponseException si title manquant', () {
      final raw = jsonEncode({'description': 'D'});
      expect(
        () => parseGeminiAd(rawJson: raw, draft: draftWithPrice),
        throwsA(isA<GeminiResponseException>()),
      );
    });

    test('throw GeminiResponseException si description vide', () {
      final raw = jsonEncode({'title': 'T', 'description': '   '});
      expect(
        () => parseGeminiAd(rawJson: raw, draft: draftWithPrice),
        throwsA(isA<GeminiResponseException>()),
      );
    });

    test('throw GeminiResponseException si la réponse n\'est pas un objet', () {
      expect(
        () => parseGeminiAd(rawJson: '[1,2,3]', draft: draftWithPrice),
        throwsA(isA<GeminiResponseException>()),
      );
    });
  });

  group('extractGeminiText', () {
    test('extrait candidates[0].content.parts[0].text', () {
      final envelope = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '{"title":"T"}'},
              ],
            },
          },
        ],
      };
      expect(extractGeminiText(envelope), '{"title":"T"}');
    });

    test('retourne null si la structure est inattendue', () {
      expect(extractGeminiText(const {}), isNull);
      expect(extractGeminiText({'candidates': []}), isNull);
      expect(extractGeminiText({'candidates': [{}]}), isNull);
      expect(
        extractGeminiText({
          'candidates': [
            {'content': {'parts': []}},
          ],
        }),
        isNull,
      );
    });
  });

  group('extractFinishReason', () {
    test('extrait candidates[0].finishReason', () {
      expect(
        extractFinishReason({
          'candidates': [
            {'finishReason': 'MAX_TOKENS'},
          ],
        }),
        'MAX_TOKENS',
      );
    });

    test('null si absent', () {
      expect(extractFinishReason(const {}), isNull);
      expect(extractFinishReason({'candidates': []}), isNull);
      expect(extractFinishReason({'candidates': [{}]}), isNull);
    });
  });

  group('extractUsageMetadata', () {
    test('extrait usageMetadata', () {
      final usage = extractUsageMetadata({
        'usageMetadata': {
          'promptTokenCount': 200,
          'candidatesTokenCount': 1024,
          'totalTokenCount': 1224,
        },
      });
      expect(usage, isNotNull);
      expect(usage!['candidatesTokenCount'], 1024);
    });

    test('null si absent', () {
      expect(extractUsageMetadata(const {}), isNull);
    });
  });

  group('looksTruncated', () {
    test('vrai sur MAX_TOKENS quel que soit le texte', () {
      expect(
        looksTruncated(text: '{"title":"T"}', finishReason: 'MAX_TOKENS'),
        isTrue,
      );
    });

    test('vrai si le texte ne se termine pas par "}"', () {
      expect(looksTruncated(text: '{"title":"T",', finishReason: null), isTrue);
      expect(looksTruncated(text: '{"title":"T"', finishReason: 'STOP'), isTrue);
    });

    test('faux si le texte se termine bien par "}" et finishReason != MAX_TOKENS', () {
      expect(
        looksTruncated(text: '{"title":"T"}', finishReason: 'STOP'),
        isFalse,
      );
      expect(
        looksTruncated(text: '{"title":"T"}  \n', finishReason: null),
        isFalse,
      );
    });

    test('faux si texte null ou vide', () {
      expect(looksTruncated(text: null, finishReason: 'STOP'), isFalse);
      expect(looksTruncated(text: '   ', finishReason: 'STOP'), isFalse);
    });
  });
}
