import 'package:flutter_test/flutter_test.dart';
import 'package:postella/domain/models/plan.dart';
import 'package:postella/domain/models/profile.dart';
import 'package:postella/domain/models/quota.dart';
import 'package:postella/domain/models/quota_decision.dart';
import 'package:postella/domain/quota_limits.dart';
import 'package:postella/domain/quota_policy.dart';

void main() {
  const policy = QuotaPolicy();
  final today = DateTime(2026, 5, 18);

  Profile profile({
    Plan plan = Plan.free,
    bool trialUsed = false,
  }) => Profile(
    id: 'u1',
    email: 'u1@test.fr',
    plan: plan,
    premiumTrialUsed: trialUsed,
    createdAt: today,
  );

  Quota quota({int free = 0, int premium = 0}) => Quota(
    userId: 'u1',
    date: today,
    freeGenerationsUsed: free,
    premiumGenerationsUsed: premium,
  );

  group('free user, free generation', () {
    test('autorise les 2 premières du jour', () {
      final d = policy.decide(
        profile: profile(),
        today: quota(),
        mode: GenerationMode.free,
      );
      expect(d.allowed, isTrue);
      expect(d.reason, RefusalReason.none);
      expect(d.suggestedAction, SuggestedAction.proceed);
      expect(d.consumesTrial, isFalse);
    });

    test('refuse la 3e et propose le trial premium si non utilisé', () {
      final d = policy.decide(
        profile: profile(),
        today: quota(free: QuotaLimits.freeDailyText),
        mode: GenerationMode.free,
      );
      expect(d.allowed, isFalse);
      expect(d.reason, RefusalReason.freeDailyExhausted);
      expect(d.suggestedAction, SuggestedAction.useTrial);
    });

    test('refuse la 3e et propose upgrade si trial déjà consommé', () {
      final d = policy.decide(
        profile: profile(trialUsed: true),
        today: quota(free: QuotaLimits.freeDailyText),
        mode: GenerationMode.free,
      );
      expect(d.allowed, isFalse);
      expect(d.reason, RefusalReason.freeDailyExhausted);
      expect(d.suggestedAction, SuggestedAction.upgradeToPremium);
    });
  });

  group('free user, premium generation', () {
    test('autorise une fois si trial non utilisé et marque consumesTrial', () {
      final d = policy.decide(
        profile: profile(),
        today: quota(),
        mode: GenerationMode.premium,
      );
      expect(d.allowed, isTrue);
      expect(d.consumesTrial, isTrue);
      expect(d.suggestedAction, SuggestedAction.proceed);
    });

    test('refuse si trial déjà utilisé et propose upgrade', () {
      final d = policy.decide(
        profile: profile(trialUsed: true),
        today: quota(),
        mode: GenerationMode.premium,
      );
      expect(d.allowed, isFalse);
      expect(d.reason, RefusalReason.premiumRequiresUpgrade);
      expect(d.suggestedAction, SuggestedAction.upgradeToPremium);
    });
  });

  group('premium user, free generation (Gemini)', () {
    test('autorise tant que < ${QuotaLimits.premiumDailyText} du jour', () {
      final d = policy.decide(
        profile: profile(plan: Plan.premium),
        today: quota(free: QuotaLimits.premiumDailyText - 1),
        mode: GenerationMode.free,
      );
      expect(d.allowed, isTrue);
    });

    test('refuse au-delà et propose comeBackTomorrow', () {
      final d = policy.decide(
        profile: profile(plan: Plan.premium),
        today: quota(free: QuotaLimits.premiumDailyText),
        mode: GenerationMode.free,
      );
      expect(d.allowed, isFalse);
      expect(d.reason, RefusalReason.premiumDailyTextExhausted);
      expect(d.suggestedAction, SuggestedAction.comeBackTomorrow);
    });
  });

  group('premium user, premium generation (OpenAI)', () {
    test('autorise tant que < ${QuotaLimits.premiumDailyImage} du jour', () {
      final d = policy.decide(
        profile: profile(plan: Plan.premium),
        today: quota(premium: QuotaLimits.premiumDailyImage - 1),
        mode: GenerationMode.premium,
      );
      expect(d.allowed, isTrue);
      expect(d.consumesTrial, isFalse);
    });

    test('refuse au-delà et propose comeBackTomorrow', () {
      final d = policy.decide(
        profile: profile(plan: Plan.premium),
        today: quota(premium: QuotaLimits.premiumDailyImage),
        mode: GenerationMode.premium,
      );
      expect(d.allowed, isFalse);
      expect(d.reason, RefusalReason.premiumDailyImageExhausted);
      expect(d.suggestedAction, SuggestedAction.comeBackTomorrow);
    });
  });

  test('aucun chemin "illimité" — toutes les combinaisons ont un plafond', () {
    // Sanity : un user premium qui a tout consommé reçoit toujours un refus.
    final freeExhausted = policy.decide(
      profile: profile(plan: Plan.premium),
      today: quota(free: 9999),
      mode: GenerationMode.free,
    );
    final premiumExhausted = policy.decide(
      profile: profile(plan: Plan.premium),
      today: quota(premium: 9999),
      mode: GenerationMode.premium,
    );
    expect(freeExhausted.allowed, isFalse);
    expect(premiumExhausted.allowed, isFalse);
  });
}
