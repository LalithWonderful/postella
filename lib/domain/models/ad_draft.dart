import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad_draft.freezed.dart';

/// Brouillon manipulé pendant le wizard de création.
///
/// Non sérialisé en JSON : c'est de la donnée locale au flow. Si on veut un
/// jour persister les drafts, ajouter `_$AdDraftFromJson` à ce moment-là.
@freezed
class AdDraft with _$AdDraft {
  const factory AdDraft({
    String? categoryId,
    @Default(<String>[]) List<String> photos,
    @Default(<String, dynamic>{}) Map<String, dynamic> details,
  }) = _AdDraft;

  /// Brouillon vide initial.
  factory AdDraft.empty() => const AdDraft();
}
