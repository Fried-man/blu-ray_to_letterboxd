import 'package:http/http.dart' as http;
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../utils/logger.dart';

/// Service for scraping Blu-ray collection data from blu-ray.com
class BluRayScraper {

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
      // CSV export appears to be disabled by Blu-ray.com, so we rely on search results
      final collectionItems = await _fetchFromSearchEndpoint(userId);
      logScraper('Successfully fetched ${collectionItems.length} items from search results');

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
    final seenUpcs = <BigInt>{}; // Track UPCs to avoid duplicates

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
          if (item.upc != null && !seenUpcs.contains(item.upc!)) {
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
                  yearPattern = r'\s*\(?\s*' + year + r'\s*-\s*' + (endYear == '-' ? r'-' : endYear) + r'\s*\)?\s*$';
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
            year: year != null ? int.tryParse(year) : null,
            endYear: endYear != null && endYear != '-' ? int.tryParse(endYear) : null,
            format: format != null ? [format] : null,
            upc: upc != null ? BigInt.tryParse(upc) : null,
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
