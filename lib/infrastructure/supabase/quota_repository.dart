import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/plan.dart';
import '../../domain/models/quota.dart';
import '../../domain/models/quota_decision.dart';
import 'supabase_bootstrap.dart';

/// Accès à la table `quotas` et à la RPC serveur `consume_quota`.
///
/// La RPC est la source de vérité — le client lit `quotas` pour afficher
/// l'état (jauge) mais n'incrémente jamais directement.
class QuotaRepository {
  QuotaRepository(this._client);

  factory QuotaRepository.fromSupabase() => QuotaRepository(supabase);

  final SupabaseClient _client;

  /// Récupère le compteur du jour. Retourne une `Quota` vide si la ligne
  /// n'existe pas encore (l'utilisateur n'a rien généré aujourd'hui).
  Future<Quota> fetchToday() async {
    final userId = _client.auth.currentUser!.id;
    final today = DateTime.now().toUtc();
    final dateStr =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final row = await _client
        .from('quotas')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();
    if (row == null) {
      return Quota.empty(userId: userId, date: DateTime.parse(dateStr));
    }
    return Quota.fromJson(row);
  }

  /// Décrémente atomiquement le quota côté serveur. C'est ici que la décision
  /// faisant autorité est prise — pas dans `QuotaPolicy` côté client.
  Future<QuotaDecision> consume(GenerationMode mode) async {
    final modeStr = switch (mode) {
      GenerationMode.free => 'free',
      GenerationMode.premium => 'premium',
    };
    final raw = await _client.rpc<Map<String, dynamic>>(
      'consume_quota',
      params: {'p_mode': modeStr},
    );
    return QuotaDecision(
      allowed: raw['allowed'] as bool,
      reason: _reasonFromString(raw['reason'] as String),
      suggestedAction: _actionFromString(raw['suggested_action'] as String),
      consumesTrial: (raw['consumes_trial'] as bool?) ?? false,
    );
  }

  RefusalReason _reasonFromString(String s) => switch (s) {
    'none' => RefusalReason.none,
    'freeDailyExhausted' => RefusalReason.freeDailyExhausted,
    'premiumDailyTextExhausted' => RefusalReason.premiumDailyTextExhausted,
    'premiumDailyImageExhausted' => RefusalReason.premiumDailyImageExhausted,
    'premiumTrialAlreadyUsed' => RefusalReason.premiumTrialAlreadyUsed,
    'premiumRequiresUpgrade' => RefusalReason.premiumRequiresUpgrade,
    _ => RefusalReason.none,
  };

  SuggestedAction _actionFromString(String s) => switch (s) {
    'proceed' => SuggestedAction.proceed,
    'useTrial' => SuggestedAction.useTrial,
    'upgradeToPremium' => SuggestedAction.upgradeToPremium,
    'comeBackTomorrow' => SuggestedAction.comeBackTomorrow,
    _ => SuggestedAction.proceed,
  };
}
