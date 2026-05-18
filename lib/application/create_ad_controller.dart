import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/ad_draft.dart';

/// État partagé entre les étapes du wizard de création.
///
/// Le draft reste 100 % local au flow tant que l'utilisateur n'a pas
/// sauvegardé : aucune écriture en base, aucun upload de photos.
class CreateAdController extends StateNotifier<AdDraft> {
  CreateAdController() : super(AdDraft.empty());

  /// Démarre un nouveau wizard sur une catégorie donnée. Repart d'un draft
  /// vierge — si l'utilisateur change d'avis sur la catégorie en revenant
  /// au picker, ses photos et infos précédentes sont remises à zéro.
  void setCategory(String id) {
    state = AdDraft.empty().copyWith(categoryId: id);
  }

  void addPhotos(List<String> paths) {
    if (paths.isEmpty) return;
    state = state.copyWith(photos: [...state.photos, ...paths]);
  }

  void removePhoto(String path) {
    state = state.copyWith(
      photos: state.photos.where((p) => p != path).toList(),
    );
  }

  void setField(String key, Object? value) {
    final next = Map<String, dynamic>.of(state.details);
    if (value == null || (value is String && value.isEmpty)) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    state = state.copyWith(details: next);
  }

  void reset() {
    state = AdDraft.empty();
  }
}

final createAdControllerProvider =
    StateNotifierProvider<CreateAdController, AdDraft>(
      (_) => CreateAdController(),
    );
