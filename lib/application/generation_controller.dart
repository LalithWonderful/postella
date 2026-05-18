import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../domain/categories/category.dart';
import '../domain/generation/ad_generator.dart';
import '../domain/models/ad_draft.dart';
import '../domain/models/generated_ad.dart';
import '../domain/models/plan.dart';
import '../domain/models/quota_decision.dart';
import '../infrastructure/supabase/quota_repository.dart';
import 'providers.dart';

/// État du job de génération courant.
sealed class GenerationState {
  const GenerationState();
}

class GenerationIdle extends GenerationState {
  const GenerationIdle();
}

class GenerationLoading extends GenerationState {
  const GenerationLoading();
}

class GenerationDone extends GenerationState {
  const GenerationDone(this.result);
  final GeneratedAd result;
}

class GenerationRefused extends GenerationState {
  const GenerationRefused(this.decision);
  final QuotaDecision decision;
}

class GenerationFailure extends GenerationState {
  const GenerationFailure(this.message);
  final String message;
}

/// Orchestre la génération :
/// 1. (Sauf bypass dev) consomme le quota côté serveur — source de vérité.
/// 2. Délègue la rédaction au [AdGenerator] courant (Gemini ou mock).
/// 3. Expose l'état à l'UI (`GeneratingPage`, `ResultPage`).
///
/// Le paramètre [bypassQuota] permet de court-circuiter l'étape 1 en dev,
/// sans toucher au serveur. Injecté depuis [Env.bypassQuotaForDev] par
/// le provider. Default `false` — les tests existants couvrent le
/// comportement normal sans avoir besoin du flag.
class GenerationController extends StateNotifier<GenerationState> {
  GenerationController({
    required QuotaRepository quotaRepo,
    required AdGenerator generator,
    this.bypassQuota = false,
  })  : _quotaRepo = quotaRepo,
        _generator = generator,
        super(const GenerationIdle());

  final QuotaRepository _quotaRepo;
  final AdGenerator _generator;
  final bool bypassQuota;

  Future<void> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    state = const GenerationLoading();
    try {
      if (bypassQuota) {
        if (kDebugMode) {
          debugPrint(
            '[Quota] bypass dev actif — consume_quota non appelé. '
            'À retirer en prod (Env.bypassQuotaForDev).',
          );
        }
      } else {
        final decision = await _quotaRepo.consume(GenerationMode.free);
        if (!decision.allowed) {
          state = GenerationRefused(decision);
          return;
        }
      }
      final ad = await _generator.generate(draft: draft, category: category);
      state = GenerationDone(ad);
    } on GenerationException catch (e) {
      state = GenerationFailure(e.message);
    } catch (e) {
      state = GenerationFailure(_humanize(e));
    }
  }

  void reset() => state = const GenerationIdle();

  String _humanize(Object e) => e.toString().replaceFirst('Exception: ', '');
}

final generationControllerProvider =
    StateNotifierProvider<GenerationController, GenerationState>(
      (ref) => GenerationController(
        quotaRepo: ref.watch(quotaRepositoryProvider),
        generator: ref.watch(adGeneratorProvider),
        bypassQuota: Env.bypassQuotaForDev,
      ),
    );
