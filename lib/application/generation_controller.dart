import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// 1. Consomme le quota côté serveur (source de vérité).
/// 2. Délègue la rédaction au [AdGenerator] courant (Gemini ou mock).
/// 3. Expose l'état à l'UI (`GeneratingPage`, `ResultPage`).
class GenerationController extends StateNotifier<GenerationState> {
  GenerationController({
    required QuotaRepository quotaRepo,
    required AdGenerator generator,
  })  : _quotaRepo = quotaRepo,
        _generator = generator,
        super(const GenerationIdle());

  final QuotaRepository _quotaRepo;
  final AdGenerator _generator;

  Future<void> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    state = const GenerationLoading();
    try {
      final decision = await _quotaRepo.consume(GenerationMode.free);
      if (!decision.allowed) {
        state = GenerationRefused(decision);
        return;
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
      ),
    );
