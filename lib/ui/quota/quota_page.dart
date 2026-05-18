import 'package:flutter/material.dart';

import '../widgets/placeholder_scaffold.dart';

class QuotaPage extends StatelessWidget {
  const QuotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Quotas',
      subtitle:
          'Affichera le compteur du jour et l\'accès premium (lot 3 / lot 5).',
    );
  }
}
