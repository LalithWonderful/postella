import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_bootstrap.dart';

/// Façade fine au-dessus du client Auth Supabase.
///
/// Volontairement minimal : on expose ce dont l'app a besoin, on ne planque
/// pas le SDK derrière un wrapper bavard. Email/password seulement en V1 ;
/// Google + Apple arriveront en lot 3b.
class AuthRepository {
  AuthRepository(this._client);

  factory AuthRepository.fromSupabase() => AuthRepository(supabase);

  final SupabaseClient _client;

  /// Session courante (null si déconnecté).
  Session? get currentSession => _client.auth.currentSession;

  /// User courant (null si déconnecté).
  User? get currentUser => _client.auth.currentUser;

  /// Stream d'événements d'authentification — branché par AuthController.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Inscription email/password. Avec la confirmation email désactivée dans
  /// le dashboard, retourne une session immédiatement utilisable.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  /// Connexion email/password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Déconnexion.
  Future<void> signOut() => _client.auth.signOut();
}
