import '../../domain/categories/category.dart';
import '../../domain/categories/field_spec.dart';
import '../../domain/models/ad_draft.dart';

/// Construit le prompt utilisateur envoyé à Gemini pour générer une
/// annonce. Pure function : zéro dépendance externe, 100 % testable.
///
/// Le `responseSchema` (côté `generationConfig`) garantit déjà la forme
/// JSON ; ce prompt sert à transmettre la matière (catégorie, champs,
/// valeurs) et les contraintes éditoriales.
///
/// `includeTips` : passe à `false` lors d'un retry après troncature pour
/// produire une réponse plus compacte (le schéma de retry omet
/// `improvement_tips` côté generator).
String buildGeminiPrompt({
  required AdDraft draft,
  required Category category,
  bool includeTips = true,
}) {
  final buf = StringBuffer();

  buf.writeln(
    'Tu rédiges une annonce de vente entre particuliers (seconde main) en français.',
  );
  buf.writeln();

  buf.writeln('CATÉGORIE : ${category.label}');
  buf.writeln('CONTEXTE : ${category.aiContext}');
  buf.writeln();

  if (category.pricingHints.isNotEmpty) {
    buf.writeln(
      'CONSEILS TARIFAIRES DE RÉFÉRENCE (indication, pas vérité absolue) :',
    );
    for (final hint in category.pricingHints) {
      buf.writeln('- $hint');
    }
    buf.writeln();
  }

  buf.writeln('INFORMATIONS FOURNIES PAR L\'UTILISATEUR :');
  final lines = _formatUserInputs(category, draft.details);
  if (lines.isEmpty) {
    buf.writeln('- (aucune)');
  } else {
    for (final line in lines) {
      buf.writeln('- $line');
    }
  }
  buf.writeln();

  buf.writeln(
    'PHOTOS DISPONIBLES : ${draft.photos.length} '
    '(non transmises à toi à ce stade — ne les analyse pas).',
  );
  buf.writeln();

  buf.writeln('CONSIGNES STRICTES :');
  buf.writeln('- Écris en français, ton clair, vendeur, naturel.');
  buf.writeln('- Pas de superlatifs creux ni de promesses mensongères.');
  buf.writeln(
    '- N\'invente AUCUNE caractéristique qui ne figure pas ci-dessus.',
  );
  buf.writeln(
    '- Si un défaut est mentionné, intègre-le honnêtement dans la description.',
  );
  buf.writeln(
    '- "title" : court (<= 70 caractères), adapté à une plateforme type Vinted / Leboncoin.',
  );
  buf.writeln(
    '- "description" : prête à copier/coller, paragraphes courts si pertinent, '
    'pas d\'emoji, pas de formatage markdown.',
  );
  buf.writeln(
    '- "suggested_price" : ne propose un nombre QUE si les éléments fournis '
    'suffisent à l\'estimer (marque, modèle, état, contexte). '
    'Sinon, laisse `null`. Ne devine pas.',
  );
  if (includeTips) {
    buf.writeln(
      '- "improvement_tips" : 1 à 3 conseils actionnables pour mieux vendre '
      '(photo, info manquante, prix). Pas de remplissage.',
    );
  }
  buf.writeln(
    '- Réponds STRICTEMENT au schéma JSON imposé. Aucun texte hors JSON, '
    'aucune balise markdown, aucun commentaire.',
  );
  buf.writeln(
    '- Renvoie UN SEUL objet JSON complet et bien formé : ouvre `{`, ferme '
    '`}`, ne tronque jamais la sortie. Sois concis pour tenir dans la limite.',
  );

  return buf.toString();
}

/// Met en forme `<label> : <valeur lisible>` pour chaque champ saisi.
/// Les valeurs `select`/`multiSelect` sont traduites en label humain (FR)
/// pour que Gemini comprenne (les codes `value` lui sont opaques).
List<String> _formatUserInputs(
  Category category,
  Map<String, dynamic> details,
) {
  final out = <String>[];
  for (final field in category.allFields) {
    final Object? raw = details[field.id];
    if (raw == null) continue;
    if (raw is String && raw.isEmpty) continue;
    out.add('${field.label} : ${_formatValue(field, raw)}');
  }
  return out;
}

String _formatValue(FieldSpec field, Object raw) {
  if (raw is List) {
    final labels = raw.map((v) {
      final s = v.toString();
      return _labelForSpec(field, s) ?? s;
    }).join(', ');
    return labels;
  }
  if (raw is bool) return raw ? 'Oui' : 'Non';
  final base = _labelForSpec(field, raw.toString()) ?? raw.toString();
  return field.unit != null ? '$base ${field.unit}' : base;
}

String? _labelForSpec(FieldSpec field, String value) {
  final opts = field.options;
  if (opts == null) return null;
  for (final o in opts) {
    if (o.value == value) return o.label;
  }
  return null;
}
