import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_info.freezed.dart';
part 'movie_info.g.dart';

/// Represents information about a movie or collection from Blu-ray.com
@freezed
class MovieInfo with _$MovieInfo {
  const factory MovieInfo({
    /// The original URL that was scraped
    required String url,

    /// Title of the movie/collection
    required String title,

    /// Year of release (for single movies) or start year (for collections)
    int? year,

    /// End year for collections
    int? endYear,

    /// Whether this is a collection containing multiple movies
    @Default(false) bool isCollection,

    /// List of movies (for collections) or single movie info
    required List<MovieItem> movies,

    /// Additional metadata
    Map<String, dynamic>? metadata,
  }) = _MovieInfo;

  factory MovieInfo.fromJson(Map<String, dynamic> json) =>
      _$MovieInfoFromJson(json);
}

/// Individual movie item within a collection or standalone movie
@freezed
class MovieItem with _$MovieItem {
  const factory MovieItem({
    /// Movie title
    required String title,

    /// Release year
    int? year,

    /// End year for collections
    int? endYear,

    /// Blu-ray.com movie URL
    String? url,

    /// Cover image URL
    String? coverImageUrl,

    /// Format (Blu-ray, 4K, DVD, etc.)
    List<String>? format,

    /// UPC code
    BigInt? upc,

    /// Additional movie metadata
    Map<String, dynamic>? metadata,
  }) = _MovieItem;

  factory MovieItem.fromJson(Map<String, dynamic> json) =>
      _$MovieItemFromJson(json);
}
