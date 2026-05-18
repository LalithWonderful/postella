// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeneratedAdImpl _$$GeneratedAdImplFromJson(Map<String, dynamic> json) =>
    _$GeneratedAdImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      suggestedPrice: (json['suggested_price'] as num).toDouble(),
      condition: json['condition'] as String?,
      improvementTips:
          (json['improvement_tips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$GeneratedAdImplToJson(_$GeneratedAdImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'suggested_price': instance.suggestedPrice,
      'condition': instance.condition,
      'improvement_tips': instance.improvementTips,
    };
