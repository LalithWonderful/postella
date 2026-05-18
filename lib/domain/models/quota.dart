import 'package:freezed_annotation/freezed_annotation.dart';

part 'quota.freezed.dart';
part 'quota.g.dart';

/// Compteur journalier de générations pour un utilisateur donné.
///
/// La clé primaire côté Supabase est `(user_id, date)`.
@freezed
class Quota with _$Quota {
  const factory Quota({
    required String userId,
    required DateTime date,
    @Default(0) int freeGenerationsUsed,
    @Default(0) int premiumGenerationsUsed,
  }) = _Quota;

  factory Quota.fromJson(Map<String, dynamic> json) => _$QuotaFromJson(json);

  /// État vide pour un utilisateur n'ayant encore rien généré aujourd'hui.
  factory Quota.empty({required String userId, required DateTime date}) =>
      Quota(userId: userId, date: date);
}
