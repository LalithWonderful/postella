// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quota_decision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuotaDecision {
  bool get allowed => throw _privateConstructorUsedError;
  RefusalReason get reason => throw _privateConstructorUsedError;
  SuggestedAction get suggestedAction => throw _privateConstructorUsedError;
  bool get consumesTrial => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Create a copy of QuotaDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuotaDecisionCopyWith<QuotaDecision> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuotaDecisionCopyWith<$Res> {
  factory $QuotaDecisionCopyWith(
    QuotaDecision value,
    $Res Function(QuotaDecision) then,
  ) = _$QuotaDecisionCopyWithImpl<$Res, QuotaDecision>;
  @useResult
  $Res call({
    bool allowed,
    RefusalReason reason,
    SuggestedAction suggestedAction,
    bool consumesTrial,
    String? message,
  });
}

/// @nodoc
class _$QuotaDecisionCopyWithImpl<$Res, $Val extends QuotaDecision>
    implements $QuotaDecisionCopyWith<$Res> {
  _$QuotaDecisionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuotaDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowed = null,
    Object? reason = null,
    Object? suggestedAction = null,
    Object? consumesTrial = null,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            allowed: null == allowed
                ? _value.allowed
                : allowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as RefusalReason,
            suggestedAction: null == suggestedAction
                ? _value.suggestedAction
                : suggestedAction // ignore: cast_nullable_to_non_nullable
                      as SuggestedAction,
            consumesTrial: null == consumesTrial
                ? _value.consumesTrial
                : consumesTrial // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuotaDecisionImplCopyWith<$Res>
    implements $QuotaDecisionCopyWith<$Res> {
  factory _$$QuotaDecisionImplCopyWith(
    _$QuotaDecisionImpl value,
    $Res Function(_$QuotaDecisionImpl) then,
  ) = __$$QuotaDecisionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool allowed,
    RefusalReason reason,
    SuggestedAction suggestedAction,
    bool consumesTrial,
    String? message,
  });
}

/// @nodoc
class __$$QuotaDecisionImplCopyWithImpl<$Res>
    extends _$QuotaDecisionCopyWithImpl<$Res, _$QuotaDecisionImpl>
    implements _$$QuotaDecisionImplCopyWith<$Res> {
  __$$QuotaDecisionImplCopyWithImpl(
    _$QuotaDecisionImpl _value,
    $Res Function(_$QuotaDecisionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuotaDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowed = null,
    Object? reason = null,
    Object? suggestedAction = null,
    Object? consumesTrial = null,
    Object? message = freezed,
  }) {
    return _then(
      _$QuotaDecisionImpl(
        allowed: null == allowed
            ? _value.allowed
            : allowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as RefusalReason,
        suggestedAction: null == suggestedAction
            ? _value.suggestedAction
            : suggestedAction // ignore: cast_nullable_to_non_nullable
                  as SuggestedAction,
        consumesTrial: null == consumesTrial
            ? _value.consumesTrial
            : consumesTrial // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$QuotaDecisionImpl implements _QuotaDecision {
  const _$QuotaDecisionImpl({
    required this.allowed,
    required this.reason,
    required this.suggestedAction,
    this.consumesTrial = false,
    this.message,
  });

  @override
  final bool allowed;
  @override
  final RefusalReason reason;
  @override
  final SuggestedAction suggestedAction;
  @override
  @JsonKey()
  final bool consumesTrial;
  @override
  final String? message;

  @override
  String toString() {
    return 'QuotaDecision(allowed: $allowed, reason: $reason, suggestedAction: $suggestedAction, consumesTrial: $consumesTrial, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuotaDecisionImpl &&
            (identical(other.allowed, allowed) || other.allowed == allowed) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.suggestedAction, suggestedAction) ||
                other.suggestedAction == suggestedAction) &&
            (identical(other.consumesTrial, consumesTrial) ||
                other.consumesTrial == consumesTrial) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    allowed,
    reason,
    suggestedAction,
    consumesTrial,
    message,
  );

  /// Create a copy of QuotaDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuotaDecisionImplCopyWith<_$QuotaDecisionImpl> get copyWith =>
      __$$QuotaDecisionImplCopyWithImpl<_$QuotaDecisionImpl>(this, _$identity);
}

abstract class _QuotaDecision implements QuotaDecision {
  const factory _QuotaDecision({
    required final bool allowed,
    required final RefusalReason reason,
    required final SuggestedAction suggestedAction,
    final bool consumesTrial,
    final String? message,
  }) = _$QuotaDecisionImpl;

  @override
  bool get allowed;
  @override
  RefusalReason get reason;
  @override
  SuggestedAction get suggestedAction;
  @override
  bool get consumesTrial;
  @override
  String? get message;

  /// Create a copy of QuotaDecision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuotaDecisionImplCopyWith<_$QuotaDecisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
