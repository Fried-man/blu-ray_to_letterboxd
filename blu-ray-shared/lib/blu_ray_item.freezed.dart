// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blu_ray_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BluRayItem _$BluRayItemFromJson(Map<String, dynamic> json) {
  return _BluRayItem.fromJson(json);
}

/// @nodoc
mixin _$BluRayItem {
  /// The title of the movie
  String? get title => throw _privateConstructorUsedError;

  /// The release year as an integer
  int? get year => throw _privateConstructorUsedError;

  /// Format type (Blu-ray, DVD, 4K, etc.)
  String? get format => throw _privateConstructorUsedError;

  /// Universal Product Code as a BigInt for proper numeric handling
  BigInt? get upc => throw _privateConstructorUsedError;

  /// URL to the movie's specific page on Blu-ray.com
  String? get movieUrl => throw _privateConstructorUsedError;

  /// URL to the movie cover image
  String? get coverImageUrl => throw _privateConstructorUsedError;

  /// Blu-ray.com product ID
  String? get productId => throw _privateConstructorUsedError;

  /// Blu-ray.com global product ID
  String? get globalProductId => throw _privateConstructorUsedError;

  /// Blu-ray.com global parent ID
  String? get globalParentId => throw _privateConstructorUsedError;

  /// Blu-ray.com category ID
  String? get categoryId => throw _privateConstructorUsedError;

  /// Derived category name from categoryId
  String? get category => throw _privateConstructorUsedError;

  /// End year for collections as an integer (null for ongoing collections)
  int? get endYear => throw _privateConstructorUsedError;

  /// Serializes this BluRayItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BluRayItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BluRayItemCopyWith<BluRayItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BluRayItemCopyWith<$Res> {
  factory $BluRayItemCopyWith(
          BluRayItem value, $Res Function(BluRayItem) then) =
      _$BluRayItemCopyWithImpl<$Res, BluRayItem>;
  @useResult
  $Res call(
      {String? title,
      int? year,
      String? format,
      BigInt? upc,
      String? movieUrl,
      String? coverImageUrl,
      String? productId,
      String? globalProductId,
      String? globalParentId,
      String? categoryId,
      String? category,
      int? endYear});
}

/// @nodoc
class _$BluRayItemCopyWithImpl<$Res, $Val extends BluRayItem>
    implements $BluRayItemCopyWith<$Res> {
  _$BluRayItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BluRayItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? year = freezed,
    Object? format = freezed,
    Object? upc = freezed,
    Object? movieUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? productId = freezed,
    Object? globalProductId = freezed,
    Object? globalParentId = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? endYear = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      format: freezed == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      upc: freezed == upc
          ? _value.upc
          : upc // ignore: cast_nullable_to_non_nullable
              as BigInt?,
      movieUrl: freezed == movieUrl
          ? _value.movieUrl
          : movieUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      globalProductId: freezed == globalProductId
          ? _value.globalProductId
          : globalProductId // ignore: cast_nullable_to_non_nullable
              as String?,
      globalParentId: freezed == globalParentId
          ? _value.globalParentId
          : globalParentId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      endYear: freezed == endYear
          ? _value.endYear
          : endYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BluRayItemImplCopyWith<$Res>
    implements $BluRayItemCopyWith<$Res> {
  factory _$$BluRayItemImplCopyWith(
          _$BluRayItemImpl value, $Res Function(_$BluRayItemImpl) then) =
      __$$BluRayItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      int? year,
      String? format,
      BigInt? upc,
      String? movieUrl,
      String? coverImageUrl,
      String? productId,
      String? globalProductId,
      String? globalParentId,
      String? categoryId,
      String? category,
      int? endYear});
}

/// @nodoc
class __$$BluRayItemImplCopyWithImpl<$Res>
    extends _$BluRayItemCopyWithImpl<$Res, _$BluRayItemImpl>
    implements _$$BluRayItemImplCopyWith<$Res> {
  __$$BluRayItemImplCopyWithImpl(
      _$BluRayItemImpl _value, $Res Function(_$BluRayItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of BluRayItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? year = freezed,
    Object? format = freezed,
    Object? upc = freezed,
    Object? movieUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? productId = freezed,
    Object? globalProductId = freezed,
    Object? globalParentId = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? endYear = freezed,
  }) {
    return _then(_$BluRayItemImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      format: freezed == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      upc: freezed == upc
          ? _value.upc
          : upc // ignore: cast_nullable_to_non_nullable
              as BigInt?,
      movieUrl: freezed == movieUrl
          ? _value.movieUrl
          : movieUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      globalProductId: freezed == globalProductId
          ? _value.globalProductId
          : globalProductId // ignore: cast_nullable_to_non_nullable
              as String?,
      globalParentId: freezed == globalParentId
          ? _value.globalParentId
          : globalParentId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      endYear: freezed == endYear
          ? _value.endYear
          : endYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BluRayItemImpl extends _BluRayItem {
  const _$BluRayItemImpl(
      {this.title,
      this.year,
      this.format,
      this.upc,
      this.movieUrl,
      this.coverImageUrl,
      this.productId,
      this.globalProductId,
      this.globalParentId,
      this.categoryId,
      this.category,
      this.endYear})
      : super._();

  factory _$BluRayItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BluRayItemImplFromJson(json);

  /// The title of the movie
  @override
  final String? title;

  /// The release year as an integer
  @override
  final int? year;

  /// Format type (Blu-ray, DVD, 4K, etc.)
  @override
  final String? format;

  /// Universal Product Code as a BigInt for proper numeric handling
  @override
  final BigInt? upc;

  /// URL to the movie's specific page on Blu-ray.com
  @override
  final String? movieUrl;

  /// URL to the movie cover image
  @override
  final String? coverImageUrl;

  /// Blu-ray.com product ID
  @override
  final String? productId;

  /// Blu-ray.com global product ID
  @override
  final String? globalProductId;

  /// Blu-ray.com global parent ID
  @override
  final String? globalParentId;

  /// Blu-ray.com category ID
  @override
  final String? categoryId;

  /// Derived category name from categoryId
  @override
  final String? category;

  /// End year for collections as an integer (null for ongoing collections)
  @override
  final int? endYear;

  @override
  String toString() {
    return 'BluRayItem(title: $title, year: $year, format: $format, upc: $upc, movieUrl: $movieUrl, coverImageUrl: $coverImageUrl, productId: $productId, globalProductId: $globalProductId, globalParentId: $globalParentId, categoryId: $categoryId, category: $category, endYear: $endYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BluRayItemImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.upc, upc) || other.upc == upc) &&
            (identical(other.movieUrl, movieUrl) ||
                other.movieUrl == movieUrl) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.globalProductId, globalProductId) ||
                other.globalProductId == globalProductId) &&
            (identical(other.globalParentId, globalParentId) ||
                other.globalParentId == globalParentId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.endYear, endYear) || other.endYear == endYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      year,
      format,
      upc,
      movieUrl,
      coverImageUrl,
      productId,
      globalProductId,
      globalParentId,
      categoryId,
      category,
      endYear);

  /// Create a copy of BluRayItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BluRayItemImplCopyWith<_$BluRayItemImpl> get copyWith =>
      __$$BluRayItemImplCopyWithImpl<_$BluRayItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BluRayItemImplToJson(
      this,
    );
  }
}

abstract class _BluRayItem extends BluRayItem {
  const factory _BluRayItem(
      {final String? title,
      final int? year,
      final String? format,
      final BigInt? upc,
      final String? movieUrl,
      final String? coverImageUrl,
      final String? productId,
      final String? globalProductId,
      final String? globalParentId,
      final String? categoryId,
      final String? category,
      final int? endYear}) = _$BluRayItemImpl;
  const _BluRayItem._() : super._();

  factory _BluRayItem.fromJson(Map<String, dynamic> json) =
      _$BluRayItemImpl.fromJson;

  /// The title of the movie
  @override
  String? get title;

  /// The release year as an integer
  @override
  int? get year;

  /// Format type (Blu-ray, DVD, 4K, etc.)
  @override
  String? get format;

  /// Universal Product Code as a BigInt for proper numeric handling
  @override
  BigInt? get upc;

  /// URL to the movie's specific page on Blu-ray.com
  @override
  String? get movieUrl;

  /// URL to the movie cover image
  @override
  String? get coverImageUrl;

  /// Blu-ray.com product ID
  @override
  String? get productId;

  /// Blu-ray.com global product ID
  @override
  String? get globalProductId;

  /// Blu-ray.com global parent ID
  @override
  String? get globalParentId;

  /// Blu-ray.com category ID
  @override
  String? get categoryId;

  /// Derived category name from categoryId
  @override
  String? get category;

  /// End year for collections as an integer (null for ongoing collections)
  @override
  int? get endYear;

  /// Create a copy of BluRayItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BluRayItemImplCopyWith<_$BluRayItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
