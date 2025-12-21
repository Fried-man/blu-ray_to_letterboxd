import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../services/blu_ray_collection_service.dart';
import '../utils/logger.dart';

/// Service provider
final bluRayServiceProvider = Provider<BluRayCollectionService>((ref) {
  logger.logState('Creating BluRayCollectionService instance');
  return BluRayCollectionService();
});

/// Provider for current user ID
final userIdProvider = StateProvider<String>((ref) => '');

/// Cache provider for storing collection data across rebuilds
final collectionCacheProvider = StateNotifierProvider<CollectionCacheNotifier, Map<String, AsyncValue<List<BluRayItem>>>>((ref) {
  logger.logState('Creating CollectionCacheNotifier');
  return CollectionCacheNotifier();
});

/// State for the collection fetch operation
final collectionStateProvider = StateNotifierProvider<CollectionNotifier, AsyncValue<List<BluRayItem>>>((ref) {
  final service = ref.watch(bluRayServiceProvider);
  logger.logState('Creating CollectionNotifier');
  return CollectionNotifier(service);
});

/// State for filtering and searching
/// Note: Only filters that work with API data are enabled
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedFormatProvider = StateProvider<String>((ref) => 'All');
// Disabled filters - not available in API data
// final selectedConditionProvider = StateProvider<String>((ref) => 'All');
// final selectedWatchedProvider = StateProvider<String>((ref) => 'All');
// final selectedWishlistProvider = StateProvider<String>((ref) => 'All');
final sortByProvider = StateProvider<String>((ref) => 'Title');
final sortOrderProvider = StateProvider<String>((ref) => 'Ascending');

/// Computed provider for filtered and sorted items
final filteredItemsProvider = Provider<List<BluRayItem>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedFormat = ref.watch(selectedFormatProvider);
  // Note: condition, watched, wishlist filters disabled - not in API data
  final sortBy = ref.watch(sortByProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  logger.logState('Computing filtered items with search: "$searchQuery", category: "$selectedCategory", format: "$selectedFormat", sort: "$sortBy $sortOrder"');

  return collectionAsync.maybeWhen(
    data: (items) {
      var filtered = items;

      // Apply category filter
      if (selectedCategory != 'All') {
        filtered = filtered.where((item) => item.category == selectedCategory).toList();
        logger.logState('Applied category filter "$selectedCategory": ${filtered.length} items remaining');
      }

      // Apply format filter
      if (selectedFormat != 'All') {
        filtered = filtered.where((item) => item.format == selectedFormat).toList();
        logger.logState('Applied format filter "$selectedFormat": ${filtered.length} items remaining');
      }

      // Note: condition, watched, wishlist filters removed - not available in API data

      // Apply search filter - only search in available fields
      if (searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        filtered = filtered.where((item) =>
            (item.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (item.year?.toString().toLowerCase().contains(lowercaseQuery) ?? false) ||
            (item.format?.toLowerCase().contains(lowercaseQuery) ?? false)).toList();
        logger.logState('Applied search filter "$searchQuery": ${filtered.length} items remaining');
      }

      // Apply sorting
      filtered.sort((a, b) {
        int compareResult = 0;

        switch (sortBy) {
          case 'Title':
            compareResult = (a.title ?? '').compareTo(b.title ?? '');
            break;
          case 'Year':
            // Numeric sorting for years (already int type)
            compareResult = (a.year ?? 0).compareTo(b.year ?? 0);
            break;
          case 'Format':
            compareResult = (a.format ?? '').compareTo(b.format ?? '');
            break;
          case 'UPC':
            // Numeric sorting for UPC (already BigInt type)
            compareResult = (a.upc ?? BigInt.zero).compareTo(b.upc ?? BigInt.zero);
            break;
          default:
            compareResult = (a.title ?? '').compareTo(b.title ?? '');
        }

        return sortOrder == 'Ascending' ? compareResult : -compareResult;
      });

      return filtered;
    },
    orElse: () => [],
  );
});

/// Provider for collection summary
final collectionSummaryProvider = Provider<Map<String, int>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);

  return collectionAsync.maybeWhen(
    data: (items) {
      final summary = <String, int>{};
      for (final item in items) {
        final category = item.category ?? 'Uncategorized';
        summary[category] = (summary[category] ?? 0) + 1;
      }
      logger.logState('Generated collection summary: $summary');
      return summary;
    },
    orElse: () => {},
  );
});

/// Provider for available categories
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final summary = ref.watch(collectionSummaryProvider);
  final categories = ['All', ...summary.keys.toList()..sort()];
  logger.logState('Available categories: $categories');
  return categories;
});

/// Provider for available formats
final availableFormatsProvider = Provider<List<String>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);

  return collectionAsync.maybeWhen(
    data: (items) {
      final formats = ['All', ...items
          .map((item) => item.format ?? 'Unknown')
          .where((format) => format.isNotEmpty)
          .toSet()
          .toList()
          ..sort()];
      logger.logState('Available formats: $formats');
      return formats;
    },
    orElse: () => ['All'],
  );
});

// Note: condition, watched, wishlist providers removed - not available in API data
// Keeping only for reference in case these fields are added later
// final availableConditionsProvider = Provider<List<String>>((ref) => ['All']);
// final availableWatchedProvider = Provider<List<String>>((ref) => ['All']);
// final availableWishlistProvider = Provider<List<String>>((ref) => ['All']);

/// Provider for sort options (only available fields from API)
final sortOptionsProvider = Provider<List<String>>((ref) => [
  'Title',
  'Year',
  'Format',
  'UPC',
]);

/// Provider for sort order options
final sortOrderOptionsProvider = Provider<List<String>>((ref) => [
  'Ascending',
  'Descending',
]);

/// Notifier for collection state management
class CollectionNotifier extends StateNotifier<AsyncValue<List<BluRayItem>>> {
  final BluRayCollectionService _service;

  CollectionNotifier(this._service) : super(const AsyncValue.loading()) {
    logger.logState('CollectionNotifier initialized');
  }

  /// Fetch collection for a user
  Future<void> fetchCollection(String userId) async {
    logger.logState('CollectionNotifier: Starting fetch for user $userId');
    state = const AsyncValue.loading();

    try {
      final items = await _service.fetchCollection(userId);
      state = AsyncValue.data(items);
      logger.logState('CollectionNotifier: Successfully loaded ${items.length} items');
    } catch (error, stackTrace) {
      logger.logState('CollectionNotifier: Failed to load collection', error: error);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear the current collection
  void clearCollection() {
    logger.logState('CollectionNotifier: Clearing collection');
    state = const AsyncValue.data([]);
  }

  /// Reset to initial loading state
  void reset() {
    logger.logState('CollectionNotifier: Resetting to initial state');
    state = const AsyncValue.loading();
  }
}

/// Notifier for collection caching
class CollectionCacheNotifier extends StateNotifier<Map<String, AsyncValue<List<BluRayItem>>>> {
  CollectionCacheNotifier() : super({}) {
    logger.logState('CollectionCacheNotifier initialized');
  }

  /// Get cached collection for a user
  AsyncValue<List<BluRayItem>>? getCachedCollection(String userId) {
    return state[userId];
  }

  /// Cache collection data for a user
  void cacheCollection(String userId, AsyncValue<List<BluRayItem>> collection) {
    state = {...state, userId: collection};
    logger.logState('Cached collection for user $userId: ${collection.maybeWhen(
      data: (items) => '${items.length} items',
      loading: () => 'loading',
      error: (error, _) => 'error: $error',
      orElse: () => 'unknown',
    )}');
  }

  /// Clear cache for a specific user
  void clearUserCache(String userId) {
    state = {...state}..remove(userId);
    logger.logState('Cleared cache for user $userId');
  }

  /// Clear all cached data
  void clearAllCache() {
    state = {};
    logger.logState('Cleared all cached collections');
  }

  /// Check if user has cached data
  bool hasCachedData(String userId) {
    return state.containsKey(userId) &&
           state[userId] != null &&
           state[userId]!.isRefreshing == false &&
           state[userId]!.hasValue;
  }
}
