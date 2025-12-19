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

/// Computed provider for filtered items
final filteredItemsProvider = Provider<List<BluRayItem>>((ref) {
  final collectionAsync = ref.watch(collectionStateProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedFormat = ref.watch(selectedFormatProvider);

  logger.logState('Computing filtered items with search: "$searchQuery", category: "$selectedCategory", format: "$selectedFormat"');

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

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        filtered = filtered.where((item) =>
            item.title?.toLowerCase().contains(lowercaseQuery) ?? false).toList();
        logger.logState('Applied search filter "$searchQuery": ${filtered.length} items remaining');
      }

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
