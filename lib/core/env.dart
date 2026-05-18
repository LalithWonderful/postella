class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Bypass dev-only du quota côté client : court-circuite `consume_quota`
  /// pour pouvoir itérer sur la génération sans épuiser ses essais.
  ///
  /// **Ne change RIEN côté serveur** : la RPC reste en place, les RLS et les
  /// limites Supabase sont intactes. C'est purement un contournement client.
  /// Default `false` — release et CI sans flag se comportent comme avant.
  static const bypassQuotaForDev = bool.fromEnvironment(
    'BYPASS_QUOTA_FOR_DEV',
    defaultValue: false,
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasGemini => geminiApiKey.isNotEmpty;
}
