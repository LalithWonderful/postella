import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
