import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/placeholder_scaffold.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Onboarding',
      subtitle: 'Bientôt : 3 slides expliquant Postella.',
      actions: [
        PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.go(AppRoutes.signIn),
        ),
      ],
    );
  }
}
