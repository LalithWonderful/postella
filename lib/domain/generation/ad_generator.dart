import '../categories/category.dart';
import '../models/ad_draft.dart';
import '../models/generated_ad.dart';

/// Contrat des moteurs de génération d'annonces (mock dev, Gemini, OpenAI…).
///
/// Toute implémentation doit retourner un [GeneratedAd] valide ou lever
/// [GenerationException] avec un message utilisateur lisible. Lever
/// d'autres types d'erreur est autorisé mais sera traduit en message
/// générique par le contrôleur.
abstract class AdGenerator {
  Future<GeneratedAd> generate({
    required AdDraft draft,
    required Category category,
  });
}

/// Erreur métier remontée à l'utilisateur (UI affiche `message` tel quel).
class GenerationException implements Exception {
  GenerationException(this.message);
  final String message;

  @override
  String toString() => message;
}
