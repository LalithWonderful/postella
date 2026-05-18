// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quota.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Quota _$QuotaFromJson(Map<String, dynamic> json) {
  return _Quota.fromJson(json);
}

/// @nodoc
mixin _$Quota {
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get freeGenerationsUsed => throw _privateConstructorUsedError;
  int get premiumGenerationsUsed => throw _privateConstructorUsedError;

  /// Serializes this Quota to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Quota
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuotaCopyWith<Quota> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuotaCopyWith<$Res> {
  factory $QuotaCopyWith(Quota value, $Res Function(Quota) then) =
      _$QuotaCopyWithImpl<$Res, Quota>;
  @useResult
  $Res call({
    String userId,
    DateTime date,
    int freeGenerationsUsed,
    int premiumGenerationsUsed,
  });
}

/// @nodoc
class _$QuotaCopyWithImpl<$Res, $Val extends Quota>
    implements $QuotaCopyWith<$Res> {
  _$QuotaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Quota
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? freeGenerationsUsed = null,
    Object? premiumGenerationsUsed = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            freeGenerationsUsed: null == freeGenerationsUsed
                ? _value.freeGenerationsUsed
                : freeGenerationsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            premiumGenerationsUsed: null == premiumGenerationsUsed
                ? _value.premiumGenerationsUsed
                : premiumGenerationsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuotaImplCopyWith<$Res> implements $QuotaCopyWith<$Res> {
  factory _$$QuotaImplCopyWith(
    _$QuotaImpl value,
    $Res Function(_$QuotaImpl) then,
  ) = __$$QuotaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    DateTime date,
    int freeGenerationsUsed,
    int premiumGenerationsUsed,
  });
}

/// @nodoc
class __$$QuotaImplCopyWithImpl<$Res>
    extends _$QuotaCopyWithImpl<$Res, _$QuotaImpl>
    implements _$$QuotaImplCopyWith<$Res> {
  __$$QuotaImplCopyWithImpl(
    _$QuotaImpl _value,
    $Res Function(_$QuotaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Quota
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? freeGenerationsUsed = null,
    Object? premiumGenerationsUsed = null,
  }) {
    return _then(
      _$QuotaImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        freeGenerationsUsed: null == freeGenerationsUsed
            ? _value.freeGenerationsUsed
            : freeGenerationsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        premiumGenerationsUsed: null == premiumGenerationsUsed
            ? _value.premiumGenerationsUsed
            : premiumGenerationsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuotaImpl implements _Quota {
  const _$QuotaImpl({
    required this.userId,
    required this.date,
    this.freeGenerationsUsed = 0,
    this.premiumGenerationsUsed = 0,
  });

  factory _$QuotaImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuotaImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final int freeGenerationsUsed;
  @override
  @JsonKey()
  final int premiumGenerationsUsed;

  @override
  String toString() {
    return 'Quota(userId: $userId, date: $date, freeGenerationsUsed: $freeGenerationsUsed, premiumGenerationsUsed: $premiumGenerationsUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuotaImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.freeGenerationsUsed, freeGenerationsUsed) ||
                other.freeGenerationsUsed == freeGenerationsUsed) &&
            (identical(other.premiumGenerationsUsed, premiumGenerationsUsed) ||
                other.premiumGenerationsUsed == premiumGenerationsUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    date,
    freeGenerationsUsed,
    premiumGenerationsUsed,
  );

  /// Create a copy of Quota
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuotaImplCopyWith<_$QuotaImpl> get copyWith =>
      __$$QuotaImplCopyWithImpl<_$QuotaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuotaImplToJson(this);
  }
}

abstract class _Quota implements Quota {
  const factory _Quota({
    required final String userId,
    required final DateTime date,
    final int freeGenerationsUsed,
    final int premiumGenerationsUsed,
  }) = _$QuotaImpl;

  factory _Quota.fromJson(Map<String, dynamic> json) = _$QuotaImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get date;
  @override
  int get freeGenerationsUsed;
  @override
  int get premiumGenerationsUsed;

  /// Create a copy of Quota
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuotaImplCopyWith<_$QuotaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
