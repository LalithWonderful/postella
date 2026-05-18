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
      premiumTrialUsed: json['premium_trial_used'] as bool? ?? false,
      createdAdsCount: (json['created_ads_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'plan': _$PlanEnumMap[instance.plan]!,
      'premium_trial_used': instance.premiumTrialUsed,
      'created_ads_count': instance.createdAdsCount,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PlanEnumMap = {Plan.free: 'free', Plan.premium: 'premium'};
