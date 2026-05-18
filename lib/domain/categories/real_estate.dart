import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _typeOptions = [
  FieldOption(value: 'apartment', label: 'Appartement'),
  FieldOption(value: 'house', label: 'Maison'),
  FieldOption(value: 'studio', label: 'Studio'),
  FieldOption(value: 'land', label: 'Terrain'),
  FieldOption(value: 'parking', label: 'Parking / box'),
];

const _conditionOptions = [
  FieldOption(value: 'new', label: 'Neuf / VEFA'),
  FieldOption(value: 'renovated', label: 'Rénové récemment'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'refresh_needed', label: 'À rafraîchir'),
  FieldOption(value: 'to_renovate', label: 'À rénover'),
];

const _outdoorOptions = [
  FieldOption(value: 'none', label: 'Aucun'),
  FieldOption(value: 'balcony', label: 'Balcon'),
  FieldOption(value: 'terrace', label: 'Terrasse'),
  FieldOption(value: 'garden', label: 'Jardin'),
  FieldOption(value: 'loggia', label: 'Loggia'),
];

const realEstateCategory = Category(
  id: 'real_estate',
  label: 'Immobilier',
  iconKey: 'home',
  photoTips: [
    CommonPhotoTips.goodLighting,
    PhotoTip(
      iconKey: 'apartment',
      title: 'Façade extérieure',
      description: 'Une photo extérieure aide à se projeter, sans révéler l\'adresse.',
    ),
    PhotoTip(
      iconKey: 'weekend',
      title: 'Salon principal',
      description: 'Pièce de vie avec la luminosité au mieux.',
    ),
    PhotoTip(
      iconKey: 'kitchen',
      title: 'Cuisine',
      description: 'Cadrage large, plan de travail dégagé.',
    ),
    PhotoTip(
      iconKey: 'bed',
      title: 'Chambres',
      description: 'Une photo par chambre, lit fait, espace dégagé.',
    ),
    PhotoTip(
      iconKey: 'bathtub',
      title: 'Salle de bain',
      description: 'Sanitaires propres, bonne lumière.',
    ),
    PhotoTip(
      iconKey: 'landscape',
      title: 'Vue / extérieur',
      description: 'Montrez la vue, le balcon ou le jardin si vous en avez.',
    ),
    PhotoTip(
      iconKey: 'architecture',
      title: 'Plan si disponible',
      description: 'Un plan en photo est très apprécié par les acheteurs sérieux.',
    ),
  ],
  requiredFields: [
    FieldSpec.select(
      id: 'property_type',
      label: 'Type de bien',
      options: _typeOptions,
      required: true,
    ),
    FieldSpec.text(id: 'city', label: 'Ville', required: true),
    FieldSpec.number(
      id: 'surface_sqm',
      label: 'Surface',
      required: true,
      unit: 'm²',
      minNumber: 1,
    ),
    FieldSpec.number(
      id: 'rooms',
      label: 'Nombre de pièces',
      required: true,
      minNumber: 1,
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
    FieldSpec.number(id: 'floor', label: 'Étage', minNumber: -2, maxNumber: 50),
    FieldSpec.select(
      id: 'outdoor',
      label: 'Extérieur',
      options: _outdoorOptions,
    ),
    FieldSpec.select(
      id: 'condition',
      label: 'État général',
      options: _conditionOptions,
    ),
    FieldSpec.number(
      id: 'monthly_charges',
      label: 'Charges mensuelles',
      unit: '€',
      minNumber: 0,
    ),
    FieldSpec.textarea(
      id: 'highlights',
      label: 'Points forts',
      hint: 'Lumineux, calme, proche transports…',
    ),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Comparez avec les annonces actives dans le même secteur sur les 90 derniers jours.',
    'Les biens lumineux et bien orientés se vendent 5–10 % plus cher en moyenne.',
    'Mentionnez les charges et les diagnostics énergétiques pour éviter les acheteurs déçus.',
  ],
  aiContext:
      'Tu rédiges une annonce immobilière de vente entre particuliers. '
      'Mentionne type de bien, ville, surface, nombre de pièces, étage si pertinent, '
      'extérieur, exposition, et points forts. Reste factuel, n\'invente aucun détail. '
      'Ne donne jamais d\'adresse précise, uniquement la ville et le quartier si l\'utilisateur le mentionne.',
);
