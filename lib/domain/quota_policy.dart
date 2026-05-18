import 'models/plan.dart';
import 'models/profile.dart';
import 'models/quota.dart';
import 'models/quota_decision.dart';
import 'quota_limits.dart';

/// Logique pure côté client pour anticiper la décision de quota.
///
/// **Important** : cette logique est uniquement informative. La décision
/// faisant autorité est prise côté serveur par la RPC Supabase
/// `consume_quota` (lot 3), qui incrémente atomiquement les compteurs.
/// Le client ne doit jamais s'auto-autoriser une génération.
class QuotaPolicy {
  const QuotaPolicy();

  /// Décide si [mode] est autorisé pour [profile] sachant que [today]
  /// reflète l'état des compteurs du jour courant.
  QuotaDecision decide({
    required Profile profile,
    required Quota today,
    required GenerationMode mode,
  }) {
    switch (mode) {
      case GenerationMode.free:
        return _decideFree(profile: profile, today: today);
      case GenerationMode.premium:
        return _decidePremium(profile: profile, today: today);
    }
  }

  QuotaDecision _decideFree({required Profile profile, required Quota today}) {
    final limit = switch (profile.plan) {
      Plan.free => QuotaLimits.freeDailyText,
      Plan.premium => QuotaLimits.premiumDailyText,
    };

    if (today.freeGenerationsUsed < limit) {
      return const QuotaDecision(
        allowed: true,
        reason: RefusalReason.none,
        suggestedAction: SuggestedAction.proceed,
      );
    }

    // Quota gratuit du jour épuisé.
    if (profile.plan == Plan.free) {
      if (!profile.premiumTrialUsed) {
        return const QuotaDecision(
          allowed: false,
          reason: RefusalReason.freeDailyExhausted,
          suggestedAction: SuggestedAction.useTrial,
          message:
              'Vous avez utilisé vos 2 générations gratuites du jour. '
              'Essayez gratuitement la version premium une fois.',
        );
      }
      return const QuotaDecision(
        allowed: false,
        reason: RefusalReason.freeDailyExhausted,
        suggestedAction: SuggestedAction.upgradeToPremium,
        message:
            'Vous avez utilisé vos 2 générations gratuites du jour. '
            'Passez en premium pour continuer aujourd\'hui.',
      );
    }

    // Premium ayant épuisé son texte premium du jour.
    return const QuotaDecision(
      allowed: false,
      reason: RefusalReason.premiumDailyTextExhausted,
      suggestedAction: SuggestedAction.comeBackTomorrow,
      message:
          'Limite quotidienne premium texte atteinte. Réessayez demain.',
    );
  }

  QuotaDecision _decidePremium({
    required Profile profile,
    required Quota today,
  }) {
    if (profile.plan == Plan.free) {
      if (!profile.premiumTrialUsed) {
        return const QuotaDecision(
          allowed: true,
          reason: RefusalReason.none,
          suggestedAction: SuggestedAction.proceed,
          consumesTrial: true,
          message:
              'Essai premium gratuit — vous avez droit à une génération '
              'premium offerte. Profitez-en.',
        );
      }
      return const QuotaDecision(
        allowed: false,
        reason: RefusalReason.premiumRequiresUpgrade,
        suggestedAction: SuggestedAction.upgradeToPremium,
        message:
            'L\'essai premium a déjà été utilisé. Passez en premium pour '
            'continuer.',
      );
    }

    // Plan premium : quota journalier OpenAI.
    if (today.premiumGenerationsUsed < QuotaLimits.premiumDailyImage) {
      return const QuotaDecision(
        allowed: true,
        reason: RefusalReason.none,
        suggestedAction: SuggestedAction.proceed,
      );
    }
    return const QuotaDecision(
      allowed: false,
      reason: RefusalReason.premiumDailyImageExhausted,
      suggestedAction: SuggestedAction.comeBackTomorrow,
      message:
          'Limite quotidienne premium atteinte. Réessayez demain.',
    );
  }
}
