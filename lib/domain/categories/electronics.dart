import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new_sealed', label: 'Neuf, sous blister'),
  FieldOption(value: 'like_new', label: 'Comme neuf'),
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'Correct, traces d\'usage'),
  FieldOption(value: 'for_parts', label: 'Pour pièces / défectueux'),
];

const _accessoriesOptions = [
  FieldOption(value: 'box', label: 'Boîte d\'origine'),
  FieldOption(value: 'charger', label: 'Chargeur'),
  FieldOption(value: 'cable', label: 'Câble'),
  FieldOption(value: 'manual', label: 'Manuel'),
  FieldOption(value: 'receipt', label: 'Facture'),
  FieldOption(value: 'warranty', label: 'Garantie en cours'),
];

const electronicsCategory = Category(
  id: 'electronics',
  label: 'Électronique',
  iconKey: 'devices',
  photoTips: [
    CommonPhotoTips.goodLighting,
    CommonPhotoTips.front,
    CommonPhotoTips.back,
    PhotoTip(
      iconKey: 'power_settings_new',
      title: 'Écran allumé',
      description: 'Une photo de l\'appareil allumé prouve qu\'il fonctionne.',
    ),
    CommonPhotoTips.accessories,
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(id: 'brand', label: 'Marque', required: true, hint: 'Apple, Samsung…'),
    FieldSpec.text(id: 'model', label: 'Modèle', required: true, hint: 'iPhone 15, Galaxy S24…'),
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
    FieldSpec.number(
      id: 'purchase_year',
      label: 'Année d\'achat',
      minNumber: 1990,
      maxNumber: 2099,
    ),
    FieldSpec.multiSelect(
      id: 'accessories',
      label: 'Accessoires inclus',
      options: _accessoriesOptions,
    ),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Les smartphones perdent 15–25 % par an, plus rapidement après 3 ans.',
    'Une facture d\'achat ou une garantie en cours justifie un prix plus élevé.',
    'Les accessoires d\'origine (boîte, chargeur) ajoutent 10–15 % à la valeur.',
  ],
  aiContext:
      'Tu rédiges une annonce de seconde main pour un produit électronique. '
      'Mets en avant la marque, le modèle exact, l\'état et les accessoires inclus. '
      'Liste clairement ce qui fonctionne. Reste factuel, évite le marketing.',
);
