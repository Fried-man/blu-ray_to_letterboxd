import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_progress.freezed.dart';
part 'collection_progress.g.dart';

/// Progress event types for collection fetching
enum ProgressEventType {
  /// Started fetching collection
  started,

  /// Processing a specific page
  pageStarted,

  /// Completed processing a page
  pageCompleted,

  /// Found new items on a page
  itemsFound,

  /// Completed fetching entire collection
  completed,

  /// Error occurred during fetching
  error,
}

/// Progress information for collection fetching operations
@freezed
class CollectionProgress with _$CollectionProgress {
  const factory CollectionProgress({
    /// Type of progress event
    required ProgressEventType type,

    /// Current page being processed (null for non-page events)
    int? currentPage,

    /// Total pages discovered so far (null if unknown)
    int? totalPages,

    /// Number of items processed on current page
    int? itemsOnCurrentPage,

    /// Total unique items found so far
    required int totalItemsFound,

    /// Progress percentage (0.0 to 1.0, null if indeterminate)
    double? progressPercentage,

    /// Optional message describing current operation
    String? message,

    /// Error message if type is error
    String? error,
  }) = _CollectionProgress;

  /// Creates a CollectionProgress from JSON
  factory CollectionProgress.fromJson(Map<String, dynamic> json) =>
      _$CollectionProgressFromJson(json);

  /// Convenience constructor for started event
  factory CollectionProgress.started() => const CollectionProgress(
        type: ProgressEventType.started,
        totalItemsFound: 0,
        message: 'Starting collection fetch...',
      );

  /// Convenience constructor for page started event
  factory CollectionProgress.pageStarted(int page) => CollectionProgress(
        type: ProgressEventType.pageStarted,
        currentPage: page,
        totalItemsFound: 0, // Will be updated as pages complete
        message: 'Processing page $page...',
      );

  /// Convenience constructor for page completed event
  factory CollectionProgress.pageCompleted(int page, int itemsFound, int totalItems) => CollectionProgress(
        type: ProgressEventType.pageCompleted,
        currentPage: page,
        itemsOnCurrentPage: itemsFound,
        totalItemsFound: totalItems,
        message: 'Completed page $page, found $itemsFound items',
      );

  /// Convenience constructor for items found event
  factory CollectionProgress.itemsFound(int totalItems, {int? currentPage, int? totalPages}) => CollectionProgress(
        type: ProgressEventType.itemsFound,
        currentPage: currentPage,
        totalPages: totalPages,
        totalItemsFound: totalItems,
        progressPercentage: totalPages != null ? (currentPage ?? 0) / totalPages : null,
        message: 'Found $totalItems total items${currentPage != null ? ' on page $currentPage' : ''}',
      );

  /// Convenience constructor for completed event
  factory CollectionProgress.completed(int totalItems) => CollectionProgress(
        type: ProgressEventType.completed,
        totalItemsFound: totalItems,
        progressPercentage: 1.0,
        message: 'Collection fetch completed! Found $totalItems items',
      );

  /// Convenience constructor for error event
  factory CollectionProgress.error(String errorMessage, {int? totalItemsFound}) => CollectionProgress(
        type: ProgressEventType.error,
        totalItemsFound: totalItemsFound ?? 0,
        error: errorMessage,
        message: 'Error: $errorMessage',
      );
}
