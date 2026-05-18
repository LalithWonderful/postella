import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new_with_tag', label: 'Neuf avec étiquette'),
  FieldOption(value: 'new_without_tag', label: 'Neuf sans étiquette'),
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'Correct'),
];

const _genderOptions = [
  FieldOption(value: 'women', label: 'Femme'),
  FieldOption(value: 'men', label: 'Homme'),
  FieldOption(value: 'unisex', label: 'Unisexe'),
  FieldOption(value: 'kids', label: 'Enfant'),
];

const fashionCategory = Category(
  id: 'fashion',
  label: 'Mode, vêtements & chaussures',
  iconKey: 'checkroom',
  photoTips: [
    CommonPhotoTips.goodLighting,
    CommonPhotoTips.front,
    PhotoTip(
      iconKey: 'flip_camera_ios',
      title: 'Photo de dos',
      description: 'Montrez le dos du vêtement, important pour les coupes.',
    ),
    PhotoTip(
      iconKey: 'local_offer',
      title: 'Étiquette de la marque',
      description: 'Photographiez l\'étiquette de marque et de taille en gros plan.',
    ),
    PhotoTip(
      iconKey: 'zoom_in',
      title: 'Détail matière',
      description: 'Un zoom sur la matière rassure sur la qualité du textile.',
    ),
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(id: 'brand', label: 'Marque', required: true),
    FieldSpec.text(id: 'size', label: 'Taille', required: true, hint: 'Ex: M, 38, 42'),
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
    FieldSpec.text(id: 'material', label: 'Matière', hint: 'Coton, laine, cuir…'),
    FieldSpec.text(id: 'color', label: 'Couleur'),
    FieldSpec.select(id: 'gender', label: 'Genre', options: _genderOptions),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Le neuf avec étiquette se revend généralement à 50–70 % du prix d\'origine.',
    'Les marques premium gardent mieux leur valeur — citez-les dans le titre.',
    'Les pièces de la saison en cours se vendent plus rapidement et plus cher.',
  ],
  aiContext:
      'Tu rédiges une annonce de seconde main pour un vêtement, une chaussure ou un accessoire de mode. '
      'Mets en avant la marque, la coupe, la matière, la taille et l\'état. Ton clair, simple, sans hyperbole. '
      'Évite les superlatifs. Tutoie l\'acheteur potentiel.',
);
