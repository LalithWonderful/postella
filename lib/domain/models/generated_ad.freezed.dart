// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_ad.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GeneratedAd _$GeneratedAdFromJson(Map<String, dynamic> json) {
  return _GeneratedAd.fromJson(json);
}

/// @nodoc
mixin _$GeneratedAd {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get suggestedPrice => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  List<String> get improvementTips => throw _privateConstructorUsedError;

  /// Serializes this GeneratedAd to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneratedAdCopyWith<GeneratedAd> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratedAdCopyWith<$Res> {
  factory $GeneratedAdCopyWith(
    GeneratedAd value,
    $Res Function(GeneratedAd) then,
  ) = _$GeneratedAdCopyWithImpl<$Res, GeneratedAd>;
  @useResult
  $Res call({
    String title,
    String description,
    double suggestedPrice,
    String? condition,
    List<String> improvementTips,
  });
}

/// @nodoc
class _$GeneratedAdCopyWithImpl<$Res, $Val extends GeneratedAd>
    implements $GeneratedAdCopyWith<$Res> {
  _$GeneratedAdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? suggestedPrice = null,
    Object? condition = freezed,
    Object? improvementTips = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestedPrice: null == suggestedPrice
                ? _value.suggestedPrice
                : suggestedPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String?,
            improvementTips: null == improvementTips
                ? _value.improvementTips
                : improvementTips // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeneratedAdImplCopyWith<$Res>
    implements $GeneratedAdCopyWith<$Res> {
  factory _$$GeneratedAdImplCopyWith(
    _$GeneratedAdImpl value,
    $Res Function(_$GeneratedAdImpl) then,
  ) = __$$GeneratedAdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String description,
    double suggestedPrice,
    String? condition,
    List<String> improvementTips,
  });
}

/// @nodoc
class __$$GeneratedAdImplCopyWithImpl<$Res>
    extends _$GeneratedAdCopyWithImpl<$Res, _$GeneratedAdImpl>
    implements _$$GeneratedAdImplCopyWith<$Res> {
  __$$GeneratedAdImplCopyWithImpl(
    _$GeneratedAdImpl _value,
    $Res Function(_$GeneratedAdImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? suggestedPrice = null,
    Object? condition = freezed,
    Object? improvementTips = null,
  }) {
    return _then(
      _$GeneratedAdImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestedPrice: null == suggestedPrice
            ? _value.suggestedPrice
            : suggestedPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String?,
        improvementTips: null == improvementTips
            ? _value._improvementTips
            : improvementTips // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeneratedAdImpl implements _GeneratedAd {
  const _$GeneratedAdImpl({
    required this.title,
    required this.description,
    required this.suggestedPrice,
    this.condition,
    final List<String> improvementTips = const <String>[],
  }) : _improvementTips = improvementTips;

  factory _$GeneratedAdImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeneratedAdImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final double suggestedPrice;
  @override
  final String? condition;
  final List<String> _improvementTips;
  @override
  @JsonKey()
  List<String> get improvementTips {
    if (_improvementTips is EqualUnmodifiableListView) return _improvementTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementTips);
  }

  @override
  String toString() {
    return 'GeneratedAd(title: $title, description: $description, suggestedPrice: $suggestedPrice, condition: $condition, improvementTips: $improvementTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratedAdImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.suggestedPrice, suggestedPrice) ||
                other.suggestedPrice == suggestedPrice) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(
              other._improvementTips,
              _improvementTips,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    suggestedPrice,
    condition,
    const DeepCollectionEquality().hash(_improvementTips),
  );

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratedAdImplCopyWith<_$GeneratedAdImpl> get copyWith =>
      __$$GeneratedAdImplCopyWithImpl<_$GeneratedAdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeneratedAdImplToJson(this);
  }
}

abstract class _GeneratedAd implements GeneratedAd {
  const factory _GeneratedAd({
    required final String title,
    required final String description,
    required final double suggestedPrice,
    final String? condition,
    final List<String> improvementTips,
  }) = _$GeneratedAdImpl;

  factory _GeneratedAd.fromJson(Map<String, dynamic> json) =
      _$GeneratedAdImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  double get suggestedPrice;
  @override
  String? get condition;
  @override
  List<String> get improvementTips;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratedAdImplCopyWith<_$GeneratedAdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
