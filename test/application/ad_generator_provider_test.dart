import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postella/application/providers.dart';
import 'package:postella/core/env.dart';
import 'package:postella/infrastructure/generation/mock_ad_generator.dart';

void main() {
  test(
    'adGeneratorProvider retourne MockAdGenerator quand GEMINI_API_KEY est absente',
    () {
      // En test, aucun `--dart-define=GEMINI_API_KEY=...` n'est passé : on
      // s'attend donc systématiquement au mock. Si quelqu'un casse cette
      // invariant en ajoutant une clé via test_args, le test signalera.
      expect(Env.hasGemini, isFalse);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final generator = container.read(adGeneratorProvider);
      expect(generator, isA<MockAdGenerator>());
    },
  );
}
