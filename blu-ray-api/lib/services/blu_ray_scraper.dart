import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/blu_ray_item.dart';
import '../utils/logger.dart';

/// Service for scraping Blu-ray collection data from blu-ray.com
class BluRayScraper {
  static const String _baseUrl = 'https://www.blu-ray.com/community/collection.php';

  // Browser-like headers
  static const Map<String, String> _headers = {
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
  };

  final http.Client _client;

  BluRayScraper({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches collection data from the public search endpoint
  Future<List<BluRayItem>> fetchCollection(String userId) async {
    try {
      // Use the public search endpoint to get collection data
      final collectionItems = await _fetchFromSearchEndpoint(userId);

      if (collectionItems.isNotEmpty) {
        // Try to enhance with CSV data if available
        try {
          final csvItems = await _fetchCsvData(userId);
          if (csvItems.isNotEmpty) {
            return _mergeCollectionData(collectionItems, csvItems);
          }
        } catch (csvError) {
          // CSV failed, but we have search data - continue with that
          logScraper('Warning: CSV data not available, using search results only');
        }
      }

      return collectionItems;
    } catch (e) {
      throw Exception('Failed to fetch Blu-ray collection: $e');
    }
  }

  /// Fetches collection data from the public search endpoint with pagination
  Future<List<BluRayItem>> _fetchFromSearchEndpoint(String userId) async {
    logScraper('Fetching collection data from search endpoint for user: $userId');

    final allItems = <BluRayItem>[];
    var page = 0; // Start at page 0 as requested
    final seenUpcs = <String>{}; // Track UPCs to avoid duplicates

    while (true) { // Continue until no more pages
      try {
        logScraper('Fetching page $page');
        final pageItems = await _fetchSearchPage(userId, page);

        if (pageItems.isEmpty) {
          // No more items on this page, stop pagination
          logScraper('No more items found on page $page, stopping pagination');
          break;
        }

        var newItemsCount = 0;

        // Only add items we haven't seen before (based on UPC)
        for (final item in pageItems) {
          if (item.upc != null && !seenUpcs.contains(item.upc)) {
            seenUpcs.add(item.upc!);
            allItems.add(item);
            newItemsCount++;
          }
        }

        logScraper('Added $newItemsCount new items from page $page (total unique: ${allItems.length})');
        page++;

      } catch (e) {
        logScraper('Failed to fetch page $page', error: e);
        // Stop on error
        break;
      }
    }

    logScraper('Successfully fetched ${allItems.length} total unique items from search endpoint');
    return allItems;
  }

  /// Fetches a single page of search results
  Future<List<BluRayItem>> _fetchSearchPage(String userId, int page) async {
    final url = 'https://www.blu-ray.com/movies/search.php?action=search&search=collection&u=$userId&sortby=relevance&page=$page';
    logScraper('Fetching search page: $url');

    final response = await _client.get(Uri.parse(url), headers: _headers);
    final htmlContent = response.body;

    logScraper('Search page response length: ${htmlContent.length}');

    // Check for errors or blocks
    if (htmlContent.contains('No index') || htmlContent.length < 1000) {
      logScraper('Search page appears to be blocked or empty');
      return [];
    }

    final items = _parseSearchResults(htmlContent);
    logScraper('Parsed ${items.length} items from search page $page');

    return items;
  }

  /// Parses search result HTML to extract movie items
  List<BluRayItem> _parseSearchResults(String htmlContent) {
    final items = <BluRayItem>[];

    // Look for movie entries in search results
    // Extract from hoverlink anchors with title and cover image
    final imgPattern = RegExp(
      r'<a[^>]*class="hoverlink"[^>]*title="([^"]*)"[^>]*>.*?<img[^>]*src="[^"]*covers/(\d+)_[^"]*\.jpg"',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );

    final imgMatches = imgPattern.allMatches(htmlContent);
    logScraper('Found ${imgMatches.length} movie images on search page');

    for (final match in imgMatches) {
      if (match.groupCount >= 2) {
        final titleWithFormat = match.group(1);
        final upc = match.group(2);

        if (titleWithFormat != null && titleWithFormat.isNotEmpty && upc != null) {
          // Parse title and format from the title attribute
          final titleMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(titleWithFormat);
          String? title;
          String? format;

          if (titleMatch != null) {
            title = titleMatch.group(1)?.trim();
            final formatPart = titleMatch.group(2)?.trim();
            if (formatPart != null) {
              if (formatPart.contains('4K')) {
                format = '4K';
              } else if (formatPart.contains('Blu-ray') || formatPart.contains('BD')) {
                format = 'Blu-ray';
              } else if (formatPart.contains('DVD')) {
                format = 'DVD';
              } else if (formatPart.contains('Digital') || formatPart.contains('UV')) {
                format = 'Digital';
              }
            }
          } else {
            title = titleWithFormat.trim();
          }

          // Extract year from title if present
          String? year;
          final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(title ?? '');
          if (yearMatch != null) {
            year = yearMatch.group(0);
          }

          final item = BluRayItem(
            title: title,
            year: year,
            format: format,
            upc: upc,
            category: null, // Search results don't have categories
          );

          items.add(item);
        }
      }
    }


    return items;
  }



  /// Fetches data from the CSV export URL
  Future<List<BluRayItem>> _fetchCsvData(String userId) async {
    final url = '$_baseUrl?u=$userId&action=exportcsv';

    logScraper('Attempting to fetch CSV data for user: $userId');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {..._headers, 'Accept': 'text/csv,application/csv,text/plain,*/*'},
      );

      final csvContent = response.body;

      logScraper('Received CSV response, length: ${csvContent.length}');

      // Check if we got valid CSV data or HTML error page
      if (csvContent.trim().isEmpty || csvContent.contains('<!DOCTYPE html')) {
        logScraper('Invalid CSV response - received HTML instead of CSV');
        throw Exception('Invalid CSV response received - got HTML page instead');
      }

      // Check if we got blocked or need login
      if (csvContent.contains('No index') || csvContent.contains('Access Denied') || csvContent.contains('logged in')) {
        logScraper('CSV access blocked - collection requires login or is private');
        throw Exception('Access blocked. The collection requires login or is private.');
      }

      final items = _parseCsvData(csvContent);
      logScraper('Successfully parsed ${items.length} items from CSV data');

      return items;
    } catch (e) {
      logScraper('CSV fetch failed or returned invalid data', error: e);
      throw Exception('CSV data not available: $e');
    }
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
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
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
