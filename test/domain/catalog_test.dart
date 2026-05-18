import 'package:flutter_test/flutter_test.dart';
import 'package:postella/domain/categories/catalog.dart';
import 'package:postella/domain/categories/field_spec.dart';

void main() {
  test('catalog contient les 9 catégories MVP attendues', () {
    final ids = kCatalog.map((c) => c.id).toList();
    expect(ids, [
      'fashion',
      'electronics',
      'furniture',
      'appliances',
      'books',
      'real_estate',
      'car_sale',
      'car_lease_transfer',
      'other',
    ]);
  });

  test('toutes les catégories ont les champs métadonnées renseignés', () {
    for (final c in kCatalog) {
      expect(c.label, isNotEmpty, reason: '${c.id} label');
      expect(c.iconKey, isNotEmpty, reason: '${c.id} iconKey');
      expect(c.aiContext, isNotEmpty, reason: '${c.id} aiContext');
      expect(c.photoTips, isNotEmpty, reason: '${c.id} photoTips');
      expect(c.requiredFields, isNotEmpty, reason: '${c.id} requiredFields');
      expect(c.pricingHints, isNotEmpty, reason: '${c.id} pricingHints');
    }
  });

  test('chaque requiredField est bien marqué required = true', () {
    for (final c in kCatalog) {
      for (final f in c.requiredFields) {
        expect(
          f.required,
          isTrue,
          reason: '${c.id}.${f.id} should be required',
        );
      }
    }
  });

  test('chaque optionalField est bien marqué required = false', () {
    for (final c in kCatalog) {
      for (final f in c.optionalFields) {
        expect(
          f.required,
          isFalse,
          reason: '${c.id}.${f.id} should not be required',
        );
      }
    }
  });

  test('les id de champ sont uniques au sein d\'une catégorie', () {
    for (final c in kCatalog) {
      final ids = c.allFields.map((f) => f.id).toList();
      final unique = ids.toSet();
      expect(
        ids.length,
        unique.length,
        reason: 'duplicate field id in ${c.id}: $ids',
      );
    }
  });

  test('les FieldSpec select/multiSelect fournissent toujours des options', () {
    for (final c in kCatalog) {
      for (final f in c.allFields) {
        if (f.kind == FieldKind.select || f.kind == FieldKind.multiSelect) {
          expect(
            f.options,
            isNotNull,
            reason: '${c.id}.${f.id} (${f.kind}) missing options',
          );
          expect(f.options!, isNotEmpty);
        }
      }
    }
  });

  test('findCategory retourne la bonne catégorie ou null', () {
    expect(findCategory('books')?.id, 'books');
    expect(findCategory('car_sale')?.id, 'car_sale');
    expect(findCategory('does_not_exist'), isNull);
  });

  test('chaque catégorie a au moins un champ monétaire obligatoire', () {
    // L'unité '€' est l'invariant : qu'il s'agisse d'un prix de vente, d'un
    // loyer mensuel ou d'une soulte (leasing), il y a toujours un montant.
    for (final c in kCatalog) {
      final hasMoneyField = c.requiredFields.any(
        (f) => f.kind == FieldKind.number && f.unit == '€',
      );
      expect(
        hasMoneyField,
        isTrue,
        reason: '${c.id} should have a required money field (unit €)',
      );
    }
  });
}
