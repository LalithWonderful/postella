import 'category.dart';
import 'field_spec.dart';
import 'photo_tip.dart';

const _conditionOptions = [
  FieldOption(value: 'new', label: 'Neuf'),
  FieldOption(value: 'like_new', label: 'Comme neuf'),
  FieldOption(value: 'good', label: 'Bon état'),
  FieldOption(value: 'fair', label: 'Correct, traces d\'usage'),
  FieldOption(value: 'annotated', label: 'Annoté / souligné'),
];

const booksCategory = Category(
  id: 'books',
  label: 'Livres',
  iconKey: 'menu_book',
  photoTips: [
    CommonPhotoTips.goodLighting,
    PhotoTip(
      iconKey: 'book',
      title: 'Couverture',
      description: 'Cadrez la couverture entièrement, sans reflet.',
    ),
    PhotoTip(
      iconKey: 'flip_to_back',
      title: 'Quatrième de couverture',
      description: 'La photo du dos permet de lire le résumé.',
    ),
    PhotoTip(
      iconKey: 'view_agenda',
      title: 'Tranche',
      description: 'La tranche révèle l\'état général et les éventuelles pliures.',
    ),
    PhotoTip(
      iconKey: 'edit_note',
      title: 'Annotations éventuelles',
      description: 'Si le livre contient des annotations, montrez-en quelques-unes.',
    ),
    CommonPhotoTips.avoidBlurry,
  ],
  requiredFields: [
    FieldSpec.text(id: 'title', label: 'Titre', required: true),
    FieldSpec.text(id: 'author', label: 'Auteur', required: true),
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
    FieldSpec.text(id: 'publisher', label: 'Éditeur'),
    FieldSpec.number(
      id: 'edition_year',
      label: 'Année d\'édition',
      minNumber: 1500,
      maxNumber: 2099,
    ),
    FieldSpec.text(id: 'isbn', label: 'ISBN'),
    FieldSpec.text(id: 'genre', label: 'Genre / domaine'),
    FieldSpec.textarea(id: 'notes', label: 'Notes complémentaires'),
  ],
  pricingHints: [
    'Les livres scolaires de la dernière édition se vendent rapidement.',
    'Les éditions originales ou de collection peuvent valoir bien plus que le prix neuf.',
    'Un lot de plusieurs ouvrages d\'un même auteur peut être vendu en pack.',
  ],
  aiContext:
      'Tu rédiges une annonce pour un livre d\'occasion. '
      'Mentionne titre, auteur, éditeur, état et signale toute annotation. '
      'Reste sobre, pas de hype.',
);
