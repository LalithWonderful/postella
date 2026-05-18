import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:postella/app.dart';

void main() {
  testWidgets('App boots with splash branding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PostellaApp()));
    // Une seule frame : on vérifie le rendu du splash, sans laisser le
    // timer déclencher la navigation (qui dépend de Supabase initialisé).
    await tester.pump();
    expect(find.text('Postella'), findsOneWidget);
    expect(find.text('Vendez plus vite, plus simplement.'), findsOneWidget);
  });
}
