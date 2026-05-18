// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdImpl _$$AdImplFromJson(Map<String, dynamic> json) => _$AdImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  categoryId: json['category_id'] as String,
  subcategory: json['subcategory'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
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
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$AdImplToJson(_$AdImpl instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'category_id': instance.categoryId,
  'subcategory': instance.subcategory,
  'title': instance.title,
  'description': instance.description,
  'suggested_price': instance.suggestedPrice,
  'condition': instance.condition,
  'photos': instance.photos,
  'details': instance.details,
  'status': _$AdStatusEnumMap[instance.status]!,
  'generator': _$AdGeneratorEnumMap[instance.generator]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
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
