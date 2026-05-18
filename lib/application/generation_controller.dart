import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/categories/category.dart';
import '../domain/categories/field_spec.dart';
import '../domain/models/ad_draft.dart';
import '../domain/models/generated_ad.dart';
import '../domain/models/plan.dart';
import '../domain/models/quota_decision.dart';
import '../infrastructure/supabase/quota_repository.dart';
import 'providers.dart';

/// État du job de génération courant (mocké en lot 4, Gemini réel au lot 5).
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

/// Pilote la génération de l'annonce.
///
/// En lot 4 : on consomme le quota côté serveur (`consume_quota`) puis on
/// fabrique un `GeneratedAd` mocké à partir des détails saisis. Le lot 5
/// remplacera le mock par un vrai appel Gemini sans changer cette interface.
class GenerationController extends StateNotifier<GenerationState> {
  GenerationController(this._quotaRepo) : super(const GenerationIdle());

  final QuotaRepository _quotaRepo;

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
      // Latence factice pour que l'écran "Génération en cours…" ait un sens
      // visuellement avant le vrai appel IA.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      state = GenerationDone(_mockGenerate(draft, category));
    } catch (e) {
      state = GenerationFailure(_humanize(e));
    }
  }

  void reset() => state = const GenerationIdle();

  String _humanize(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  /// Synthétise un titre / description / prix lisibles à partir des champs
  /// du draft. Volontairement simple : c'est un mock, le but est d'avoir un
  /// rendu plausible pour valider le parcours.
  GeneratedAd _mockGenerate(AdDraft draft, Category category) {
    final d = draft.details;

    final title = _composeTitle(category, d);
    final price = _asDouble(d['asking_price']) ??
        _asDouble(d['monthly_payment']) ??
        _asDouble(d['transfer_fee_requested']) ??
        0;
    final condition = d['condition'] as String?;

    final description = _composeDescription(category, d, draft.photos.length);

    return GeneratedAd(
      title: title,
      description: description,
      suggestedPrice: price,
      condition: condition,
      improvementTips: _composeTips(category, draft, d),
    );
  }

  double? _asDouble(Object? v) => v is num ? v.toDouble() : null;

  String _composeTitle(Category category, Map<String, dynamic> d) {
    final brand = d['brand'] as String?;
    final model = d['model'] as String?;
    final itemType = d['item_type'] as String?;
    final title = d['title'] as String?;
    final author = d['author'] as String?;
    final propertyType = d['property_type'] as String?;
    final city = d['city'] as String?;
    final surface = d['surface_sqm'];
    final rooms = d['rooms'];

    if (brand != null && model != null) return '$brand $model';
    if (title != null && author != null) return '$title — $author';
    if (propertyType != null && city != null && surface != null) {
      final r = rooms != null ? '$rooms pièces · ' : '';
      final typeLabel =
          _labelFor(category, 'property_type', propertyType) ?? propertyType;
      return '$typeLabel $r${surface}m² — $city';
    }
    if (itemType != null) {
      return brand != null ? '$itemType $brand' : itemType;
    }
    if (title != null) return title;
    return category.label;
  }

  String _composeDescription(
    Category category,
    Map<String, dynamic> d,
    int photoCount,
  ) {
    final buf = StringBuffer();
    buf.writeln('${category.label} — annonce générée par Postella.');
    buf.writeln();

    final entries = <String>[];
    for (final field in category.allFields) {
      final Object? raw = d[field.id];
      if (raw == null) continue;
      if (raw is String && raw.isEmpty) continue;
      final value = _renderValue(field, raw);
      entries.add('• ${field.label} : $value');
    }
    if (entries.isNotEmpty) {
      buf.writeAll(entries, '\n');
      buf.writeln();
      buf.writeln();
    }

    if (photoCount > 0) {
      buf.writeln('$photoCount photo${photoCount > 1 ? 's' : ''} disponibles.');
    }
    buf.write('À venir chercher sur place. Pas d\'envoi.');
    return buf.toString();
  }

  List<String> _composeTips(
    Category category,
    AdDraft draft,
    Map<String, dynamic> d,
  ) {
    final tips = <String>[];
    if (draft.photos.length < 3) {
      tips.add(
        'Ajoute au moins 3 photos sous différents angles pour rassurer les acheteurs.',
      );
    }
    final notes = d['notes'];
    if (notes == null || (notes is String && notes.isEmpty)) {
      tips.add(
        'Ajoute quelques notes personnelles : pourquoi tu vends, historique d\'utilisation, défauts éventuels.',
      );
    }
    if (category.pricingHints.isNotEmpty) {
      tips.add(category.pricingHints.first);
    }
    return tips;
  }

  String _renderValue(FieldSpec field, Object raw) {
    if (raw is List) {
      return raw
          .map((v) => _labelForSpec(field, v.toString()) ?? v.toString())
          .join(', ');
    }
    if (raw is bool) return raw ? 'Oui' : 'Non';
    return _labelForSpec(field, raw.toString()) ?? raw.toString();
  }

  String? _labelFor(Category category, String fieldId, String value) {
    for (final f in category.allFields) {
      if (f.id == fieldId) return _labelForSpec(f, value);
    }
    return null;
  }

  String? _labelForSpec(FieldSpec field, String value) {
    final opts = field.options;
    if (opts == null) return null;
    for (final o in opts) {
      if (o.value == value) return o.label;
    }
    return null;
  }
}

final generationControllerProvider =
    StateNotifierProvider<GenerationController, GenerationState>(
      (ref) => GenerationController(ref.watch(quotaRepositoryProvider)),
    );
