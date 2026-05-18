import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _fuelOptions = [
  FieldOption(value: 'petrol', label: 'Essence'),
  FieldOption(value: 'diesel', label: 'Diesel'),
  FieldOption(value: 'hybrid', label: 'Hybride'),
  FieldOption(value: 'plug_in_hybrid', label: 'Hybride rechargeable'),
  FieldOption(value: 'electric', label: 'Électrique'),
  FieldOption(value: 'lpg', label: 'GPL'),
];

const _gearboxOptions = [
  FieldOption(value: 'manual', label: 'Manuelle'),
  FieldOption(value: 'automatic', label: 'Automatique'),
];

const _conditionOptions = [
  FieldOption(value: 'very_good', label: 'Très bon état'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'État correct'),
  FieldOption(value: 'damaged', label: 'À réparer'),
];

const carSaleCategory = Category(
  id: 'car_sale',
  label: 'Voiture — vente',
  iconKey: 'directions_car',
  photoTips: [
    CommonPhotoTips.goodLighting,
    PhotoTip(
      iconKey: 'photo_camera_front',
      title: 'Face avant',
      description: 'Vue 3/4 avant, voiture entière, propre.',
    ),
    PhotoTip(
      iconKey: 'flip_camera_ios',
      title: 'Face arrière',
      description: '3/4 arrière, plaque masquée si souhaité.',
    ),
    PhotoTip(
      iconKey: 'arrow_left',
      title: 'Profil gauche',
      description: 'Profil complet côté conducteur.',
    ),
    PhotoTip(
      iconKey: 'arrow_right',
      title: 'Profil droit',
      description: 'Profil complet côté passager.',
    ),
    PhotoTip(
      iconKey: 'airline_seat_recline_normal',
      title: 'Habitacle',
      description: 'Sièges avant et arrière, tableau de bord visible.',
    ),
    PhotoTip(
      iconKey: 'speed',
      title: 'Compteur kilométrique',
      description: 'Photo du compteur, allumé, kilométrage lisible.',
    ),
    CommonPhotoTips.defects,
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(id: 'brand', label: 'Marque', required: true),
    FieldSpec.text(id: 'model', label: 'Modèle', required: true),
    FieldSpec.number(
      id: 'year',
      label: 'Année',
      required: true,
      minNumber: 1950,
      maxNumber: 2099,
    ),
    FieldSpec.number(
      id: 'mileage',
      label: 'Kilométrage',
      required: true,
      unit: 'km',
      minNumber: 0,
    ),
    FieldSpec.select(
      id: 'fuel',
      label: 'Carburant',
      options: _fuelOptions,
      required: true,
    ),
    FieldSpec.select(
      id: 'gearbox',
      label: 'Boîte',
      options: _gearboxOptions,
      required: true,
    ),
    FieldSpec.select(
      id: 'condition',
      label: 'État général',
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
    FieldSpec.boolean(
      id: 'technical_inspection_valid',
      label: 'Contrôle technique à jour',
    ),
    FieldSpec.boolean(id: 'service_history', label: 'Carnet d\'entretien suivi'),
    FieldSpec.date(id: 'first_registration', label: 'Date de 1re mise en circulation'),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Le prix dépend fortement de l\'année, du kilométrage et de l\'historique d\'entretien.',
    'Un contrôle technique récent et un carnet d\'entretien complet valorisent la voiture.',
    'Comparez avec des annonces similaires sur les 30 derniers jours, même version et finition.',
  ],
  aiContext:
      'Tu rédiges une annonce de vente automobile entre particuliers. '
      'Mentionne marque, modèle, année, kilométrage, carburant, boîte, état, '
      'entretien et contrôle technique. Reste factuel, n\'invente aucune option. '
      'Précise si la voiture est visible sur place.',
);
