/// Plan utilisateur. Sérialisé en JSON sous forme de chaîne lower-case.
enum Plan { free, premium }

/// Mode de génération demandé par l'utilisateur.
///
/// - [GenerationMode.free] : Gemini, comptabilisé dans `freeGenerationsUsed`.
/// - [GenerationMode.premium] : OpenAI + enrichissement, comptabilisé dans
///   `premiumGenerationsUsed` ou comme essai unique.
enum GenerationMode { free, premium }
