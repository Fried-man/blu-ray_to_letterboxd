import 'package:blu_ray_shared/blu_ray_item.dart';

/// Utility class for exporting Blu-ray collections to Letterboxd CSV format
class CsvExportUtils {
  /// Converts a list of BluRayItem to Letterboxd CSV format string
  static String convertToLetterboxdCsv(List<BluRayItem> items) {
    final buffer = StringBuffer();

    // CSV Header - Letterboxd import format
    buffer.writeln('Title,Year,Directors,Rating,WatchedDate,Tags');

    // Process each item
    for (final item in items) {
      final row = _createCsvRow(item);
      buffer.writeln(row);
    }

    return buffer.toString();
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
