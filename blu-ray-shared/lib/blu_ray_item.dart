import 'package:freezed_annotation/freezed_annotation.dart';

part 'blu_ray_item.freezed.dart';
part 'blu_ray_item.g.dart';

/// DTO representing a movie item extracted from the Blu-ray.com search endpoint
/// Contains only the fields that are actually populated from search results
@freezed
class BluRayItem with _$BluRayItem {
  const factory BluRayItem({
    /// The title of the movie
    String? title,

    /// The release year as an integer
    int? year,

    /// Format type (Blu-ray, DVD, 4K, etc.)
    String? format,

    /// Universal Product Code as a BigInt for proper numeric handling
    BigInt? upc,

    /// URL to the movie's specific page on Blu-ray.com
    String? movieUrl,

    /// URL to the movie cover image
    String? coverImageUrl,

    /// Blu-ray.com product ID
    String? productId,

    /// Blu-ray.com global product ID
    String? globalProductId,

    /// Blu-ray.com global parent ID
    String? globalParentId,

    /// Blu-ray.com category ID
    String? categoryId,

    /// End year for collections as an integer (null for ongoing collections)
    int? endYear,
  }) = _BluRayItem;

  /// Creates a BluRayItem from JSON
  factory BluRayItem.fromJson(Map<String, dynamic> json) =>
      _$BluRayItemFromJson(json);

  /// Empty constructor for creating instances without parameters
  const BluRayItem._();
}
