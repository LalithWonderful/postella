import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad.freezed.dart';
part 'ad.g.dart';

/// Statut d'une annonce dans le cycle de vie.
enum AdStatus { draft, generated, saved }

/// Moteur ayant produit la dernière version de l'annonce.
enum AdEngine { gemini, openai, none }

@freezed
class Ad with _$Ad {
  const factory Ad({
    required String id,
    required String userId,
    required String categoryId,
    String? subcategory,
    String? title,
    String? description,
    double? suggestedPrice,
    String? condition,
    @Default(<String>[]) List<String> photos,
    @Default(<String, dynamic>{}) Map<String, dynamic> details,
    @Default(AdStatus.draft) AdStatus status,
    @Default(AdEngine.none) AdEngine generator,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Ad;

  factory Ad.fromJson(Map<String, dynamic> json) => _$AdFromJson(json);
}
