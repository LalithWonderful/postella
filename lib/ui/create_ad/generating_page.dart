import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/create_ad_controller.dart';
import '../../application/generation_controller.dart';
import '../../domain/categories/catalog.dart';
import '../../domain/models/quota_decision.dart';
import '../router.dart';
import '../widgets/primary_button.dart';

class GeneratingPage extends ConsumerStatefulWidget {
  const GeneratingPage({super.key});

  @override
  ConsumerState<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends ConsumerState<GeneratingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final draft = ref.read(createAdControllerProvider);
    final categoryId = draft.categoryId;
    if (categoryId == null) {
      context.go(AppRoutes.createCategory);
      return;
    }
    final category = kCatalog.firstWhere((c) => c.id == categoryId);
    final controller = ref.read(generationControllerProvider.notifier);
    controller.reset();
    await controller.generate(draft: draft, category: category);
    if (!mounted) return;
    final state = ref.read(generationControllerProvider);
    if (state is GenerationDone) {
      context.go(AppRoutes.createResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generationControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (state) {
            GenerationIdle() || GenerationLoading() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Génération en cours…',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Postella analyse les informations pour rédiger ton annonce.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GenerationRefused(:final decision) => _ErrorView(
              title: 'Génération non autorisée',
              message: _refusalMessage(decision),
            ),
            GenerationFailure(:final message) => _ErrorView(
              title: 'Erreur',
              message: message,
            ),
            GenerationDone() => const Center(
              child: CircularProgressIndicator(),
            ),
          },
        ),
      ),
    );
  }

  String _refusalMessage(QuotaDecision d) {
    return switch (d.suggestedAction) {
      SuggestedAction.comeBackTomorrow =>
        'Tu as utilisé toutes tes générations du jour. Reviens demain.',
      SuggestedAction.upgradeToPremium =>
        'Passe Premium pour générer plus d\'annonces aujourd\'hui.',
      SuggestedAction.useTrial =>
        'Tu as utilisé tes générations gratuites. Essaie ta génération Premium offerte.',
      SuggestedAction.proceed => 'Génération refusée.',
    };
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Retour',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}
