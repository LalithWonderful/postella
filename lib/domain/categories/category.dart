import 'field_spec.dart';
import 'photo_tip.dart';

/// Description statique d'une catégorie d'annonce.
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.photoTips,
    required this.requiredFields,
    required this.optionalFields,
    required this.pricingHints,
    required this.aiContext,
  });

  /// Identifiant stable (snake_case) — utilisé dans `Ad.category`.
  final String id;
  final String label;

  /// Clé d'icône Material résolue par l'UI.
  final String iconKey;

  /// Conseils photo affichés à l'étape photos.
  final List<PhotoTip> photoTips;

  /// Champs obligatoires affichés à l'étape "Informations".
  final List<FieldSpec> requiredFields;

  /// Champs optionnels affichés à l'étape "Informations".
  final List<FieldSpec> optionalFields;

  /// Conseils tarifaires affichés en complément.
  final List<String> pricingHints;

  /// Fragment de prompt injecté côté IA pour orienter la génération.
  final String aiContext;

  /// Tous les champs (required puis optional) — pratique pour l'UI.
  List<FieldSpec> get allFields => [...requiredFields, ...optionalFields];
}
