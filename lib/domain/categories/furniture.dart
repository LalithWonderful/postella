import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new', label: 'Neuf'),
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'Correct, à rafraîchir'),
  FieldOption(value: 'to_renovate', label: 'À rénover'),
];

const furnitureCategory = Category(
  id: 'furniture',
  label: 'Meubles & décoration',
  iconKey: 'chair',
  photoTips: [
    CommonPhotoTips.goodLighting,
    CommonPhotoTips.front,
    CommonPhotoTips.side,
    CommonPhotoTips.overhead,
    PhotoTip(
      iconKey: 'straighten',
      title: 'Dimensions visibles',
      description: 'Une photo avec mètre ou règle aide énormément l\'acheteur.',
    ),
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(
      id: 'item_type',
      label: 'Type d\'objet',
      required: true,
      hint: 'Canapé, table, lampe…',
    ),
    FieldSpec.text(
      id: 'dimensions',
      label: 'Dimensions',
      required: true,
      hint: 'L x l x H en cm',
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
    FieldSpec.text(id: 'material', label: 'Matière', hint: 'Bois massif, métal…'),
    FieldSpec.text(id: 'color', label: 'Couleur'),
    FieldSpec.text(id: 'brand', label: 'Marque / éditeur'),
    FieldSpec.boolean(id: 'delivery_available', label: 'Livraison possible'),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Les pièces de marque (Ligne Roset, IKEA Stockholm…) gardent mieux leur valeur.',
    'Le bois massif se revend mieux que les matériaux composites.',
    'Précisez si la livraison ou le démontage sont possibles, c\'est un gros frein sinon.',
  ],
  aiContext:
      'Tu rédiges une annonce de seconde main pour un meuble ou un objet de décoration. '
      'Donne les dimensions, la matière, l\'état et le contexte d\'utilisation. '
      'Mentionne explicitement les conditions de retrait (à venir chercher / livraison possible).',
);
