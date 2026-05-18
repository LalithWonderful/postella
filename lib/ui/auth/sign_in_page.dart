import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Connexion',
      subtitle: 'Email + Google + Apple Sign-In (lot 3).',
      actions: [
        PrimaryButton(
          label: 'Continuer vers l\'app',
          onPressed: () => context.go(AppRoutes.home),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go(AppRoutes.signUp),
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}
