// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdImpl _$$AdImplFromJson(Map<String, dynamic> json) => _$AdImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
  subcategory: json['subcategory'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble(),
  condition: json['condition'] as String?,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  details:
      json['details'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  status:
      $enumDecodeNullable(_$AdStatusEnumMap, json['status']) ?? AdStatus.draft,
  generator:
      $enumDecodeNullable(_$AdGeneratorEnumMap, json['generator']) ??
      AdGenerator.none,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$AdImplToJson(_$AdImpl instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'subcategory': instance.subcategory,
  'title': instance.title,
  'description': instance.description,
  'suggestedPrice': instance.suggestedPrice,
  'condition': instance.condition,
  'photos': instance.photos,
  'details': instance.details,
  'status': _$AdStatusEnumMap[instance.status]!,
  'generator': _$AdGeneratorEnumMap[instance.generator]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AdStatusEnumMap = {
  AdStatus.draft: 'draft',
  AdStatus.generated: 'generated',
  AdStatus.saved: 'saved',
};

const _$AdGeneratorEnumMap = {
  AdGenerator.gemini: 'gemini',
  AdGenerator.openai: 'openai',
  AdGenerator.none: 'none',
};
