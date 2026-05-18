/// Décrit un champ de formulaire affichable dynamiquement par l'UI.
///
/// Volontairement simple et statique : les FieldSpec sont des constantes
/// déclarées dans les fichiers de catégorie. Pas de freezed ici — pas de
/// copyWith ni de sérialisation JSON nécessaire.
enum FieldKind { text, number, select, multiSelect, boolean, date, textarea }

class FieldSpec {
  const FieldSpec({
    required this.id,
    required this.label,
    required this.kind,
    this.required = false,
    this.hint,
    this.options,
    this.minNumber,
    this.maxNumber,
    this.unit,
  });

  /// Clé stable utilisée comme clé dans `Ad.details`.
  final String id;

  /// Libellé affiché à l'utilisateur (FR).
  final String label;
  final FieldKind kind;
  final bool required;
  final String? hint;

  /// Liste d'options pour [FieldKind.select] et [FieldKind.multiSelect].
  final List<FieldOption>? options;

  /// Bornes pour [FieldKind.number] (purement indicatives, pas bloquantes).
  final num? minNumber;
  final num? maxNumber;

  /// Unité affichée pour [FieldKind.number], ex: '€', 'km', 'm²'.
  final String? unit;

  // Helpers pour les declarations const concises dans les catégories.
  const FieldSpec.text({
    required this.id,
    required this.label,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.text,
       options = null,
       minNumber = null,
       maxNumber = null,
       unit = null;

  const FieldSpec.textarea({
    required this.id,
    required this.label,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.textarea,
       options = null,
       minNumber = null,
       maxNumber = null,
       unit = null;

  const FieldSpec.number({
    required this.id,
    required this.label,
    this.required = false,
    this.hint,
    this.minNumber,
    this.maxNumber,
    this.unit,
  }) : kind = FieldKind.number,
       options = null;

  const FieldSpec.select({
    required this.id,
    required this.label,
    required this.options,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.select,
       minNumber = null,
       maxNumber = null,
       unit = null;

  const FieldSpec.multiSelect({
    required this.id,
    required this.label,
    required this.options,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.multiSelect,
       minNumber = null,
       maxNumber = null,
       unit = null;

  const FieldSpec.boolean({
    required this.id,
    required this.label,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.boolean,
       options = null,
       minNumber = null,
       maxNumber = null,
       unit = null;

  const FieldSpec.date({
    required this.id,
    required this.label,
    this.required = false,
    this.hint,
  }) : kind = FieldKind.date,
       options = null,
       minNumber = null,
       maxNumber = null,
       unit = null;
}

class FieldOption {
  const FieldOption({required this.value, required this.label});

  /// Valeur stable stockée dans `Ad.details`.
  final String value;

  /// Libellé affiché.
  final String label;
}
