import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_bootstrap.dart';

/// Upload et lecture des photos d'annonces dans le bucket privé `ad-photos`.
///
/// Convention de path : `<user_id>/<ad_id>/<index>.<ext>` — la RLS du bucket
/// exige que le premier segment du path soit l'`auth.uid()` du caller.
class StorageRepository {
  StorageRepository(this._client);

  factory StorageRepository.fromSupabase() => StorageRepository(supabase);

  static const _bucket = 'ad-photos';

  final SupabaseClient _client;

  /// Upload un fichier local. Retourne le `path` interne au bucket
  /// (à stocker dans `ads.photos`).
  Future<String> uploadAdPhoto({
    required String adId,
    required int index,
    required File file,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final ext = file.path.split('.').last.toLowerCase();
    final path = '$userId/$adId/$index.$ext';
    await _client.storage.from(_bucket).upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    return path;
  }

  /// Génère une URL temporaire signée pour afficher une photo. Durée par
  /// défaut : 1 heure.
  Future<String> signedUrl(String path, {Duration ttl = const Duration(hours: 1)}) {
    return _client.storage.from(_bucket).createSignedUrl(path, ttl.inSeconds);
  }

  Future<void> delete(List<String> paths) async {
    if (paths.isEmpty) return;
    await _client.storage.from(_bucket).remove(paths);
  }
}
