import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blu_ray_shared/blu_ray_item.dart';

/// Utility class for exporting Blu-ray collections to Letterboxd CSV format
class CsvExportUtils {
  static const String _apiBaseUrl = 'http://localhost:3003';

  /// Converts a list of BluRayItem to Letterboxd CSV format string
  /// Handles collections by fetching individual movies and replacing collection rows
  static Future<String> convertToLetterboxdCsv(
    List<BluRayItem> items, {
    void Function(String message, int current, int total)? onProgress,
  }) async {
    final buffer = StringBuffer();

    // CSV Header - Letterboxd import format
    buffer.writeln('Title,Year,Directors,Rating,WatchedDate,Tags');

    onProgress?.call('Starting CSV export...', 0, items.length);

    // Process each item
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      onProgress?.call('Processing "${item.title ?? 'Unknown'}"...', i, items.length);

      // Check if this is a collection (has both start and end year)
      if (item.year != null && item.endYear != null) {
        // This is a collection - fetch individual movies
        final movieRows = await _processCollectionItem(item, onProgress: onProgress);
        for (final row in movieRows) {
          buffer.writeln(row);
        }
      } else {
        // This is a regular movie - create single row
        final row = _createCsvRow(item);
        buffer.writeln(row);
      }

      onProgress?.call('Completed "${item.title ?? 'Unknown'}" (${i + 1}/${items.length})', i + 1, items.length);
    }

    onProgress?.call('Export complete!', items.length, items.length);
    return buffer.toString();
  }

  /// Processes a collection item by fetching movie details and creating rows for individual movies
  static Future<List<String>> _processCollectionItem(
    BluRayItem collectionItem, {
    void Function(String message, int current, int total)? onProgress,
  }) async {
    final rows = <String>[];

    try {
      if (collectionItem.movieUrl == null || collectionItem.movieUrl!.isEmpty) {
        // No URL to fetch from - fall back to original item
        rows.add(_createCsvRow(collectionItem));
        return rows;
      }

      // Fetch movie info from API
      onProgress?.call('Fetching collection details for "${collectionItem.title}"...', 0, 1);
      final movieInfo = await _fetchMovieInfo(collectionItem.movieUrl!);
      onProgress?.call('Processing collection movies...', 1, 1);

      if (movieInfo.isCollection && movieInfo.movies.isNotEmpty) {
        // Create a row for each individual movie in the collection
        for (final movie in movieInfo.movies) {
          // Create a BluRayItem-like object from the MovieItem for consistent processing
          final movieAsItem = BluRayItem(
            title: movie.title,
            year: movie.year,
            endYear: movie.endYear,
            format: collectionItem.format, // Use the collection's format
            upc: movie.upc,
            movieUrl: movie.url,
            coverImageUrl: movie.coverImageUrl,
            productId: null,
            globalProductId: null,
            globalParentId: null,
            categoryId: null,
          );

          rows.add(_createCsvRow(movieAsItem));
        }
      } else {
        // Not a collection or no movies found - fall back to original item
        rows.add(_createCsvRow(collectionItem));
      }
    } catch (e) {
      print('Error processing collection ${collectionItem.title}: $e');
      // On error, fall back to original item
      rows.add(_createCsvRow(collectionItem));
    }

    return rows;
  }

  /// Fetches movie info from the API
  static Future<MovieInfo> _fetchMovieInfo(String movieUrl) async {
    final encodedUrl = Uri.encodeComponent(movieUrl);
    final url = Uri.parse('$_apiBaseUrl/api/movie?url=$encodedUrl');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MovieInfo.fromJson(data);
    } else {
      throw Exception('Failed to fetch movie info: ${response.statusCode} ${response.body}');
    }
  }

  /// Creates a single CSV row for a BluRayItem
  static String _createCsvRow(BluRayItem item) {
    final title = _escapeCsvField(item.title ?? '');
    final year = item.year?.toString() ?? '';
    final directors = ''; // Not available in current data model
    final rating = ''; // Not available - user would need to add manually
    final watchedDate = ''; // Not available - user would need to add manually

    // Create tags from format information
    final tags = _createTagsFromFormats(item.format);

    return '$title,$year,$directors,$rating,$watchedDate,$tags';
  }

  /// Creates tags string from format list
  static String _createTagsFromFormats(List<String>? formats) {
    if (formats == null || formats.isEmpty) return '';

    // Filter out common formats and create tags
    final tags = <String>[];
    for (final format in formats) {
      switch (format.toLowerCase()) {
        case '4k':
          tags.add('4K');
          break;
        case 'blu-ray':
          tags.add('Blu-ray');
          break;
        case 'dvd':
          tags.add('DVD');
          break;
        default:
          // Keep other formats as-is
          tags.add(format);
      }
    }

    return _escapeCsvField(tags.join(', '));
  }


  /// Escapes CSV field values according to CSV standards
  static String _escapeCsvField(String value) {
    // If the value contains comma, quote, or newline, wrap in quotes
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      // Escape quotes by doubling them
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

/// Represents information about a movie or collection from Blu-ray.com
class MovieInfo {
  final String url;
  final String title;
  final int? year;
  final int? endYear;
  final bool isCollection;
  final List<MovieItem> movies;
  final Map<String, dynamic>? metadata;

  MovieInfo({
    required this.url,
    required this.title,
    this.year,
    this.endYear,
    this.isCollection = false,
    required this.movies,
    this.metadata,
  });

  factory MovieInfo.fromJson(Map<String, dynamic> json) {
    return MovieInfo(
      url: json['url'] as String,
      title: json['title'] as String,
      year: json['year'] as int?,
      endYear: json['endYear'] as int?,
      isCollection: json['isCollection'] as bool? ?? false,
      movies: (json['movies'] as List<dynamic>?)
          ?.map((item) => MovieItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Individual movie item within a collection or standalone movie
class MovieItem {
  final String title;
  final int? year;
  final int? endYear;
  final String? url;
  final String? coverImageUrl;
  final List<String>? format;
  final BigInt? upc;
  final Map<String, dynamic>? metadata;

  MovieItem({
    required this.title,
    this.year,
    this.endYear,
    this.url,
    this.coverImageUrl,
    this.format,
    this.upc,
    this.metadata,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      title: json['title'] as String,
      year: json['year'] as int?,
      endYear: json['endYear'] as int?,
      url: json['url'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      format: (json['format'] as List<dynamic>?)?.cast<String>(),
      upc: json['upc'] != null ? BigInt.parse(json['upc'].toString()) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
