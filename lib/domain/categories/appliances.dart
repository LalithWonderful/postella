import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new', label: 'Neuf, jamais utilisé'),
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état, fonctionnel'),
  FieldOption(value: 'fair', label: 'Correct, traces d\'usage'),
  FieldOption(value: 'for_parts', label: 'Pour pièces / à réparer'),
];

const _energyOptions = [
  FieldOption(value: 'A', label: 'A'),
  FieldOption(value: 'B', label: 'B'),
  FieldOption(value: 'C', label: 'C'),
  FieldOption(value: 'D', label: 'D'),
  FieldOption(value: 'E', label: 'E'),
  FieldOption(value: 'F', label: 'F'),
  FieldOption(value: 'G', label: 'G'),
];

const appliancesCategory = Category(
  id: 'appliances',
  label: 'Électroménager',
  iconKey: 'kitchen',
  photoTips: [
    CommonPhotoTips.goodLighting,
    CommonPhotoTips.front,
    PhotoTip(
      iconKey: 'badge',
      title: 'Plaque signalétique',
      description:
          'Photographiez la plaque signalétique (modèle, année, classe énergétique).',
    ),
    PhotoTip(
      iconKey: 'door_front',
      title: 'Intérieur de l\'appareil',
      description: 'Montrez l\'intérieur propre — décisif pour les acheteurs.',
    ),
    CommonPhotoTips.accessories,
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(id: 'brand', label: 'Marque', required: true),
    FieldSpec.text(
      id: 'item_type',
      label: 'Type d\'appareil',
      required: true,
      hint: 'Lave-linge, frigo, four…',
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
    FieldSpec.number(
      id: 'purchase_year',
      label: 'Année d\'achat',
      minNumber: 1990,
      maxNumber: 2099,
    ),
    FieldSpec.select(
      id: 'energy_class',
      label: 'Classe énergétique',
      options: _energyOptions,
    ),
    FieldSpec.boolean(id: 'delivery_available', label: 'Livraison possible'),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Précisez l\'année d\'achat : au-delà de 7 ans, l\'acheteur attend une décote forte.',
    'Une classe énergétique A+ ou mieux est un argument à mettre en avant.',
    'Les marques premium (Miele, Bosch) gardent leur valeur plus longtemps.',
  ],
  aiContext:
      'Tu rédiges une annonce de seconde main pour un appareil électroménager. '
      'Mets en avant la marque, le type, l\'année et la classe énergétique. '
      'Précise les dimensions si pertinentes et la possibilité de livraison.',
);
