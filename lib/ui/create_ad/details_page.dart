import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/create_ad_controller.dart';
import '../../domain/categories/catalog.dart';
import '../../domain/categories/category.dart';
import '../router.dart';
import '../widgets/dynamic_field.dart';
import '../widgets/primary_button.dart';

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({super.key});

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit(Category category) {
    if (!_formKey.currentState!.validate()) return;
    context.push(AppRoutes.createGenerating);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createAdControllerProvider);
    final categoryId = draft.categoryId;
    if (categoryId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.createCategory);
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final category = kCatalog.firstWhere((c) => c.id == categoryId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Quelques informations',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plus tu en donnes, meilleure sera l\'annonce générée.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final spec in category.requiredFields) ...[
                      DynamicField(
                        spec: spec,
                        value: draft.details[spec.id],
                        onChanged: (v) => ref
                            .read(createAdControllerProvider.notifier)
                            .setField(spec.id, v),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (category.optionalFields.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Optionnel',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final spec in category.optionalFields) ...[
                        DynamicField(
                          spec: spec,
                          value: draft.details[spec.id],
                          onChanged: (v) => ref
                              .read(createAdControllerProvider.notifier)
                              .setField(spec.id, v),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (category.pricingHints.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  size: 18,
                                  color:
                                      theme.colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Conseils tarifs',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme
                                        .colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (final hint in category.pricingHints)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $hint',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme
                                        .colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: PrimaryButton(
                label: 'Générer l\'annonce',
                onPressed: () => _submit(category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
