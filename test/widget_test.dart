import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:postella/app.dart';

void main() {
  testWidgets('App boots with splash branding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PostellaApp()));
    await tester.pump();
    expect(find.text('Postella'), findsOneWidget);
    // Laisser le timer du splash s'écouler avant la fin du test pour éviter
    // les "pending timer" qui font échouer le runner.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
