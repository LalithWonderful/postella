import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/env.dart';
import '../router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Si Supabase n'est pas configuré, on reste sur le splash plutôt que de
    // naviguer vers un écran qui crashera en lisant le client. Évite aussi
    // d'avoir à mocker tout l'arbre Riverpod en tests.
    if (!Env.hasSupabase) return;
    _timer = Timer(const Duration(milliseconds: 800), _decide);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _decide() {
    if (!mounted) return;
    final session = ref.read(currentSessionProvider);
    context.go(session != null ? AppRoutes.home : AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 48,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Postella',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vendez plus vite, plus simplement.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
