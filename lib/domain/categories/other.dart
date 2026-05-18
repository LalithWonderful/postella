import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new', label: 'Neuf'),
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'Correct'),
  FieldOption(value: 'to_repair', label: 'À réparer'),
];

const otherCategory = Category(
  id: 'other',
  label: 'Autre',
  iconKey: 'category',
  photoTips: [
    CommonPhotoTips.goodLighting,
    CommonPhotoTips.front,
    CommonPhotoTips.side,
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(
      id: 'item_title',
      label: 'Nom de l\'objet',
      required: true,
      hint: 'Ex: Vélo de course, vase en céramique…',
    ),
    FieldSpec.select(
      id: 'condition',
      label: 'État',
      options: _conditionOptions,
      required: true,
    ),
    FieldSpec.number(
      id: 'asking_price',
      label: 'Prix souhaité',
      required: true,
      unit: '€',
      minNumber: 0,
    ),
  ],
  optionalFields: [
    FieldSpec.text(id: 'brand', label: 'Marque'),
    FieldSpec.text(id: 'dimensions', label: 'Dimensions'),
    FieldSpec.textarea(
      id: 'notes',
      label: 'Description libre',
      hint: 'Tout ce qui peut aider l\'acheteur.',
    ),
  ],
  pricingHints: [
    'Cherchez des annonces similaires avant de fixer un prix.',
    'Soyez précis dans le titre : "Vélo de course Decathlon 2022" plutôt que "Vélo".',
  ],
  aiContext:
      'Tu rédiges une annonce de seconde main pour un objet ne rentrant pas dans une catégorie spécifique. '
      'Utilise toutes les informations fournies par l\'utilisateur. Reste factuel.',
);
