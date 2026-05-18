import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/supabase/auth_repository.dart';
import 'providers.dart';

/// État d'une opération d'auth ponctuelle (sign in / sign up).
sealed class AuthOperationState {
  const AuthOperationState();
}

class AuthOperationIdle extends AuthOperationState {
  const AuthOperationIdle();
}

class AuthOperationLoading extends AuthOperationState {
  const AuthOperationLoading();
}

class AuthOperationSuccess extends AuthOperationState {
  const AuthOperationSuccess();
}

class AuthOperationFailure extends AuthOperationState {
  const AuthOperationFailure(this.message);
  final String message;
}

/// Contrôleur en charge des opérations d'auth (sign in / sign up / sign out)
/// et de l'exposition de leur état pour l'UI.
class AuthController extends StateNotifier<AuthOperationState> {
  AuthController(this._repo) : super(const AuthOperationIdle());

  final AuthRepository _repo;

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _repo.signIn(email: email, password: password));
  }

  Future<void> signUp({required String email, required String password}) {
    return _run(() => _repo.signUp(email: email, password: password));
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthOperationIdle();
  }

  void reset() => state = const AuthOperationIdle();

  Future<void> _run(Future<void> Function() op) async {
    state = const AuthOperationLoading();
    try {
      await op();
      state = const AuthOperationSuccess();
    } catch (e) {
      state = AuthOperationFailure(_humanize(e));
    }
  }

  String _humanize(Object e) {
    final msg = e.toString();
    // Les erreurs Supabase contiennent souvent du texte technique anglais.
    // On laisse passer le message brut en V1 — on traduira plus finement
    // une fois les cas d'usage observés.
    if (msg.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (msg.contains('already registered')) {
      return 'Un compte existe déjà avec cet email.';
    }
    if (msg.contains('Password should be at least')) {
      return 'Le mot de passe doit faire au moins 6 caractères.';
    }
    return msg.replaceFirst('Exception: ', '');
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthOperationState>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
    );
