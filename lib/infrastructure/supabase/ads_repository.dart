import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/ad.dart';
import 'supabase_bootstrap.dart';

/// CRUD sur la table `ads`. Les RLS limitent automatiquement aux annonces
/// de l'utilisateur courant.
class AdsRepository {
  AdsRepository(this._client);

  factory AdsRepository.fromSupabase() => AdsRepository(supabase);

  final SupabaseClient _client;

  /// Liste les annonces de l'utilisateur courant, les plus récentes d'abord.
  Future<List<Ad>> listMine() async {
    final rows = await _client
        .from('ads')
        .select()
        .order('created_at', ascending: false);
    return rows.map((r) => Ad.fromJson(r)).toList();
  }

  /// Crée une annonce. Retourne l'annonce avec son id généré.
  Future<Ad> create(Ad ad) async {
    final row = await _client
        .from('ads')
        .insert(_toInsert(ad))
        .select()
        .single();
    return Ad.fromJson(row);
  }

  /// Met à jour une annonce existante.
  Future<Ad> update(Ad ad) async {
    final row = await _client
        .from('ads')
        .update(_toInsert(ad))
        .eq('id', ad.id)
        .select()
        .single();
    return Ad.fromJson(row);
  }

  /// Supprime une annonce.
  Future<void> delete(String adId) async {
    await _client.from('ads').delete().eq('id', adId);
  }

  /// Sérialisation manuelle vers la forme attendue par Postgres : on retire
  /// `id` (auto-généré) et on n'envoie pas `created_at`/`updated_at`.
  Map<String, dynamic> _toInsert(Ad ad) {
    final json = ad.toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }
}
