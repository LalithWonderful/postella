import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/categories/catalog.dart';
import '../../domain/categories/field_spec.dart';
import '../../domain/models/ad.dart';
import '../router.dart';
import '../widgets/ad_photo.dart';

class AdDetailPage extends ConsumerWidget {
  const AdDetailPage({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAdsProvider);
    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (ads) {
          final ad = ads.where((a) => a.id == adId).firstOrNull;
          if (ad == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48),
                    const SizedBox(height: 12),
                    const Text('Annonce introuvable'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Retour aux annonces'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _AdDetail(ad: ad);
        },
      ),
    );
  }
}

class _AdDetail extends StatelessWidget {
  const _AdDetail({required this.ad});

  final Ad ad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = kCatalog.firstWhere(
      (c) => c.id == ad.categoryId,
      orElse: () => kCatalog.last,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (ad.photos.isNotEmpty) ...[
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdPhoto(storagePath: ad.photos.first),
            ),
          ),
          if (ad.photos.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ad.photos.length - 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: AdPhoto(storagePath: ad.photos[i + 1]),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
        Text(
          category.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ad.title ?? category.label,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (ad.suggestedPrice != null) ...[
          const SizedBox(height: 6),
          Text(
            _formatPrice(ad.suggestedPrice!),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (ad.description != null) ...[
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
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: ad.description!),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Description copiée.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copier'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(ad.description!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
        if (ad.details.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Informations',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final field in category.allFields)
            if (ad.details[field.id] != null)
              _DetailRow(
                label: field.label,
                value: _renderValue(field, ad.details[field.id] as Object),
              ),
        ],
      ],
    );
  }

  String _renderValue(FieldSpec field, Object raw) {
    if (raw is List) {
      return raw
          .map((v) => _labelForSpec(field, v.toString()) ?? v.toString())
          .join(', ');
    }
    if (raw is bool) return raw ? 'Oui' : 'Non';
    final base = _labelForSpec(field, raw.toString()) ?? raw.toString();
    return field.unit != null ? '$base ${field.unit}' : base;
  }

  String? _labelForSpec(FieldSpec field, String value) {
    final opts = field.options;
    if (opts == null) return null;
    for (final o in opts) {
      if (o.value == value) return o.label;
    }
    return null;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
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
