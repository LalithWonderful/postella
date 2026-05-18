import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';

/// Initialise Supabase si les variables d'environnement sont présentes.
///
/// Si [Env.hasSupabase] vaut `false`, l'app démarre quand même mais en mode
/// "déconnecté" : les écrans qui ont besoin d'auth doivent vérifier
/// [Env.hasSupabase] et afficher un état d'erreur clair.
Future<void> initSupabase() async {
  if (!Env.hasSupabase) return;
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    debug: false,
  );
}

/// Accès rapide au client Supabase initialisé. Lance si appelé avant
/// [initSupabase] ou sans config.
SupabaseClient get supabase => Supabase.instance.client;
