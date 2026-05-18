import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

/// Affiche une photo d'annonce stockée dans le bucket privé.
///
/// Demande une URL signée à la lecture — on ne persiste jamais d'URL.
class AdPhoto extends ConsumerWidget {
  const AdPhoto({
    super.key,
    required this.storagePath,
    this.fit = BoxFit.cover,
  });

  final String storagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(signedPhotoUrlProvider(storagePath));
    final theme = Theme.of(context);
    return async.when(
      data: (url) => Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => _Placeholder(
          icon: Icons.broken_image_outlined,
          color: theme.colorScheme.surfaceContainerHighest,
          iconColor: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      loading: () => _Placeholder(
        color: theme.colorScheme.surfaceContainerHighest,
        showSpinner: true,
      ),
      error: (_, _) => _Placeholder(
        icon: Icons.error_outline_rounded,
        color: theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.color,
    this.icon,
    this.iconColor,
    this.showSpinner = false,
  });

  final Color color;
  final IconData? icon;
  final Color? iconColor;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: iconColor),
      ),
    );
  }
}
