import 'dart:convert';

import '../../domain/models/ad_draft.dart';
import '../../domain/models/generated_ad.dart';

/// Exception levée par [parseGeminiAd] quand la réponse de Gemini est
/// inexploitable (JSON invalide, champs requis manquants…).
///
/// Le caller (`GeminiAdGenerator`) peut alors basculer sur un fallback
/// déterministe plutôt que de remonter une erreur à l'utilisateur.
class GeminiResponseException implements Exception {
  GeminiResponseException(this.reason);
  final String reason;

  @override
  String toString() => 'GeminiResponseException: $reason';
}

/// Parse le `text` retourné par Gemini (qui contient lui-même un JSON,
/// grâce à `responseMimeType: application/json`) en [GeneratedAd].
///
/// Rules :
/// - `title` et `description` sont requis (non vides) — sinon exception.
/// - `suggested_price` peut être `null` ou absent : on tente de récupérer
///   un prix depuis le draft (asking_price, monthly_payment, transfer_fee).
///   Renvoie 0 si rien de disponible (l'UI affiche alors "—").
/// - `condition` est toujours pris du draft (source de vérité côté utilisateur),
///   pas de ce que Gemini suggère.
/// - `improvement_tips` est optionnel ; on retourne une liste vide si absent.
GeneratedAd parseGeminiAd({
  required String rawJson,
  required AdDraft draft,
}) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(rawJson);
  } catch (e) {
    throw GeminiResponseException('JSON invalide : $e');
  }
  if (decoded is! Map<String, dynamic>) {
    throw GeminiResponseException(
      'Réponse inattendue : objet JSON attendu, reçu ${decoded.runtimeType}',
    );
  }

  final title = _nonEmptyString(decoded['title']);
  if (title == null) {
    throw GeminiResponseException('Champ "title" manquant ou vide');
  }
  final description = _nonEmptyString(decoded['description']);
  if (description == null) {
    throw GeminiResponseException('Champ "description" manquant ou vide');
  }

  final price = _asDouble(decoded['suggested_price']) ??
      _fallbackPriceFromDraft(draft);

  final tips = <String>[];
  final rawTips = decoded['improvement_tips'];
  if (rawTips is List) {
    for (final t in rawTips) {
      final s = t?.toString().trim();
      if (s != null && s.isNotEmpty) tips.add(s);
    }
  }

  return GeneratedAd(
    title: title,
    description: description,
    suggestedPrice: price,
    condition: draft.details['condition'] as String?,
    improvementTips: tips,
  );
}

/// Extrait `candidates[0].content.parts[0].text` de l'enveloppe Gemini.
/// Retourne `null` si la structure n'est pas celle attendue — le caller
/// décide quoi faire (généralement : tomber sur le fallback).
String? extractGeminiText(Map<String, dynamic> envelope) {
  final candidates = envelope['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;
  final first = candidates.first;
  if (first is! Map) return null;
  final content = first['content'];
  if (content is! Map) return null;
  final parts = content['parts'];
  if (parts is! List || parts.isEmpty) return null;
  final firstPart = parts.first;
  if (firstPart is! Map) return null;
  final text = firstPart['text'];
  return text is String ? text : null;
}

/// Extrait `candidates[0].finishReason`. Valeurs typiques : `STOP` (réponse
/// terminée), `MAX_TOKENS` (sortie tronquée — symptôme classique du JSON
/// incomplet), `SAFETY`, `RECITATION`.
String? extractFinishReason(Map<String, dynamic> envelope) {
  final candidates = envelope['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;
  final first = candidates.first;
  if (first is! Map) return null;
  final reason = first['finishReason'];
  return reason is String ? reason : null;
}

/// Extrait `usageMetadata` (promptTokenCount, candidatesTokenCount,
/// totalTokenCount). Utile pour diagnostiquer une troncature côté output.
Map<String, dynamic>? extractUsageMetadata(Map<String, dynamic> envelope) {
  final meta = envelope['usageMetadata'];
  if (meta is Map<String, dynamic>) return meta;
  return null;
}

/// Heuristique : la réponse est probablement tronquée si Gemini signale
/// `MAX_TOKENS`, ou si le texte ne se termine pas par `}` (le JSON attendu
/// est un objet). On l'utilise pour décider d'un retry avec un schéma
/// simplifié.
bool looksTruncated({required String? text, required String? finishReason}) {
  if (finishReason == 'MAX_TOKENS') return true;
  if (text == null) return false;
  final trimmed = text.trimRight();
  if (trimmed.isEmpty) return false;
  return !trimmed.endsWith('}');
}

String? _nonEmptyString(Object? v) {
  if (v is! String) return null;
  final trimmed = v.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    final n = num.tryParse(v.replaceAll(',', '.'));
    return n?.toDouble();
  }
  return null;
}

double _fallbackPriceFromDraft(AdDraft draft) {
  final d = draft.details;
  return _asDouble(d['asking_price']) ??
      _asDouble(d['monthly_payment']) ??
      _asDouble(d['transfer_fee_requested']) ??
      0;
}
