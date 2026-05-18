import 'package:flutter/material.dart';

import '../widgets/placeholder_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Réglages',
      subtitle: 'Compte, langue, déconnexion (lot 3).',
    );
  }
}
