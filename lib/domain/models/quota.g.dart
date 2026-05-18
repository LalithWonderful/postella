// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuotaImpl _$$QuotaImplFromJson(Map<String, dynamic> json) => _$QuotaImpl(
  userId: json['user_id'] as String,
  date: DateTime.parse(json['date'] as String),
  freeGenerationsUsed: (json['free_generations_used'] as num?)?.toInt() ?? 0,
  premiumGenerationsUsed:
      (json['premium_generations_used'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$QuotaImplToJson(_$QuotaImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'date': instance.date.toIso8601String(),
      'free_generations_used': instance.freeGenerationsUsed,
      'premium_generations_used': instance.premiumGenerationsUsed,
    };
