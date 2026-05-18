import 'package:flutter_test/flutter_test.dart';
import 'package:postella/application/generation_controller.dart';
import 'package:postella/domain/categories/category.dart';
import 'package:postella/domain/categories/fashion.dart';
import 'package:postella/domain/generation/ad_generator.dart';
import 'package:postella/domain/models/ad_draft.dart';
import 'package:postella/domain/models/generated_ad.dart';
import 'package:postella/domain/models/plan.dart';
import 'package:postella/domain/models/quota.dart';
import 'package:postella/domain/models/quota_decision.dart';
import 'package:postella/infrastructure/supabase/quota_repository.dart';

/// QuotaRepository factice : compte les appels à `consume` et retourne
/// la décision configurée. Implémente l'interface, ignore le SupabaseClient.
class _RecordingQuotaRepo implements QuotaRepository {
  _RecordingQuotaRepo({this.willAllow = true});

  final bool willAllow;
  int consumeCalls = 0;

  @override
  Future<QuotaDecision> consume(GenerationMode mode) async {
    consumeCalls++;
    return QuotaDecision(
      allowed: willAllow,
      reason: willAllow
          ? RefusalReason.none
          : RefusalReason.freeDailyExhausted,
      suggestedAction:
          willAllow ? SuggestedAction.proceed : SuggestedAction.useTrial,
    );
  }

  @override
  Future<Quota> fetchToday() => throw UnimplementedError();
}

class _RecordingGenerator implements AdGenerator {
  int callCount = 0;

  @override
  Future<GeneratedAd> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    callCount++;
    return const GeneratedAd(
      title: 'Test title',
      description: 'Test description',
      suggestedPrice: 10,
    );
  }
}

void main() {
  const draft = AdDraft(
    categoryId: 'fashion',
    details: {'brand': 'Zara', 'size': 'M', 'condition': 'good'},
  );

  group('GenerationController — bypass quota dev', () {
    test(
      'bypassQuota=true : consume_quota n\'est PAS appelé, generator l\'est',
      () async {
        final quota = _RecordingQuotaRepo(willAllow: false);
        final gen = _RecordingGenerator();
        final controller = GenerationController(
          quotaRepo: quota,
          generator: gen,
          bypassQuota: true,
        );

        await controller.generate(draft: draft, category: fashionCategory);

        expect(quota.consumeCalls, 0, reason: 'le quota ne doit jamais être consommé en bypass dev');
        expect(gen.callCount, 1);
        expect(controller.state, isA<GenerationDone>());
        expect(
          (controller.state as GenerationDone).result.title,
          'Test title',
        );
      },
    );

    test(
      'bypassQuota=true : même si quota refuserait, on génère quand même',
      () async {
        // Sanity : le bypass ignore explicitement le refus, sans même appeler
        // la RPC. Garde-fou pour s'assurer qu'on ne lit pas accidentellement
        // la décision.
        final quota = _RecordingQuotaRepo(willAllow: false);
        final gen = _RecordingGenerator();
        final controller = GenerationController(
          quotaRepo: quota,
          generator: gen,
          bypassQuota: true,
        );

        await controller.generate(draft: draft, category: fashionCategory);

        expect(controller.state, isA<GenerationDone>());
        expect(controller.state, isNot(isA<GenerationRefused>()));
      },
    );
  });

  group('GenerationController — comportement normal (bypass off)', () {
    test('bypassQuota=false + quota OK : consume_quota appelé puis génération', () async {
      final quota = _RecordingQuotaRepo();
      final gen = _RecordingGenerator();
      final controller = GenerationController(
        quotaRepo: quota,
        generator: gen,
        bypassQuota: false,
      );

      await controller.generate(draft: draft, category: fashionCategory);

      expect(quota.consumeCalls, 1);
      expect(gen.callCount, 1);
      expect(controller.state, isA<GenerationDone>());
    });

    test('bypassQuota=false + quota refusé : generator NON appelé, state Refused', () async {
      final quota = _RecordingQuotaRepo(willAllow: false);
      final gen = _RecordingGenerator();
      final controller = GenerationController(
        quotaRepo: quota,
        generator: gen,
        bypassQuota: false,
      );

      await controller.generate(draft: draft, category: fashionCategory);

      expect(quota.consumeCalls, 1);
      expect(gen.callCount, 0, reason: 'pas de génération si quota refuse');
      expect(controller.state, isA<GenerationRefused>());
    });

    test('default (bypass non spécifié) : comportement normal', () async {
      final quota = _RecordingQuotaRepo();
      final gen = _RecordingGenerator();
      final controller = GenerationController(
        quotaRepo: quota,
        generator: gen,
      );

      await controller.generate(draft: draft, category: fashionCategory);

      expect(quota.consumeCalls, 1, reason: 'default bypassQuota=false');
      expect(gen.callCount, 1);
    });
  });
}
