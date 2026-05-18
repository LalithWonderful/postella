// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ad_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdDraft {
  String? get categoryId => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  Map<String, dynamic> get details => throw _privateConstructorUsedError;

  /// Create a copy of AdDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdDraftCopyWith<AdDraft> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdDraftCopyWith<$Res> {
  factory $AdDraftCopyWith(AdDraft value, $Res Function(AdDraft) then) =
      _$AdDraftCopyWithImpl<$Res, AdDraft>;
  @useResult
  $Res call({
    String? categoryId,
    List<String> photos,
    Map<String, dynamic> details,
  });
}

/// @nodoc
class _$AdDraftCopyWithImpl<$Res, $Val extends AdDraft>
    implements $AdDraftCopyWith<$Res> {
  _$AdDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? photos = null,
    Object? details = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            photos: null == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdDraftImplCopyWith<$Res> implements $AdDraftCopyWith<$Res> {
  factory _$$AdDraftImplCopyWith(
    _$AdDraftImpl value,
    $Res Function(_$AdDraftImpl) then,
  ) = __$$AdDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? categoryId,
    List<String> photos,
    Map<String, dynamic> details,
  });
}

/// @nodoc
class __$$AdDraftImplCopyWithImpl<$Res>
    extends _$AdDraftCopyWithImpl<$Res, _$AdDraftImpl>
    implements _$$AdDraftImplCopyWith<$Res> {
  __$$AdDraftImplCopyWithImpl(
    _$AdDraftImpl _value,
    $Res Function(_$AdDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? photos = null,
    Object? details = null,
  }) {
    return _then(
      _$AdDraftImpl(
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        photos: null == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$AdDraftImpl implements _AdDraft {
  const _$AdDraftImpl({
    this.categoryId,
    final List<String> photos = const <String>[],
    final Map<String, dynamic> details = const <String, dynamic>{},
  }) : _photos = photos,
       _details = details;

  @override
  final String? categoryId;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  final Map<String, dynamic> _details;
  @override
  @JsonKey()
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  @override
  String toString() {
    return 'AdDraft(categoryId: $categoryId, photos: $photos, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdDraftImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    const DeepCollectionEquality().hash(_photos),
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AdDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdDraftImplCopyWith<_$AdDraftImpl> get copyWith =>
      __$$AdDraftImplCopyWithImpl<_$AdDraftImpl>(this, _$identity);
}

abstract class _AdDraft implements AdDraft {
  const factory _AdDraft({
    final String? categoryId,
    final List<String> photos,
    final Map<String, dynamic> details,
  }) = _$AdDraftImpl;

  @override
  String? get categoryId;
  @override
  List<String> get photos;
  @override
  Map<String, dynamic> get details;

  /// Create a copy of AdDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdDraftImplCopyWith<_$AdDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
