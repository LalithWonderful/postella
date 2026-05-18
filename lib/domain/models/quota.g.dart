// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuotaImpl _$$QuotaImplFromJson(Map<String, dynamic> json) => _$QuotaImpl(
  userId: json['userId'] as String,
  date: DateTime.parse(json['date'] as String),
  freeGenerationsUsed: (json['freeGenerationsUsed'] as num?)?.toInt() ?? 0,
  premiumGenerationsUsed:
      (json['premiumGenerationsUsed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$QuotaImplToJson(_$QuotaImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'freeGenerationsUsed': instance.freeGenerationsUsed,
      'premiumGenerationsUsed': instance.premiumGenerationsUsed,
    };
