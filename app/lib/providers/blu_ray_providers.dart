import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blu_ray_item.dart';
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
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedFormatProvider = StateProvider<String>((ref) => 'All');
final selectedConditionProvider = StateProvider<String>((ref) => 'All');
final selectedWatchedProvider = StateProvider<String>((ref) => 'All');
final selectedWishlistProvider = StateProvider<String>((ref) => 'All');
final sortByProvider = StateProvider<String>((ref) => 'Title');
final sortOrderProvider = StateProvider<String>((ref) => 'Ascending');

/// Computed provider for filtered and sorted items
final filteredItemsProvider = Provider<List<BluRayItem>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedFormat = ref.watch(selectedFormatProvider);
  final selectedCondition = ref.watch(selectedConditionProvider);
  final selectedWatched = ref.watch(selectedWatchedProvider);
  final selectedWishlist = ref.watch(selectedWishlistProvider);
  final sortBy = ref.watch(sortByProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  logger.logState('Computing filtered items with search: "$searchQuery", category: "$selectedCategory", format: "$selectedFormat", condition: "$selectedCondition", watched: "$selectedWatched", wishlist: "$selectedWishlist", sort: "$sortBy $sortOrder"');

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

      // Apply condition filter
      if (selectedCondition != 'All') {
        filtered = filtered.where((item) => item.condition == selectedCondition).toList();
        logger.logState('Applied condition filter "$selectedCondition": ${filtered.length} items remaining');
      }

      // Apply watched filter
      if (selectedWatched != 'All') {
        filtered = filtered.where((item) => item.watched == selectedWatched).toList();
        logger.logState('Applied watched filter "$selectedWatched": ${filtered.length} items remaining');
      }

      // Apply wishlist filter
      if (selectedWishlist != 'All') {
        filtered = filtered.where((item) => item.wishlist == selectedWishlist).toList();
        logger.logState('Applied wishlist filter "$selectedWishlist": ${filtered.length} items remaining');
      }

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        filtered = filtered.where((item) =>
            (item.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (item.director?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (item.actors?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (item.genre?.toLowerCase().contains(lowercaseQuery) ?? false)).toList();
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
            compareResult = (a.year ?? '').compareTo(b.year ?? '');
            break;
          case 'Date Added':
            compareResult = (a.dateAdded ?? '').compareTo(b.dateAdded ?? '');
            break;
          case 'Director':
            compareResult = (a.director ?? '').compareTo(b.director ?? '');
            break;
          case 'Rating':
            compareResult = (a.rating ?? '').compareTo(b.rating ?? '');
            break;
          case 'Runtime':
            compareResult = (a.runtime ?? '').compareTo(b.runtime ?? '');
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

/// Provider for available conditions
final availableConditionsProvider = Provider<List<String>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);

  return collectionAsync.maybeWhen(
    data: (items) {
      final conditions = ['All', ...items
          .map((item) => item.condition ?? 'Unknown')
          .where((condition) => condition.isNotEmpty)
          .toSet()
          .toList()
          ..sort()];
      logger.logState('Available conditions: $conditions');
      return conditions;
    },
    orElse: () => ['All'],
  );
});

/// Provider for available watched statuses
final availableWatchedProvider = Provider<List<String>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);

  return collectionAsync.maybeWhen(
    data: (items) {
      final watched = ['All', ...items
          .map((item) => item.watched ?? 'Unknown')
          .where((w) => w.isNotEmpty)
          .toSet()
          .toList()
          ..sort()];
      logger.logState('Available watched statuses: $watched');
      return watched;
    },
    orElse: () => ['All'],
  );
});

/// Provider for available wishlist statuses
final availableWishlistProvider = Provider<List<String>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);

  return collectionAsync.maybeWhen(
    data: (items) {
      final wishlist = ['All', ...items
          .map((item) => item.wishlist ?? 'Unknown')
          .where((w) => w.isNotEmpty)
          .toSet()
          .toList()
          ..sort()];
      logger.logState('Available wishlist statuses: $wishlist');
      return wishlist;
    },
    orElse: () => ['All'],
  );
});

/// Provider for sort options
final sortOptionsProvider = Provider<List<String>>((ref) => [
  'Title',
  'Year',
  'Date Added',
  'Director',
  'Rating',
  'Runtime',
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
