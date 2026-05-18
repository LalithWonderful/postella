import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/categories/catalog.dart';
import '../../domain/models/ad.dart';
import '../router.dart';
import '../widgets/ad_photo.dart';

class AdsListPage extends ConsumerWidget {
  const AdsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'Impossible de charger les annonces.\n$e',
          onRetry: () => ref.invalidate(myAdsProvider),
        ),
        data: (ads) {
          if (ads.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myAdsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: ads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _AdTile(
                ad: ads[i],
                onTap: () => context.push('/ads/${ads[i].id}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createCategory),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer une annonce'),
      ),
    );
  }
}

class _AdTile extends StatelessWidget {
  const _AdTile({required this.ad, required this.onTap});

  final Ad ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = ad.categoryId.isNotEmpty
        ? kCatalog.firstWhere(
            (c) => c.id == ad.categoryId,
            orElse: () => kCatalog.last,
          )
        : kCatalog.last;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ad.photos.isEmpty
                      ? ColoredBox(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : AdPhoto(storagePath: ad.photos.first),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title ?? category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (ad.suggestedPrice != null)
                      Text(
                        _formatPrice(ad.suggestedPrice!),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price <= 0) return '—';
  final isWhole = price == price.roundToDouble();
  return isWhole
      ? '${price.toStringAsFixed(0)} €'
      : '${price.toStringAsFixed(2)} €';
}
