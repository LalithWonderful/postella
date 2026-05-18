// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      plan: $enumDecodeNullable(_$PlanEnumMap, json['plan']) ?? Plan.free,
      premiumTrialUsed: json['premiumTrialUsed'] as bool? ?? false,
      createdAdsCount: (json['createdAdsCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'plan': _$PlanEnumMap[instance.plan]!,
      'premiumTrialUsed': instance.premiumTrialUsed,
      'createdAdsCount': instance.createdAdsCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PlanEnumMap = {Plan.free: 'free', Plan.premium: 'premium'};
