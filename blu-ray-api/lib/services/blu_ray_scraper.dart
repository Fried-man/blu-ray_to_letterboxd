import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:blu_ray_shared/blu_ray_item.dart';
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
    // Extract comprehensive movie data from hoverlink anchors
    final moviePattern = RegExp(
      r'<a[^>]*class="hoverlink"[^>]*data-globalproductid="([^"]*)"[^>]*data-globalparentid="([^"]*)"[^>]*data-categoryid="([^"]*)"[^>]*data-productid="([^"]*)"[^>]*href="([^"]*)"[^>]*title="([^"]*)"[^>]*>.*?<img[^>]*src="([^"]*covers/(\d+)_[^"]*\.jpg)"',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );

    // Fallback regex for items that might not have all data attributes
    final fallbackPattern = RegExp(
      r'<a[^>]*class="hoverlink"[^>]*data-globalproductid="([^"]*)"[^>]*data-productid="([^"]*)"[^>]*href="([^"]*)"[^>]*title="([^"]*)"[^>]*>.*?<img[^>]*src="([^"]*covers/(\d+)_[^"]*\.jpg)"',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );

    var matches = moviePattern.allMatches(htmlContent).toList();
    logScraper('Found ${matches.length} movie entries with full regex');

    // If no matches with the full regex, try the fallback
    if (matches.isEmpty) {
      matches = fallbackPattern.allMatches(htmlContent).toList();
      logScraper('Found ${matches.length} movie entries with fallback regex');
    }

    for (final match in matches) {
      String? globalProductId, globalParentId, categoryId, productId, movieUrl, titleWithFormat, coverImageUrl, upc;

      if (match.groupCount >= 8) {
        // Full regex match
        globalProductId = match.group(1);
        globalParentId = match.group(2);
        categoryId = match.group(3);
        productId = match.group(4);
        movieUrl = match.group(5);
        titleWithFormat = match.group(6);
        coverImageUrl = match.group(7);
        upc = match.group(8); // Extract UPC from image filename
      } else if (match.groupCount >= 6) {
        // Fallback regex match
        globalProductId = match.group(1);
        productId = match.group(2);
        movieUrl = match.group(3);
        titleWithFormat = match.group(4);
        coverImageUrl = match.group(5);
        upc = match.group(6);
        globalParentId = null;
        categoryId = null;
      }

      if (titleWithFormat != null && titleWithFormat.isNotEmpty) {
          // Parse title and year from the title attribute
          // Format: "Movie Title Format (Year)" e.g., "Top Gun: Maverick 4K (2022)"
          // Also handle year ranges: "(2012-2020)" or "(2012-)" for ongoing collections
          final titleMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(titleWithFormat);
          String? title;
          String? year;
          String? endYear;
          String? format;

          if (titleMatch != null) {
            final fullTitle = titleMatch.group(1)?.trim();
            final yearAndFormat = titleMatch.group(2)?.trim();

            if (yearAndFormat != null) {
              // Check for year range patterns: "2012-2020" or "2012-"
              final yearRangeMatch = RegExp(r'\b(19|20)\d{2}\s*-\s*((19|20)\d{2})?\s*$').firstMatch(yearAndFormat);
              if (yearRangeMatch != null) {
                // Extract start year
                year = yearRangeMatch.group(1) != null ? yearRangeMatch.group(0)?.substring(0, 4) : null;
                // Extract end year (if present, otherwise it's ongoing with "-")
                final endYearPart = yearRangeMatch.group(2);
                if (endYearPart != null && endYearPart.isNotEmpty) {
                  endYear = endYearPart;
                } else if (yearAndFormat.contains('-')) {
                  // Ongoing collection (ends with "-")
                  endYear = '-';
                }
              } else {
                // Extract single year from the parentheses content
                final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(yearAndFormat);
                if (yearMatch != null) {
                  year = yearMatch.group(0);
                }
              }

              // Remove year information from title
              if (fullTitle != null && (year != null || endYear != null)) {
                String yearPattern = '';
                if (year != null && endYear != null) {
                  yearPattern = r'\s*\(?\s*' + year + r'\s*-\s*' + (endYear == '-' ? r'-' : endYear!) + r'\s*\)?\s*$';
                } else if (year != null) {
                  yearPattern = r'\s*\(?\s*' + year + r'\s*\)?\s*$';
                }
                if (yearPattern.isNotEmpty) {
                  title = fullTitle.replaceAll(RegExp(yearPattern), '').trim();
                } else {
                  title = fullTitle;
                }
              } else {
                title = fullTitle;
              }

              // Extract format from the parentheses content
              if (yearAndFormat.contains('4K')) {
                format = '4K';
              } else if (yearAndFormat.contains('Blu-ray') || yearAndFormat.contains('BD')) {
                format = 'Blu-ray';
              } else if (yearAndFormat.contains('DVD')) {
                format = 'DVD';
              } else if (yearAndFormat.contains('Digital') || yearAndFormat.contains('UV')) {
                format = 'Digital';
              }
            } else {
              title = fullTitle;
            }

            // Also check the title part for format indicators
            if (format == null && title != null) {
              if (title.contains('4K')) {
                format = '4K';
                title = title.replaceAll('4K', '').trim();
              } else if (title.contains('Blu-ray') || title.contains('BD')) {
                format = 'Blu-ray';
                title = title.replaceAll(RegExp(r'\s*Blu-ray|\s*BD'), '').trim();
              } else if (title.contains('DVD')) {
                format = 'DVD';
                title = title.replaceAll('DVD', '').trim();
              }
            }
          } else {
            title = titleWithFormat.trim();
          }

          // If no year found in parentheses, try to extract from title
          if (year == null && title != null) {
            final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(title);
            if (yearMatch != null) {
              year = yearMatch.group(0);
            }
          }

          // Determine format from URL if not found in title
          if (format == null && movieUrl != null) {
            if (movieUrl.contains('/4K-')) {
              format = '4K';
            } else if (movieUrl.contains('/Blu-ray/') || movieUrl.contains('/BD/')) {
              format = 'Blu-ray';
            } else if (movieUrl.contains('/DVD/')) {
              format = 'DVD';
            }
          }

          final item = BluRayItem(
            title: title,
            year: year,
            endYear: endYear,
            format: format,
            upc: upc,
            movieUrl: movieUrl,
            coverImageUrl: coverImageUrl,
            productId: productId,
            globalProductId: globalProductId,
            globalParentId: globalParentId,
            categoryId: categoryId,
          );

          items.add(item);
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

  /// Merges data from search results and CSV sources
  List<BluRayItem> _mergeCollectionData(
    List<BluRayItem> searchItems,
    List<BluRayItem> csvItems,
  ) {
    final mergedItems = <BluRayItem>[];

    // Create a map for quick lookup of CSV items by UPC or title
    final csvItemMap = <String, BluRayItem>{};
    for (final item in csvItems) {
      // Prefer UPC for matching, fall back to title
      final key = item.upc ?? item.title?.toLowerCase();
      if (key != null) {
        csvItemMap[key] = item;
      }
    }

    // Merge search items with CSV data
    for (final searchItem in searchItems) {
      final csvItem = csvItemMap[searchItem.upc ?? searchItem.title?.toLowerCase()];

      if (csvItem != null) {
        // Use CSV data but keep search-specific fields
        mergedItems.add(csvItem.copyWith(
          movieUrl: searchItem.movieUrl ?? csvItem.movieUrl,
          coverImageUrl: searchItem.coverImageUrl ?? csvItem.coverImageUrl,
          productId: searchItem.productId ?? csvItem.productId,
          globalProductId: searchItem.globalProductId ?? csvItem.globalProductId,
          globalParentId: searchItem.globalParentId ?? csvItem.globalParentId,
          categoryId: searchItem.categoryId ?? csvItem.categoryId,
        ));
      } else {
        // Only search data available
        mergedItems.add(searchItem);
      }
    }

    // Add any CSV items that weren't in the search results
    for (final csvItem in csvItems) {
      final key = csvItem.upc ?? csvItem.title?.toLowerCase();
      if (key == null) continue;

      final existingItem = mergedItems.any(
        (item) => (item.upc ?? item.title?.toLowerCase()) == key,
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
