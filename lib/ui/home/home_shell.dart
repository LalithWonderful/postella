import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_TabSpec>[
    _TabSpec(
      route: AppRoutes.home,
      icon: Icons.list_alt_rounded,
      label: 'Annonces',
    ),
    _TabSpec(
      route: AppRoutes.quota,
      icon: Icons.bolt_rounded,
      label: 'Quotas',
    ),
    _TabSpec(
      route: AppRoutes.settings,
      icon: Icons.settings_rounded,
      label: 'Réglages',
    ),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.route,
    required this.icon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final String label;
}
