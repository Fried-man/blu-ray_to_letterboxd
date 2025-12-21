import 'package:blu_ray_shared/blu_ray_item.dart';

/// Controller for collection operations
class CollectionController {
  /// Filters items based on search query
  List<BluRayItem> filterItems(List<BluRayItem> items, String query) {
    if (query.isEmpty) return items;

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) =>
        (item.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (item.year?.toString().toLowerCase().contains(lowercaseQuery) ?? false) ||
        (item.format?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (item.upc?.toString().toLowerCase().contains(lowercaseQuery) ?? false)).toList();
  }

  /// Sorts items based on criteria
  List<BluRayItem> sortItems(List<BluRayItem> items, String sortBy, String sortOrder) {
    final sorted = List<BluRayItem>.from(items);
    sorted.sort((a, b) {
      int compareResult = 0;

      switch (sortBy) {
        case 'Title':
          compareResult = (a.title ?? '').compareTo(b.title ?? '');
          break;
        case 'Year':
          compareResult = (a.year ?? 0).compareTo(b.year ?? 0);
          break;
        case 'Format':
          compareResult = (a.format ?? '').compareTo(b.format ?? '');
          break;
        case 'UPC':
          compareResult = (a.upc ?? BigInt.zero).compareTo(b.upc ?? BigInt.zero);
          break;
        default:
          compareResult = (a.title ?? '').compareTo(b.title ?? '');
      }

      return sortOrder == 'Ascending' ? compareResult : -compareResult;
    });

    return sorted;
  }

  /// Gets unique formats from items
  List<String> getFormats(List<BluRayItem> items) {
    return ['All', ...items
        .map((item) => item.format ?? 'Unknown')
        .where((format) => format.isNotEmpty)
        .toSet()
        .toList()
        ..sort()];
  }
}