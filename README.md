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

1. Copier le template d'env et y mettre vos clés :
   ```sh
   cp env.example.json env.json
   # Éditer env.json avec les valeurs Supabase / Gemini / OpenAI
   ```
   `env.json` est gitignoré et ne doit JAMAIS être commité.

2. Installer les dépendances et générer le code :
   ```sh
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Lancer l'app :
   ```sh
   flutter run --dart-define-from-file=env.json
   ```

Sans `env.json` valide, l'app démarre quand même mais en mode déconnecté
(Supabase non initialisé, écrans auth purement décoratifs).

## Supabase

Les migrations sont dans `supabase/migrations/`. Pour appliquer le schéma
initial : Supabase Dashboard → SQL Editor → coller le contenu de
`0001_init.sql` → Run.

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
- **Lot 2** ✅ Domain : modèles freezed, 9 catégories peuplées, quota_policy + tests.
- **Lot 3** ✅ Supabase : migrations SQL, RLS, RPC `consume_quota`, écrans auth email/password.
- **Lot 3b** Auth OAuth Google + Apple (à venir).
- **Lot 4** Wizard de création : photos + tips, formulaire dynamique, résultat.
- **Lot 5** IA : Gemini réel + stub OpenAI, écran quota/upsell.
