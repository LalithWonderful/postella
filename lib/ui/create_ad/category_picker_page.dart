import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class CategoryPickerPage extends StatelessWidget {
  const CategoryPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Choisir une catégorie',
      subtitle: 'Catalogue des 9 catégories MVP (lot 2).',
      actions: [
        PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.push(AppRoutes.createPhotos),
        ),
      ],
    );
  }
}
