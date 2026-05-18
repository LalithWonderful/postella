/// Conseil photo affiché lors de la prise/import de photos, contextualisé
/// à la catégorie courante.
class PhotoTip {
  const PhotoTip({
    required this.iconKey,
    required this.title,
    required this.description,
  });

  /// Clé d'icône Material résolue par l'UI (cf. ui/widgets/photo_tip_card).
  final String iconKey;
  final String title;
  final String description;
}

/// Petits builders réutilisés par plusieurs catégories.
class CommonPhotoTips {
  const CommonPhotoTips._();

  static const goodLighting = PhotoTip(
    iconKey: 'wb_sunny',
    title: 'Bon éclairage',
    description:
        'Privilégiez la lumière naturelle et évitez les contre-jours et les ombres dures.',
  );

  static const front = PhotoTip(
    iconKey: 'photo_camera_front',
    title: 'Photo de face',
    description: 'Cadrez l\'objet centré, vu de face, sur fond neutre.',
  );

  static const side = PhotoTip(
    iconKey: 'photo_camera',
    title: 'Photo de côté',
    description: 'Montrez le profil pour donner les proportions.',
  );

  static const back = PhotoTip(
    iconKey: 'flip_camera_ios',
    title: 'Photo de l\'arrière',
    description: 'Pensez à montrer l\'arrière, utile pour rassurer l\'acheteur.',
  );

  static const overhead = PhotoTip(
    iconKey: 'expand',
    title: 'Photo en hauteur',
    description:
        'Une vue en plongée aide à montrer les proportions et l\'environnement.',
  );

  static const defects = PhotoTip(
    iconKey: 'report_problem',
    title: 'Montrez les défauts',
    description:
        'Photographiez rayures, taches ou usures de près : la transparence accélère la vente.',
  );

  static const accessories = PhotoTip(
    iconKey: 'inventory_2',
    title: 'Accessoires inclus',
    description: 'Regroupez tout ce qui est fourni avec l\'objet sur une photo.',
  );

  static const avoidBlurry = PhotoTip(
    iconKey: 'do_not_disturb_on',
    title: 'Évitez le flou',
    description:
        'Tenez le téléphone à deux mains et attendez la mise au point. Pas de photo sombre.',
  );
}
