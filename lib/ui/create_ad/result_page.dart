import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Annonce générée',
      subtitle: 'Titre / description / prix / copier / sauver (lot 4).',
      actions: [
        PrimaryButton(
          label: 'Retour à mes annonces',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
