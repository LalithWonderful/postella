/// Limites de quotas Postella — un seul endroit pour les ajuster.
///
/// Aucune notion d'illimité : tous les plans ont un plafond journalier.
class QuotaLimits {
  const QuotaLimits._();

  /// Générations Gemini (texte) autorisées par jour pour un plan free.
  static const int freeDailyText = 2;

  /// Générations Gemini (texte) autorisées par jour pour un plan premium.
  static const int premiumDailyText = 15;

  /// Générations OpenAI (texte + image) autorisées par jour pour un plan premium.
  static const int premiumDailyImage = 5;

  /// Nombre total d'essais premium offerts à vie à un utilisateur free.
  static const int trialPerLifetime = 1;
}
