import 'package:freezed_annotation/freezed_annotation.dart';

part 'quota_decision.freezed.dart';

/// Raison de refus retournée par `QuotaPolicy`.
enum RefusalReason {
  none,
  freeDailyExhausted,
  premiumDailyTextExhausted,
  premiumDailyImageExhausted,
  premiumTrialAlreadyUsed,
  premiumRequiresUpgrade,
}

/// Action suggérée à l'utilisateur après la décision.
enum SuggestedAction {
  proceed,
  useTrial,
  upgradeToPremium,
  comeBackTomorrow,
}

/// Décision structurée renvoyée par `QuotaPolicy.decide`.
///
/// Si [allowed] vaut `true`, [reason] vaut [RefusalReason.none] et
/// [suggestedAction] vaut [SuggestedAction.proceed]. [consumesTrial] indique
/// que cette génération utilisera l'essai premium gratuit (une seule fois à
/// vie pour un user free).
@freezed
class QuotaDecision with _$QuotaDecision {
  const factory QuotaDecision({
    required bool allowed,
    required RefusalReason reason,
    required SuggestedAction suggestedAction,
    @Default(false) bool consumesTrial,
    String? message,
  }) = _QuotaDecision;
}
