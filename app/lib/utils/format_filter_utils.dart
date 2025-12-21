/// Utility functions for format filtering
bool matchesFormatFilter(List<String> itemFormats, String selectedFilter) {
  switch (selectedFilter) {
    case 'No format':
      return itemFormats.isEmpty;
    case '4K only':
      return itemFormats.length == 1 && itemFormats.contains('4K');
    case 'Blu-ray only':
      return itemFormats.length == 1 && itemFormats.contains('Blu-ray');
    case 'DVD only':
      return itemFormats.length == 1 && itemFormats.contains('DVD');
    case '4K and Blu-ray':
      return itemFormats.length == 2 &&
             itemFormats.contains('4K') &&
             itemFormats.contains('Blu-ray');
    default:
      // For custom combinations like "4K + Blu-ray + DVD"
      if (selectedFilter.contains(' + ')) {
        final requiredFormats = selectedFilter.split(' + ');
        return requiredFormats.every((format) => itemFormats.contains(format)) &&
               itemFormats.length == requiredFormats.length;
      }
      // Fallback: check if any format matches
      return itemFormats.contains(selectedFilter);
  }
}