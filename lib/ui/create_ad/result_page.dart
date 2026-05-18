import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/create_ad_controller.dart';
import '../../application/generation_controller.dart';
import '../../application/providers.dart';
import '../../domain/categories/catalog.dart';
import '../../domain/models/ad.dart';
import '../../domain/models/generated_ad.dart';
import '../router.dart';
import '../widgets/primary_button.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool _saving = false;
  String? _saveError;

  Future<void> _save(GeneratedAd result) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final user = ref.read(currentSessionProvider)?.user;
      if (user == null) {
        throw StateError('Session expirée, reconnecte-toi.');
      }
      final draft = ref.read(createAdControllerProvider);
      final categoryId = draft.categoryId;
      if (categoryId == null) {
        throw StateError('Catégorie manquante.');
      }

      final adsRepo = ref.read(adsRepositoryProvider);
      final storage = ref.read(storageRepositoryProvider);
      final now = DateTime.now().toUtc();

      // 1. Insert l'annonce sans photos — on a besoin de l'id généré côté
      // serveur pour fabriquer les chemins de storage.
      final initial = Ad(
        id: '',
        userId: user.id,
        categoryId: categoryId,
        title: result.title,
        description: result.description,
        suggestedPrice: result.suggestedPrice,
        condition: result.condition,
        photos: const [],
        details: draft.details,
        status: AdStatus.saved,
        generator: AdEngine.gemini,
        createdAt: now,
        updatedAt: now,
      );
      final created = await adsRepo.create(initial);

      // 2. Upload des fichiers locaux vers le bucket privé `ad-photos`. On
      // ne stocke que le storage path — les URLs signées sont générées au
      // moment de la lecture.
      final paths = <String>[];
      for (var i = 0; i < draft.photos.length; i++) {
        final path = await storage.uploadAdPhoto(
          adId: created.id,
          index: i,
          file: File(draft.photos[i]),
        );
        paths.add(path);
      }

      // 3. Mise à jour de l'annonce avec les paths uploadés.
      if (paths.isNotEmpty) {
        await adsRepo.update(
          created.copyWith(
            photos: paths,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }

      // Invalide la liste pour qu'elle reflète la nouvelle annonce.
      ref.invalidate(myAdsProvider);
      ref.read(createAdControllerProvider.notifier).reset();
      ref.read(generationControllerProvider.notifier).reset();

      if (!mounted) return;
      context.go(AppRoutes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce sauvegardée.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Description copiée.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(generationControllerProvider);
    final draft = ref.watch(createAdControllerProvider);

    if (genState is! GenerationDone) {
      // Si on arrive ici sans résultat (rechargement / état perdu), on
      // ramène l'utilisateur en début de wizard.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final result = genState.result;
    final category = draft.categoryId != null
        ? kCatalog.firstWhere((c) => c.id == draft.categoryId)
        : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonce générée'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _saving ? null : () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (category != null)
                    Text(
                      category.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    result.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(result.suggestedPrice),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Description',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _copy(result.description),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copier'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (result.improvementTips.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Pour aller plus loin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final tip in result.improvementTips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.tips_and_updates_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (_saveError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _saveError!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: PrimaryButton(
                label: _saving ? 'Sauvegarde…' : 'Sauvegarder l\'annonce',
                icon: _saving ? null : Icons.check_rounded,
                onPressed: _saving ? null : () => _save(result),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price <= 0) return '—';
    final isWhole = price == price.roundToDouble();
    return isWhole ? '${price.toStringAsFixed(0)} €' : '${price.toStringAsFixed(2)} €';
  }
}
