import 'package:freezed_annotation/freezed_annotation.dart';

import 'plan.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String email,
    @Default(Plan.free) Plan plan,
    @Default(false) bool premiumTrialUsed,
    @Default(0) int createdAdsCount,
    required DateTime createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
