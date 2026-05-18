import 'package:flutter/material.dart';

import '../widgets/placeholder_scaffold.dart';

class AdDetailPage extends StatelessWidget {
  const AdDetailPage({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Annonce',
      subtitle: 'Détail de l\'annonce $adId (lot 4).',
    );
  }
}
