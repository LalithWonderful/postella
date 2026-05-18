# Postella

App mobile Flutter qui aide à créer rapidement une annonce de seconde main à partir de photos.

## Stack

- Flutter 3.41+ / Dart 3.11+
- State management : `flutter_riverpod`
- Routing : `go_router`
- Modèles : `freezed` + `json_serializable`
- Backend : Supabase (Auth + Postgres + Storage) — *non branché en lot 1*
- IA : Gemini (génération gratuite) + OpenAI mocké (premium) — *non branché en lot 1*

## Démarrage

```sh
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GEMINI_API_KEY=...
```

En lot 1 aucune clé n'est requise : l'app se lance sur le splash puis route vers des écrans placeholder.

## Structure

```
lib/
  core/                   # theme, env, configuration transverse
  domain/                 # modèles, catégories, quota_policy (lot 2)
  infrastructure/         # supabase, ai (lots 3 & 5)
  application/            # providers riverpod (lot 2+)
  ui/                     # écrans + widgets
  l10n/                   # i18n (FR par défaut)
supabase/migrations/      # SQL Supabase (lot 3)
test/                     # tests unitaires
```

## Lots de développement

- **Lot 1** ✅ Bootstrap : projet, thème, routes, écrans placeholder.
- **Lot 2** Domain : modèles freezed, 9 catégories peuplées, quota_policy + tests.
- **Lot 3** Supabase : migrations, RLS, RPC `consume_quota`, écrans auth.
- **Lot 4** Wizard de création : photos + tips, formulaire dynamique, résultat.
- **Lot 5** IA : Gemini réel + stub OpenAI, écran quota/upsell.
