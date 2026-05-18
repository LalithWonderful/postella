import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Ajouter des photos',
      subtitle: 'image_picker + conseils photo par catégorie (lot 4).',
      actions: [
        PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.push(AppRoutes.createDetails),
        ),
      ],
    );
  }
}
