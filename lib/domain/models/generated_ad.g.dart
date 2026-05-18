// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeneratedAdImpl _$$GeneratedAdImplFromJson(Map<String, dynamic> json) =>
    _$GeneratedAdImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      suggestedPrice: (json['suggestedPrice'] as num).toDouble(),
      condition: json['condition'] as String?,
      improvementTips:
          (json['improvementTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$GeneratedAdImplToJson(_$GeneratedAdImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'suggestedPrice': instance.suggestedPrice,
      'condition': instance.condition,
      'improvementTips': instance.improvementTips,
    };
