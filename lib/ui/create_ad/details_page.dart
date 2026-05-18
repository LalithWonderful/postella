import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Informations',
      subtitle: 'Formulaire dynamique depuis les FieldSpec (lot 4).',
      actions: [
        PrimaryButton(
          label: 'Générer l\'annonce',
          onPressed: () => context.push(AppRoutes.createGenerating),
        ),
      ],
    );
  }
}
