import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../domain/generation/ad_generator.dart';
import '../domain/models/ad.dart';
import '../infrastructure/generation/gemini_ad_generator.dart';
import '../infrastructure/generation/mock_ad_generator.dart';
import '../infrastructure/supabase/ads_repository.dart';
import '../infrastructure/supabase/auth_repository.dart';
import '../infrastructure/supabase/profile_repository.dart';
import '../infrastructure/supabase/quota_repository.dart';
import '../infrastructure/supabase/storage_repository.dart';

/// Racine des providers Riverpod : un seul endroit pour câbler les
/// repositories. Les écrans/contrôleurs lisent depuis ici, jamais
/// directement le SDK Supabase.

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository.fromSupabase(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (_) => ProfileRepository.fromSupabase(),
);

final adsRepositoryProvider = Provider<AdsRepository>(
  (_) => AdsRepository.fromSupabase(),
);

final quotaRepositoryProvider = Provider<QuotaRepository>(
  (_) => QuotaRepository.fromSupabase(),
);

final storageRepositoryProvider = Provider<StorageRepository>(
  (_) => StorageRepository.fromSupabase(),
);

/// Stream d'événements d'auth Supabase — déclenche les rebuilds quand
/// l'utilisateur se connecte/déconnecte.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

/// Session courante (null si déconnecté). Snapshot, pas Stream.
final currentSessionProvider = Provider<Session?>((ref) {
  // S'abonner au stream pour rebuild à chaque changement.
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).currentSession;
});

/// Annonces de l'utilisateur courant, les plus récentes d'abord.
/// `ref.invalidate(myAdsProvider)` après création/suppression pour refresh.
final myAdsProvider = FutureProvider<List<Ad>>((ref) {
  // Se ré-évalue à chaque changement de session (login / logout).
  ref.watch(currentSessionProvider);
  return ref.watch(adsRepositoryProvider).listMine();
});

/// URL signée pour afficher une photo stockée dans le bucket privé.
/// Les URLs ne sont jamais persistées — toujours générées à la demande.
final signedPhotoUrlProvider =
    FutureProvider.family<String, String>((ref, path) {
  return ref.watch(storageRepositoryProvider).signedUrl(path);
});

/// Moteur de génération d'annonces effectif :
/// - [GeminiAdGenerator] si `GEMINI_API_KEY` est compilée dans le build
///   (`--dart-define-from-file=env.json`)
/// - [MockAdGenerator] sinon — dev local sans clé, ou fallback silencieux
///   quand Gemini retourne une réponse inexploitable.
///
/// Le mock simule une latence pour rendre l'écran "Génération en cours…"
/// lisible quand on est en mode dev sans clé. Quand il sert de fallback à
/// Gemini, la latence n'est plus utile (on injecte un mock instantané dans
/// `GeminiAdGenerator.fallback`).
final adGeneratorProvider = Provider<AdGenerator>((_) {
  const mockFallback = MockAdGenerator();
  if (kDebugMode) {
    // Diagnostic : on imprime la PRÉSENCE et la LONGUEUR de la clé, jamais
    // sa valeur. Si keyLength=0 ici, c'est que `--dart-define-from-file=env.json`
    // n'a pas été passé au lancement (ou que la clé a un autre nom dans le JSON).
    debugPrint(
      '[adGeneratorProvider] hasGemini=${Env.hasGemini} '
      'geminiKeyLength=${Env.geminiApiKey.length} '
      'hasSupabase=${Env.hasSupabase}',
    );
  }
  if (!Env.hasGemini) {
    if (kDebugMode) {
      debugPrint('[adGeneratorProvider] → MockAdGenerator (pas de clé Gemini)');
    }
    return const MockAdGenerator(simulatedLatency: Duration(milliseconds: 1200));
  }
  if (kDebugMode) {
    debugPrint('[adGeneratorProvider] → GeminiAdGenerator');
  }
  return GeminiAdGenerator(
    apiKey: Env.geminiApiKey,
    fallback: mockFallback,
  );
});
