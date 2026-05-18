import 'package:flutter_test/flutter_test.dart';
import 'package:postella/domain/categories/electronics.dart';
import 'package:postella/domain/models/ad_draft.dart';
import 'package:postella/infrastructure/generation/mock_ad_generator.dart';

void main() {
  group('MockAdGenerator', () {
    test('compose un titre "marque + modèle" quand les deux sont saisis', () {
      final draft = AdDraft(
        categoryId: 'electronics',
        photos: const ['/tmp/a.jpg', '/tmp/b.jpg', '/tmp/c.jpg'],
        details: const {
          'brand': 'Apple',
          'model': 'iPhone 15',
          'condition': 'like_new',
          'asking_price': 600,
        },
      );

      final ad = MockAdGenerator.buildMockAd(
        draft: draft,
        category: electronicsCategory,
      );

      expect(ad.title, 'Apple iPhone 15');
      expect(ad.suggestedPrice, 600.0);
      expect(ad.condition, 'like_new');
      expect(ad.description, contains('iPhone 15'));
      // Avec >= 3 photos et notes vides, on doit avoir 1 tip "notes" + 1 pricing
      expect(ad.improvementTips, isNotEmpty);
      expect(
        ad.improvementTips.any((t) => t.toLowerCase().contains('notes')),
        isTrue,
      );
    });

    test(
      'recommande d\'ajouter des photos quand le draft en a moins de 3',
      () {
        final draft = AdDraft(
          categoryId: 'electronics',
          photos: const ['/tmp/a.jpg'],
          details: const {
            'brand': 'Sony',
            'model': 'WH-1000XM5',
            'condition': 'good',
            'asking_price': 200,
          },
        );

        final ad = MockAdGenerator.buildMockAd(
          draft: draft,
          category: electronicsCategory,
        );

        expect(
          ad.improvementTips.any((t) => t.toLowerCase().contains('photo')),
          isTrue,
        );
      },
    );

    test('retourne suggestedPrice 0 si aucun champ monétaire saisi', () {
      const draft = AdDraft(
        categoryId: 'electronics',
        details: {'brand': 'Bose'},
      );

      final ad = MockAdGenerator.buildMockAd(
        draft: draft,
        category: electronicsCategory,
      );

      expect(ad.suggestedPrice, 0);
    });
  });
}
