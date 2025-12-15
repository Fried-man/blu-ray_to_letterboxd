import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../models/blu_ray_item.dart';
import '../utils/logger.dart';

/// Service for scraping Blu-ray collection data from blu-ray.com
class BluRayScraper {
  static const String _baseUrl = 'https://www.blu-ray.com/community/collection.php';
  static const String _proxyBaseUrl = 'http://localhost:3002/api/blu-ray';

  // Dio instance with browser-like configuration
  late final Dio _dio;

  BluRayScraper() {
    _dio = Dio(BaseOptions(
      baseUrl: kIsWeb ? _proxyBaseUrl : 'https://www.blu-ray.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0',
      },
    ));

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: true,
      responseBody: false,
      error: true,
      logPrint: (object) => logger.logNetwork('Dio: $object'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.logNetwork('Making request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.logNetwork('Response received: ${response.statusCode} for ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        logger.logNetwork('Request failed: ${error.message}', error: error);
        return handler.next(error);
      },
    ));
  }

  /// Fetches collection data from both printer-friendly and CSV export URLs
  Future<List<BluRayItem>> fetchCollection(String userId) async {
    try {
      // First try to get data from the collection page
      final collectionItems = await _fetchPrinterFriendlyData(userId);

      if (collectionItems.isNotEmpty) {
        // If we got data from the collection page, try to enhance it with CSV data
        try {
          final csvItems = await _fetchCsvData(userId);
          if (csvItems.isNotEmpty) {
            return _mergeCollectionData(collectionItems, csvItems);
          }
        } catch (csvError) {
          // CSV failed, but we have collection data - continue with that
          print('Warning: CSV data not available, using collection page data only');
        }
      }

      // Return whatever we got from the collection page
      return collectionItems;
    } catch (e) {
      throw Exception('Failed to fetch Blu-ray collection: $e');
    }
  }

  /// Fetches data from the regular collection page (shows owned movies)
  Future<List<BluRayItem>> _fetchPrinterFriendlyData(String userId) async {
    final url = kIsWeb ? '/collection/$userId' : '/community/collection.php?u=$userId';

    logger.logScraper('Fetching collection page for user: $userId (Web: ${kIsWeb})');

    try {
      final response = await _dio.get(url);

      final htmlContent = response.data as String;

      logger.logScraper('Received HTML content, length: ${htmlContent.length}');

      // Check if we got the expected content
      if (!htmlContent.contains('Owned by')) {
        logger.logScraper('Warning: Page does not contain expected "Owned by" section');
      }

      // Check if we got blocked or need login
      if (htmlContent.contains('No index') || htmlContent.contains('Access Denied') || htmlContent.contains('You have to be logged in')) {
        logger.logScraper('Access blocked - collection requires login or is private');
        throw Exception('Access blocked. The collection requires login or is private.');
      }

      final items = _parsePrinterFriendlyHtml(htmlContent);
      logger.logScraper('Successfully parsed ${items.length} items from collection page');

      return items;
    } catch (e) {
      logger.logScraper('Failed to fetch collection page data', error: e);
      rethrow;
    }
  }

  /// Fetches data from the CSV export URL
  Future<List<BluRayItem>> _fetchCsvData(String userId) async {
    final url = kIsWeb ? '/collection/$userId?action=exportcsv' : '/community/collection.php?u=$userId&action=exportcsv';

    logger.logScraper('Attempting to fetch CSV data for user: $userId (Web: ${kIsWeb})');

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {'Accept': 'text/csv,application/csv,text/plain,*/*'}),
      );

      final csvContent = response.data as String;

      logger.logScraper('Received CSV response, length: ${csvContent.length}');

      // Check if we got valid CSV data or HTML error page
      if (csvContent.trim().isEmpty || csvContent.contains('<!DOCTYPE html')) {
        logger.logScraper('Invalid CSV response - received HTML instead of CSV');
        throw Exception('Invalid CSV response received - got HTML page instead');
      }

      // Check if we got blocked or need login
      if (csvContent.contains('No index') || csvContent.contains('Access Denied') || csvContent.contains('logged in')) {
        logger.logScraper('CSV access blocked - collection requires login or is private');
        throw Exception('Access blocked. The collection requires login or is private.');
      }

      final items = _parseCsvData(csvContent);
      logger.logScraper('Successfully parsed ${items.length} items from CSV data');

      return items;
    } catch (e) {
      logger.logScraper('CSV fetch failed or returned invalid data', error: e);
      throw Exception('CSV data not available: $e');
    }
  }

  /// Parses the printer-friendly HTML to extract items with categories
  List<BluRayItem> _parsePrinterFriendlyHtml(String htmlContent) {
    final items = <BluRayItem>[];

    // The collection page shows movies in a visual grid with images
    // Each movie is in a div with an anchor tag containing the title in the title attribute

    // Find all movie entries in the grid layout
    // Pattern matches: <a class="hoverlink" data-globalproductid="..." data-productid="..." href="..." title="..." ><img src="..." />
    final moviePattern = RegExp(
      r'<a[^>]+class="hoverlink"[^>]+data-productid="([^"]*)"[^>]+href="([^"]*)"[^>]+title="([^"]*)"[^>]*>.*?<img[^>]+src="([^"]*)"[^>]*>',
      multiLine: true,
      dotAll: true,
    );

    final matches = moviePattern.allMatches(htmlContent);

    for (final match in matches) {
      if (match.groupCount >= 4) {
        final productId = match.group(1);
        final url = match.group(2);
        final titleWithYear = match.group(3);
        final imageUrl = match.group(4);

        if (titleWithYear != null && titleWithYear.isNotEmpty) {
          // Parse title and year from the title attribute
          // Format is typically: "Movie Title (Year)" or "Movie Title (Year-Year)"
          final titleMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(titleWithYear);
          String? title;
          String? year;

          if (titleMatch != null) {
            title = titleMatch.group(1)?.trim();
            year = titleMatch.group(2)?.trim();
          } else {
            title = titleWithYear.trim();
          }

          // Determine format from URL or title
          String? format;
          if (url?.contains('/4K-') ?? false) {
            format = '4K';
          } else if (url?.contains('/Blu-ray/') ?? false) {
            format = 'Blu-ray';
          } else if (url?.contains('/DVD/') ?? false) {
            format = 'DVD';
          }

          // Extract UPC from URL if present
          String? upc;
          final upcMatch = RegExp(r'/(\d+)/$').firstMatch(url ?? '');
          if (upcMatch != null) {
            upc = upcMatch.group(1);
          }

          final item = BluRayItem(
            title: title,
            year: year,
            format: format,
            upc: upc,
            // The regular collection page doesn't show categories like the printer-friendly view
            // So we'll leave category as null for now
          );

          items.add(item);
        }
      }
    }

    // If no movies found with the visual grid pattern, try the table-based approach
    // (this might be used in the printer-friendly view)
    if (items.isEmpty) {
      return _parseTableBasedHtml(htmlContent);
    }

    return items;
  }

  /// Fallback parser for table-based HTML structure (printer-friendly view)
  List<BluRayItem> _parseTableBasedHtml(String htmlContent) {
    final items = <BluRayItem>[];

    // Look for table rows containing movie data
    final tableRows = RegExp(r'<tr[^>]*>(.*?)</tr>', multiLine: true, dotAll: true).allMatches(htmlContent);

    for (final rowMatch in tableRows) {
      final rowHtml = rowMatch.group(1) ?? '';

      // Extract table cells
      final cells = RegExp(r'<td[^>]*>(.*?)</td>', multiLine: true, dotAll: true)
          .allMatches(rowHtml)
          .map((match) => cleanHtml(match.group(1) ?? ''))
          .toList();

      if (cells.isNotEmpty && cells[0].isNotEmpty) {
        // Create item from table cells
        final item = BluRayItem(
          title: cells.isNotEmpty ? cells[0] : null,
          year: cells.length > 1 ? extractYear(cells[1]) : null,
          format: cells.length > 2 ? cells[2] : null,
          region: cells.length > 3 ? cells[3] : null,
          condition: cells.length > 4 ? cells[4] : null,
        );

        if (item.title != null && item.title!.isNotEmpty) {
          items.add(item);
        }
      }
    }

    return items;
  }

  /// Parses CSV data into BluRayItem objects
  List<BluRayItem> _parseCsvData(String csvContent) {
    try {
      // Parse CSV with flexible settings
      final csvData = const CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
        shouldParseNumbers: false,
      ).convert(csvContent);

      if (csvData.isEmpty) return [];

      // First row should contain headers
      final headers = csvData[0].map((header) => header.toString().trim()).toList();

      final items = <BluRayItem>[];

      // Process data rows
      for (var i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) continue;

        final itemMap = <String, dynamic>{};

        // Map CSV columns to our data structure
        for (var j = 0; j < headers.length && j < row.length; j++) {
          final header = headers[j];
          final value = row[j]?.toString().trim();
          if (value != null && value.isNotEmpty) {
            itemMap[header] = value;
          }
        }

        final item = BluRayItem.fromMap(itemMap);
        items.add(item);
      }

      return items;
    } catch (e) {
      throw Exception('Failed to parse CSV data: $e');
    }
  }

  /// Merges data from printer-friendly and CSV sources
  List<BluRayItem> _mergeCollectionData(
    List<BluRayItem> printerItems,
    List<BluRayItem> csvItems,
  ) {
    final mergedItems = <BluRayItem>[];

    // Create a map for quick lookup of CSV items by title
    final csvItemMap = <String, BluRayItem>{};
    for (final item in csvItems) {
      if (item.title != null) {
        csvItemMap[item.title!.toLowerCase()] = item;
      }
    }

    // Merge printer-friendly items with CSV data
    for (final printerItem in printerItems) {
      if (printerItem.title == null) continue;

      final csvItem = csvItemMap[printerItem.title!.toLowerCase()];

      if (csvItem != null) {
        // Merge the items, preferring CSV data but keeping category from printer view
        mergedItems.add(csvItem.copyWith(category: printerItem.category));
      } else {
        // Only printer data available
        mergedItems.add(printerItem);
      }
    }

    // Add any CSV items that weren't in the printer view
    for (final csvItem in csvItems) {
      if (csvItem.title == null) continue;

      final existingItem = mergedItems.any(
        (item) => item.title?.toLowerCase() == csvItem.title!.toLowerCase(),
      );

      if (!existingItem) {
        mergedItems.add(csvItem);
      }
    }

    return mergedItems;
  }

  /// Cleans HTML tags and entities from text
  String cleanHtml(String html) {
    // Remove HTML tags
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities (in order of specificity)
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&hellip;', '...')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ')
        .trim();

    // Normalize whitespace
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extracts year from a string that might contain other information
  String? extractYear(String text) {
    final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(text);
    return yearMatch?.group(0);
  }

  /// Validates if a user ID looks reasonable
  bool isValidUserId(String userId) {
    return RegExp(r'^\d+$').hasMatch(userId) && userId.length >= 3;
  }
}
