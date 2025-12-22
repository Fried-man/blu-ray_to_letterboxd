// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieInfo _$MovieInfoFromJson(Map<String, dynamic> json) {
  return _MovieInfo.fromJson(json);
}

/// @nodoc
mixin _$MovieInfo {
  /// The original URL that was scraped
  String get url => throw _privateConstructorUsedError;

  /// Title of the movie/collection
  String get title => throw _privateConstructorUsedError;

  /// Year of release (for single movies) or start year (for collections)
  int? get year => throw _privateConstructorUsedError;

  /// End year for collections
  int? get endYear => throw _privateConstructorUsedError;

  /// Whether this is a collection containing multiple movies
  bool get isCollection => throw _privateConstructorUsedError;

  /// List of movies (for collections) or single movie info
  List<MovieItem> get movies => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this MovieInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieInfoCopyWith<MovieInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieInfoCopyWith<$Res> {
  factory $MovieInfoCopyWith(MovieInfo value, $Res Function(MovieInfo) then) =
      _$MovieInfoCopyWithImpl<$Res, MovieInfo>;
  @useResult
  $Res call({
    String url,
    String title,
    int? year,
    int? endYear,
    bool isCollection,
    List<MovieItem> movies,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$MovieInfoCopyWithImpl<$Res, $Val extends MovieInfo>
    implements $MovieInfoCopyWith<$Res> {
  _$MovieInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? title = null,
    Object? year = freezed,
    Object? endYear = freezed,
    Object? isCollection = null,
    Object? movies = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            year: freezed == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int?,
            endYear: freezed == endYear
                ? _value.endYear
                : endYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            isCollection: null == isCollection
                ? _value.isCollection
                : isCollection // ignore: cast_nullable_to_non_nullable
                      as bool,
            movies: null == movies
                ? _value.movies
                : movies // ignore: cast_nullable_to_non_nullable
                      as List<MovieItem>,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieInfoImplCopyWith<$Res>
    implements $MovieInfoCopyWith<$Res> {
  factory _$$MovieInfoImplCopyWith(
    _$MovieInfoImpl value,
    $Res Function(_$MovieInfoImpl) then,
  ) = __$$MovieInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String url,
    String title,
    int? year,
    int? endYear,
    bool isCollection,
    List<MovieItem> movies,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$MovieInfoImplCopyWithImpl<$Res>
    extends _$MovieInfoCopyWithImpl<$Res, _$MovieInfoImpl>
    implements _$$MovieInfoImplCopyWith<$Res> {
  __$$MovieInfoImplCopyWithImpl(
    _$MovieInfoImpl _value,
    $Res Function(_$MovieInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? title = null,
    Object? year = freezed,
    Object? endYear = freezed,
    Object? isCollection = null,
    Object? movies = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$MovieInfoImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        year: freezed == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int?,
        endYear: freezed == endYear
            ? _value.endYear
            : endYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        isCollection: null == isCollection
            ? _value.isCollection
            : isCollection // ignore: cast_nullable_to_non_nullable
                  as bool,
        movies: null == movies
            ? _value._movies
            : movies // ignore: cast_nullable_to_non_nullable
                  as List<MovieItem>,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieInfoImpl implements _MovieInfo {
  const _$MovieInfoImpl({
    required this.url,
    required this.title,
    this.year,
    this.endYear,
    this.isCollection = false,
    required final List<MovieItem> movies,
    final Map<String, dynamic>? metadata,
  }) : _movies = movies,
       _metadata = metadata;

  factory _$MovieInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieInfoImplFromJson(json);

  /// The original URL that was scraped
  @override
  final String url;

  /// Title of the movie/collection
  @override
  final String title;

  /// Year of release (for single movies) or start year (for collections)
  @override
  final int? year;

  /// End year for collections
  @override
  final int? endYear;

  /// Whether this is a collection containing multiple movies
  @override
  @JsonKey()
  final bool isCollection;

  /// List of movies (for collections) or single movie info
  final List<MovieItem> _movies;

  /// List of movies (for collections) or single movie info
  @override
  List<MovieItem> get movies {
    if (_movies is EqualUnmodifiableListView) return _movies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_movies);
  }

  /// Additional metadata
  final Map<String, dynamic>? _metadata;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MovieInfo(url: $url, title: $title, year: $year, endYear: $endYear, isCollection: $isCollection, movies: $movies, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieInfoImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.endYear, endYear) || other.endYear == endYear) &&
            (identical(other.isCollection, isCollection) ||
                other.isCollection == isCollection) &&
            const DeepCollectionEquality().equals(other._movies, _movies) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    url,
    title,
    year,
    endYear,
    isCollection,
    const DeepCollectionEquality().hash(_movies),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of MovieInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieInfoImplCopyWith<_$MovieInfoImpl> get copyWith =>
      __$$MovieInfoImplCopyWithImpl<_$MovieInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieInfoImplToJson(this);
  }
}

abstract class _MovieInfo implements MovieInfo {
  const factory _MovieInfo({
    required final String url,
    required final String title,
    final int? year,
    final int? endYear,
    final bool isCollection,
    required final List<MovieItem> movies,
    final Map<String, dynamic>? metadata,
  }) = _$MovieInfoImpl;

  factory _MovieInfo.fromJson(Map<String, dynamic> json) =
      _$MovieInfoImpl.fromJson;

  /// The original URL that was scraped
  @override
  String get url;

  /// Title of the movie/collection
  @override
  String get title;

  /// Year of release (for single movies) or start year (for collections)
  @override
  int? get year;

  /// End year for collections
  @override
  int? get endYear;

  /// Whether this is a collection containing multiple movies
  @override
  bool get isCollection;

  /// List of movies (for collections) or single movie info
  @override
  List<MovieItem> get movies;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of MovieInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieInfoImplCopyWith<_$MovieInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MovieItem _$MovieItemFromJson(Map<String, dynamic> json) {
  return _MovieItem.fromJson(json);
}

/// @nodoc
mixin _$MovieItem {
  /// Movie title
  String get title => throw _privateConstructorUsedError;

  /// Release year
  int? get year => throw _privateConstructorUsedError;

  /// End year for collections
  int? get endYear => throw _privateConstructorUsedError;

  /// Blu-ray.com movie URL
  String? get url => throw _privateConstructorUsedError;

  /// Cover image URL
  String? get coverImageUrl => throw _privateConstructorUsedError;

  /// Format (Blu-ray, 4K, DVD, etc.)
  List<String>? get format => throw _privateConstructorUsedError;

  /// UPC code
  BigInt? get upc => throw _privateConstructorUsedError;

  /// Additional movie metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this MovieItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieItemCopyWith<MovieItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieItemCopyWith<$Res> {
  factory $MovieItemCopyWith(MovieItem value, $Res Function(MovieItem) then) =
      _$MovieItemCopyWithImpl<$Res, MovieItem>;
  @useResult
  $Res call({
    String title,
    int? year,
    int? endYear,
    String? url,
    String? coverImageUrl,
    List<String>? format,
    BigInt? upc,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$MovieItemCopyWithImpl<$Res, $Val extends MovieItem>
    implements $MovieItemCopyWith<$Res> {
  _$MovieItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? year = freezed,
    Object? endYear = freezed,
    Object? url = freezed,
    Object? coverImageUrl = freezed,
    Object? format = freezed,
    Object? upc = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            year: freezed == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int?,
            endYear: freezed == endYear
                ? _value.endYear
                : endYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            format: freezed == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            upc: freezed == upc
                ? _value.upc
                : upc // ignore: cast_nullable_to_non_nullable
                      as BigInt?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieItemImplCopyWith<$Res>
    implements $MovieItemCopyWith<$Res> {
  factory _$$MovieItemImplCopyWith(
    _$MovieItemImpl value,
    $Res Function(_$MovieItemImpl) then,
  ) = __$$MovieItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    int? year,
    int? endYear,
    String? url,
    String? coverImageUrl,
    List<String>? format,
    BigInt? upc,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$MovieItemImplCopyWithImpl<$Res>
    extends _$MovieItemCopyWithImpl<$Res, _$MovieItemImpl>
    implements _$$MovieItemImplCopyWith<$Res> {
  __$$MovieItemImplCopyWithImpl(
    _$MovieItemImpl _value,
    $Res Function(_$MovieItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? year = freezed,
    Object? endYear = freezed,
    Object? url = freezed,
    Object? coverImageUrl = freezed,
    Object? format = freezed,
    Object? upc = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$MovieItemImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        year: freezed == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int?,
        endYear: freezed == endYear
            ? _value.endYear
            : endYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        format: freezed == format
            ? _value._format
            : format // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        upc: freezed == upc
            ? _value.upc
            : upc // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieItemImpl implements _MovieItem {
  const _$MovieItemImpl({
    required this.title,
    this.year,
    this.endYear,
    this.url,
    this.coverImageUrl,
    final List<String>? format,
    this.upc,
    final Map<String, dynamic>? metadata,
  }) : _format = format,
       _metadata = metadata;

  factory _$MovieItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieItemImplFromJson(json);

  /// Movie title
  @override
  final String title;

  /// Release year
  @override
  final int? year;

  /// End year for collections
  @override
  final int? endYear;

  /// Blu-ray.com movie URL
  @override
  final String? url;

  /// Cover image URL
  @override
  final String? coverImageUrl;

  /// Format (Blu-ray, 4K, DVD, etc.)
  final List<String>? _format;

  /// Format (Blu-ray, 4K, DVD, etc.)
  @override
  List<String>? get format {
    final value = _format;
    if (value == null) return null;
    if (_format is EqualUnmodifiableListView) return _format;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// UPC code
  @override
  final BigInt? upc;

  /// Additional movie metadata
  final Map<String, dynamic>? _metadata;

  /// Additional movie metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MovieItem(title: $title, year: $year, endYear: $endYear, url: $url, coverImageUrl: $coverImageUrl, format: $format, upc: $upc, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieItemImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.endYear, endYear) || other.endYear == endYear) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality().equals(other._format, _format) &&
            (identical(other.upc, upc) || other.upc == upc) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    year,
    endYear,
    url,
    coverImageUrl,
    const DeepCollectionEquality().hash(_format),
    upc,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of MovieItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieItemImplCopyWith<_$MovieItemImpl> get copyWith =>
      __$$MovieItemImplCopyWithImpl<_$MovieItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieItemImplToJson(this);
  }
}

abstract class _MovieItem implements MovieItem {
  const factory _MovieItem({
    required final String title,
    final int? year,
    final int? endYear,
    final String? url,
    final String? coverImageUrl,
    final List<String>? format,
    final BigInt? upc,
    final Map<String, dynamic>? metadata,
  }) = _$MovieItemImpl;

  factory _MovieItem.fromJson(Map<String, dynamic> json) =
      _$MovieItemImpl.fromJson;

  /// Movie title
  @override
  String get title;

  /// Release year
  @override
  int? get year;

  /// End year for collections
  @override
  int? get endYear;

  /// Blu-ray.com movie URL
  @override
  String? get url;

  /// Cover image URL
  @override
  String? get coverImageUrl;

  /// Format (Blu-ray, 4K, DVD, etc.)
  @override
  List<String>? get format;

  /// UPC code
  @override
  BigInt? get upc;

  /// Additional movie metadata
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of MovieItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieItemImplCopyWith<_$MovieItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
