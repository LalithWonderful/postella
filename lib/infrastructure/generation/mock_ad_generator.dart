import '../../domain/categories/category.dart';
import '../../domain/categories/field_spec.dart';
import '../../domain/generation/ad_generator.dart';
import '../../domain/models/ad_draft.dart';
import '../../domain/models/generated_ad.dart';

/// Génération entièrement locale et déterministe à partir des champs saisis.
///
/// Utilisé :
/// - en dev quand aucune clé `GEMINI_API_KEY` n'est fournie
/// - comme fallback du [GeminiAdGenerator] quand la réponse de Gemini est
///   inexploitable (JSON invalide / champs manquants)
class MockAdGenerator implements AdGenerator {
  const MockAdGenerator({this.simulatedLatency = Duration.zero});

  /// Délai factice ajouté avant de retourner — utile pour rendre l'écran
  /// "Génération en cours…" lisible. Le contrôleur ne l'utilise pas en
  /// fallback (où la réactivité prime).
  final Duration simulatedLatency;

  @override
  Future<GeneratedAd> generate({
    required AdDraft draft,
    required Category category,
  }) async {
    if (simulatedLatency > Duration.zero) {
      await Future<void>.delayed(simulatedLatency);
    }
    return buildMockAd(draft: draft, category: category);
  }

  /// Exposé pour les tests : version synchrone, déterministe.
  static GeneratedAd buildMockAd({
    required AdDraft draft,
    required Category category,
  }) {
    final d = draft.details;
    return GeneratedAd(
      title: _composeTitle(category, d),
      description: _composeDescription(category, d, draft.photos.length),
      suggestedPrice: _composePrice(d),
      condition: d['condition'] as String?,
      improvementTips: _composeTips(category, draft, d),
    );
  }
}

double _composePrice(Map<String, dynamic> d) {
  return _asDouble(d['asking_price']) ??
      _asDouble(d['monthly_payment']) ??
      _asDouble(d['transfer_fee_requested']) ??
      0;
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
