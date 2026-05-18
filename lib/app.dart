import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'ui/router.dart';

class PostellaApp extends ConsumerStatefulWidget {
  const PostellaApp({super.key});

  @override
  ConsumerState<PostellaApp> createState() => _PostellaAppState();
}

class _PostellaAppState extends ConsumerState<PostellaApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Postella',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
