import 'blu_ray_scraper.dart';
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../utils/logger.dart';

/// Service for managing Blu-ray collection data fetching and processing
class BluRayCollectionService {
  final BluRayScraper _scraper = BluRayScraper();

  /// Fetches the complete Blu-ray collection for a user
  ///
  /// Throws exceptions for network errors, invalid user IDs, or access issues
  Future<List<BluRayItem>> fetchCollection(String userId) async {
    logger.logScraper('Collection service: Starting fetch for user ID: $userId');

    // Validate user ID
    if (!_scraper.isValidUserId(userId)) {
      logger.logScraper('Invalid user ID format: $userId');
      throw InvalidUserIdException('Invalid user ID format: $userId');
    }

    try {
      final items = await _scraper.fetchCollection(userId);
      logger.logScraper('Collection service: Successfully fetched ${items.length} items for user $userId');
      return items;
    } on Exception catch (e) {
      logger.logScraper('Collection service: Fetch failed for user $userId', error: e);

      if (e.toString().contains('Access blocked') ||
          e.toString().contains('private') ||
          e.toString().contains('login')) {
        logger.logScraper('Collection access blocked for user $userId');
        throw CollectionAccessException(
          'Unable to access collection. The collection might be private or you may need to be logged in.',
        );
      }
      rethrow;
    }
  }

  /// Validates if a user ID format is valid
  bool isValidUserId(String userId) {
    return _scraper.isValidUserId(userId);
  }

  /// Filters items by format
  List<BluRayItem> filterByFormat(List<BluRayItem> items, String format) {
    if (format == 'All' || format.isEmpty) {
      return items;
    }
    return items.where((item) => item.format == format).toList();
  }

  /// Searches items by title
  List<BluRayItem> searchByTitle(List<BluRayItem> items, String query) {
    if (query.isEmpty) return items;

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) =>
        item.title?.toLowerCase().contains(lowercaseQuery) ?? false).toList();
  }

  /// Gets all unique formats from the collection
  List<String> getFormats(List<BluRayItem> items) {
    final formats = items
        .map((item) => item.format ?? 'Unknown')
        .where((format) => format.isNotEmpty)
        .toSet()
        .toList();
    formats.sort();
    return formats;
  }
}

/// Exception thrown when user ID is invalid
class InvalidUserIdException implements Exception {
  final String message;
  InvalidUserIdException(this.message);

  @override
  String toString() => 'InvalidUserIdException: $message';
}

/// Exception thrown when collection access is blocked
class CollectionAccessException implements Exception {
  final String message;
  CollectionAccessException(this.message);

  @override
  String toString() => 'CollectionAccessException: $message';
}
