import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class AdsListPage extends StatelessWidget {
  const AdsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune annonce pour le moment',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Touchez le bouton + pour en créer une.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createCategory),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer une annonce'),
      ),
    );
  }
}
