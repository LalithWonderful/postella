import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_ad.freezed.dart';
part 'generated_ad.g.dart';

/// Résultat structuré renvoyé par un `AdGenerator`.
@freezed
class GeneratedAd with _$GeneratedAd {
  const factory GeneratedAd({
    required String title,
    required String description,
    required double suggestedPrice,
    String? condition,
    @Default(<String>[]) List<String> improvementTips,
  }) = _GeneratedAd;

  factory GeneratedAd.fromJson(Map<String, dynamic> json) =>
      _$GeneratedAdFromJson(json);
}
