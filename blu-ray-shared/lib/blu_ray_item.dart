import 'package:freezed_annotation/freezed_annotation.dart';

part 'blu_ray_item.freezed.dart';
part 'blu_ray_item.g.dart';

/// Parses format information from a Blu-ray.com movie URL
/// Returns a list of formats found in the URL (e.g., ['4K', 'Blu-ray'])
List<String> parseFormatsFromUrl(String? url) {
  if (url == null || url.isEmpty) return [];

  final formats = <String>[];

  // Convert URL to lowercase for case-insensitive matching
  final lowerUrl = url.toLowerCase();

  // Check for 4K format
  if (lowerUrl.contains('-4k-')) {
    formats.add('4K');
  }

  // Check for Blu-ray format
  if (lowerUrl.contains('-blu-ray')) {
    formats.add('Blu-ray');
  }

  // Check for DVD format
  if (lowerUrl.contains('-dvd')) {
    formats.add('DVD');
  }

  // Check for other formats that might appear
  if (lowerUrl.contains('-bluray')) {
    if (!formats.contains('Blu-ray')) {
      formats.add('Blu-ray');
    }
  }

  return formats;
}


/// DTO representing a movie item extracted from the Blu-ray.com search endpoint
/// Contains only the fields that are actually populated from search results
@freezed
class BluRayItem with _$BluRayItem {
  const factory BluRayItem({
    /// The title of the movie
    String? title,

    /// The release year as an integer
    int? year,

    /// Format types (Blu-ray, DVD, 4K, etc.) - derived from URL
    List<String>? format,

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

    /// Type of media: "movie", "collection", or "tv_show"
    String? mediaType,
  }) = _BluRayItem;

  /// Creates a BluRayItem from JSON
  factory BluRayItem.fromJson(Map<String, dynamic> json) =>
      _$BluRayItemFromJson(json);

  /// Creates a BluRayItem from JSON with format automatically parsed from URL
  factory BluRayItem.fromJsonWithParsedFormat(Map<String, dynamic> json) {
    // Always parse format from URL for more accurate detection
    final parsedFormats = parseFormatsFromUrl(json['movieUrl'] as String?);

    // Preprocess the JSON to ensure format is a list and merge with URL parsing
    final processedJson = Map<String, dynamic>.from(json);
    final rawFormat = json['format'];

    List<String>? finalFormats;
    if (parsedFormats.isNotEmpty) {
      // Use URL-parsed formats as the base
      finalFormats = parsedFormats;
      // If JSON also has format data, merge it
      if (rawFormat is String && rawFormat.isNotEmpty && !finalFormats.contains(rawFormat)) {
        finalFormats.add(rawFormat);
      }
    } else if (rawFormat is String && rawFormat.isNotEmpty) {
      // Fall back to JSON format if URL parsing didn't work
      finalFormats = [rawFormat];
    }

    processedJson['format'] = finalFormats;

    return _$BluRayItemFromJson(processedJson);
  }

  /// Empty constructor for creating instances without parameters
  const BluRayItem._();
}