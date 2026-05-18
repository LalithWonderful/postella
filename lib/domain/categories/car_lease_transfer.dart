import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _fuelOptions = [
  FieldOption(value: 'petrol', label: 'Essence'),
  FieldOption(value: 'diesel', label: 'Diesel'),
  FieldOption(value: 'hybrid', label: 'Hybride'),
  FieldOption(value: 'plug_in_hybrid', label: 'Hybride rechargeable'),
  FieldOption(value: 'electric', label: 'Électrique'),
];

const _gearboxOptions = [
  FieldOption(value: 'manual', label: 'Manuelle'),
  FieldOption(value: 'automatic', label: 'Automatique'),
];

const _leaseTypeOptions = [
  FieldOption(value: 'lld', label: 'LLD (location longue durée)'),
  FieldOption(value: 'loa', label: 'LOA (location avec option d\'achat)'),
];

const carLeaseTransferCategory = Category(
  id: 'car_lease_transfer',
  label: 'Voiture — reprise / transfert de leasing',
  iconKey: 'sync_alt',
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
      iconKey: 'airline_seat_recline_normal',
      title: 'Habitacle',
      description: 'Sièges et tableau de bord.',
    ),
    PhotoTip(
      iconKey: 'speed',
      title: 'Compteur',
      description: 'Photo du compteur kilométrique allumé.',
    ),
    PhotoTip(
      iconKey: 'description',
      title: 'Page de contrat',
      description:
          'Première page du contrat de leasing (informations sensibles masquées) — c\'est ce que l\'acheteur regardera.',
    ),
    CommonPhotoTips.defects,
  ],
  requiredFields: [
    FieldSpec.text(id: 'brand', label: 'Marque', required: true),
    FieldSpec.text(id: 'model', label: 'Modèle', required: true),
    FieldSpec.number(
      id: 'year',
      label: 'Année',
      required: true,
      minNumber: 1990,
      maxNumber: 2099,
    ),
    FieldSpec.number(
      id: 'mileage',
      label: 'Kilométrage actuel',
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
      id: 'lease_type',
      label: 'Type de contrat',
      options: _leaseTypeOptions,
      required: true,
    ),
    FieldSpec.number(
      id: 'months_remaining',
      label: 'Durée restante',
      required: true,
      unit: 'mois',
      minNumber: 1,
      maxNumber: 60,
    ),
    FieldSpec.number(
      id: 'monthly_payment',
      label: 'Loyer mensuel',
      required: true,
      unit: '€',
      minNumber: 0,
    ),
    FieldSpec.number(
      id: 'contract_mileage_cap',
      label: 'Kilométrage max au contrat',
      required: true,
      unit: 'km',
      minNumber: 0,
    ),
    FieldSpec.number(
      id: 'transfer_fee_requested',
      label: 'Soulte demandée',
      required: true,
      unit: '€',
    ),
  ],
  optionalFields: [
    FieldSpec.text(id: 'financing_company', label: 'Organisme de financement'),
    FieldSpec.date(id: 'contract_end_date', label: 'Date de fin de contrat'),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'La soulte couvre généralement la décote entre la valeur de marché et la valeur résiduelle.',
    'Un kilométrage restant confortable est un argument fort.',
    'Vérifiez avec votre organisme que le transfert est autorisé et listez les frais éventuels.',
  ],
  aiContext:
      'Tu rédiges une annonce de transfert/reprise de leasing automobile (LLD ou LOA). '
      'Mets en avant la marque, modèle, type de contrat, durée et kilométrage restants, loyer mensuel '
      'et soulte demandée. Mentionne explicitement le mot "reprise de leasing". '
      'Reste factuel et indique que les frais de transfert doivent être validés avec l\'organisme.',
);
