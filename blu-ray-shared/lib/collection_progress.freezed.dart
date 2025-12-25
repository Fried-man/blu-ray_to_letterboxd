// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CollectionProgress _$CollectionProgressFromJson(Map<String, dynamic> json) {
  return _CollectionProgress.fromJson(json);
}

/// @nodoc
mixin _$CollectionProgress {
  /// Type of progress event
  ProgressEventType get type => throw _privateConstructorUsedError;

  /// Current page being processed (null for non-page events)
  int? get currentPage => throw _privateConstructorUsedError;

  /// Total pages discovered so far (null if unknown)
  int? get totalPages => throw _privateConstructorUsedError;

  /// Number of items processed on current page
  int? get itemsOnCurrentPage => throw _privateConstructorUsedError;

  /// Total unique items found so far
  int get totalItemsFound => throw _privateConstructorUsedError;

  /// Progress percentage (0.0 to 1.0, null if indeterminate)
  double? get progressPercentage => throw _privateConstructorUsedError;

  /// Optional message describing current operation
  String? get message => throw _privateConstructorUsedError;

  /// Error message if type is error
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this CollectionProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionProgressCopyWith<CollectionProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionProgressCopyWith<$Res> {
  factory $CollectionProgressCopyWith(
          CollectionProgress value, $Res Function(CollectionProgress) then) =
      _$CollectionProgressCopyWithImpl<$Res, CollectionProgress>;
  @useResult
  $Res call(
      {ProgressEventType type,
      int? currentPage,
      int? totalPages,
      int? itemsOnCurrentPage,
      int totalItemsFound,
      double? progressPercentage,
      String? message,
      String? error});
}

/// @nodoc
class _$CollectionProgressCopyWithImpl<$Res, $Val extends CollectionProgress>
    implements $CollectionProgressCopyWith<$Res> {
  _$CollectionProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? currentPage = freezed,
    Object? totalPages = freezed,
    Object? itemsOnCurrentPage = freezed,
    Object? totalItemsFound = null,
    Object? progressPercentage = freezed,
    Object? message = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProgressEventType,
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
      itemsOnCurrentPage: freezed == itemsOnCurrentPage
          ? _value.itemsOnCurrentPage
          : itemsOnCurrentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalItemsFound: null == totalItemsFound
          ? _value.totalItemsFound
          : totalItemsFound // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: freezed == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectionProgressImplCopyWith<$Res>
    implements $CollectionProgressCopyWith<$Res> {
  factory _$$CollectionProgressImplCopyWith(_$CollectionProgressImpl value,
          $Res Function(_$CollectionProgressImpl) then) =
      __$$CollectionProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProgressEventType type,
      int? currentPage,
      int? totalPages,
      int? itemsOnCurrentPage,
      int totalItemsFound,
      double? progressPercentage,
      String? message,
      String? error});
}

/// @nodoc
class __$$CollectionProgressImplCopyWithImpl<$Res>
    extends _$CollectionProgressCopyWithImpl<$Res, _$CollectionProgressImpl>
    implements _$$CollectionProgressImplCopyWith<$Res> {
  __$$CollectionProgressImplCopyWithImpl(_$CollectionProgressImpl _value,
      $Res Function(_$CollectionProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectionProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? currentPage = freezed,
    Object? totalPages = freezed,
    Object? itemsOnCurrentPage = freezed,
    Object? totalItemsFound = null,
    Object? progressPercentage = freezed,
    Object? message = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CollectionProgressImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProgressEventType,
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
      itemsOnCurrentPage: freezed == itemsOnCurrentPage
          ? _value.itemsOnCurrentPage
          : itemsOnCurrentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalItemsFound: null == totalItemsFound
          ? _value.totalItemsFound
          : totalItemsFound // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: freezed == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionProgressImpl implements _CollectionProgress {
  const _$CollectionProgressImpl(
      {required this.type,
      this.currentPage,
      this.totalPages,
      this.itemsOnCurrentPage,
      required this.totalItemsFound,
      this.progressPercentage,
      this.message,
      this.error});

  factory _$CollectionProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionProgressImplFromJson(json);

  /// Type of progress event
  @override
  final ProgressEventType type;

  /// Current page being processed (null for non-page events)
  @override
  final int? currentPage;

  /// Total pages discovered so far (null if unknown)
  @override
  final int? totalPages;

  /// Number of items processed on current page
  @override
  final int? itemsOnCurrentPage;

  /// Total unique items found so far
  @override
  final int totalItemsFound;

  /// Progress percentage (0.0 to 1.0, null if indeterminate)
  @override
  final double? progressPercentage;

  /// Optional message describing current operation
  @override
  final String? message;

  /// Error message if type is error
  @override
  final String? error;

  @override
  String toString() {
    return 'CollectionProgress(type: $type, currentPage: $currentPage, totalPages: $totalPages, itemsOnCurrentPage: $itemsOnCurrentPage, totalItemsFound: $totalItemsFound, progressPercentage: $progressPercentage, message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionProgressImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.itemsOnCurrentPage, itemsOnCurrentPage) ||
                other.itemsOnCurrentPage == itemsOnCurrentPage) &&
            (identical(other.totalItemsFound, totalItemsFound) ||
                other.totalItemsFound == totalItemsFound) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, currentPage, totalPages,
      itemsOnCurrentPage, totalItemsFound, progressPercentage, message, error);

  /// Create a copy of CollectionProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionProgressImplCopyWith<_$CollectionProgressImpl> get copyWith =>
      __$$CollectionProgressImplCopyWithImpl<_$CollectionProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionProgressImplToJson(
      this,
    );
  }
}

abstract class _CollectionProgress implements CollectionProgress {
  const factory _CollectionProgress(
      {required final ProgressEventType type,
      final int? currentPage,
      final int? totalPages,
      final int? itemsOnCurrentPage,
      required final int totalItemsFound,
      final double? progressPercentage,
      final String? message,
      final String? error}) = _$CollectionProgressImpl;

  factory _CollectionProgress.fromJson(Map<String, dynamic> json) =
      _$CollectionProgressImpl.fromJson;

  /// Type of progress event
  @override
  ProgressEventType get type;

  /// Current page being processed (null for non-page events)
  @override
  int? get currentPage;

  /// Total pages discovered so far (null if unknown)
  @override
  int? get totalPages;

  /// Number of items processed on current page
  @override
  int? get itemsOnCurrentPage;

  /// Total unique items found so far
  @override
  int get totalItemsFound;

  /// Progress percentage (0.0 to 1.0, null if indeterminate)
  @override
  double? get progressPercentage;

  /// Optional message describing current operation
  @override
  String? get message;

  /// Error message if type is error
  @override
  String? get error;

  /// Create a copy of CollectionProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionProgressImplCopyWith<_$CollectionProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
