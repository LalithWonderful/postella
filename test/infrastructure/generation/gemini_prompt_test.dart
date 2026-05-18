import 'package:flutter_test/flutter_test.dart';
import 'package:postella/domain/categories/electronics.dart';
import 'package:postella/domain/categories/fashion.dart';
import 'package:postella/domain/models/ad_draft.dart';
import 'package:postella/infrastructure/generation/gemini_prompt.dart';

void main() {
  group('buildGeminiPrompt', () {
    test('inclut la catégorie, le contexte IA et les conseils tarifaires', () {
      const draft = AdDraft(categoryId: 'electronics');
      final prompt = buildGeminiPrompt(
        draft: draft,
        category: electronicsCategory,
      );

      expect(prompt, contains('CATÉGORIE : ${electronicsCategory.label}'));
      expect(prompt, contains(electronicsCategory.aiContext));
      for (final hint in electronicsCategory.pricingHints) {
        expect(prompt, contains(hint));
      }
    });

    test('formate les valeurs select avec leur label humain (FR)', () {
      final draft = AdDraft(
        categoryId: 'fashion',
        details: const {
          'brand': 'Levi\'s',
          'size': 'M',
          'condition': 'very_good',
          'asking_price': 35,
          'gender': 'men',
        },
      );

      final prompt = buildGeminiPrompt(
        draft: draft,
        category: fashionCategory,
      );

      // Codes value JAMAIS exposés à Gemini : il reçoit les labels.
      expect(prompt, isNot(contains('very_good')));
      expect(prompt, contains('Très bon état'));
      expect(prompt, isNot(contains(': men')));
      expect(prompt, contains('Homme'));
      // L'unité € est suffixée au prix.
      expect(prompt, contains('35 €'));
    });

    test('mentionne le nombre de photos sans les transmettre', () {
      final draft = AdDraft(
        categoryId: 'fashion',
        photos: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        details: const {'brand': 'Zara', 'size': 'L', 'condition': 'good'},
      );

      final prompt = buildGeminiPrompt(
        draft: draft,
        category: fashionCategory,
      );

      expect(prompt, contains('PHOTOS DISPONIBLES : 2'));
      expect(prompt, contains('non transmises à toi'));
    });

    test('respecte les contraintes éditoriales (français, JSON strict)', () {
      const draft = AdDraft(categoryId: 'fashion');
      final prompt = buildGeminiPrompt(
        draft: draft,
        category: fashionCategory,
      );

      expect(prompt, contains('français'));
      expect(prompt, contains('STRICTEMENT au schéma JSON'));
      expect(prompt, contains('N\'invente AUCUNE caractéristique'));
      expect(prompt, contains('défaut'));
    });

    test('signale "aucune" quand l\'utilisateur n\'a rien saisi', () {
      const draft = AdDraft(categoryId: 'fashion');
      final prompt = buildGeminiPrompt(
        draft: draft,
        category: fashionCategory,
      );

      expect(prompt, contains('(aucune)'));
    });
  });
}
