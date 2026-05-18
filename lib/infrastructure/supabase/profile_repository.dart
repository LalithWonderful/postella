import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/profile.dart';
import 'supabase_bootstrap.dart';

/// Lecture/écriture sur la table `profiles`.
class ProfileRepository {
  ProfileRepository(this._client);

  factory ProfileRepository.fromSupabase() => ProfileRepository(supabase);

  final SupabaseClient _client;

  /// Renvoie le profil de l'utilisateur courant.
  ///
  /// Le profil est créé automatiquement par le trigger SQL `handle_new_user`
  /// au signup. Si pour une raison quelconque il n'existe pas, retourne null.
  Future<Profile?> fetchCurrent() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row);
  }
}
