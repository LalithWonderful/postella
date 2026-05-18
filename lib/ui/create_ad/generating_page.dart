import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class GeneratingPage extends StatefulWidget {
  const GeneratingPage({super.key});

  @override
  State<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends State<GeneratingPage> {
  @override
  void initState() {
    super.initState();
    // Placeholder lot 1 : timer factice. Le vrai appel IA arrive au lot 5.
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(AppRoutes.createResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Génération en cours…',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
