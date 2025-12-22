import 'package:http/http.dart' as http;
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../utils/logger.dart';
import '../movie_info.dart';

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




  /// Parses a movie or collection page HTML to extract movie information
  MovieInfo _parseMoviePage(String htmlContent, String originalUrl) {
    // Extract the page title
    final titleMatch = RegExp(r'<title>([^<]+)</title>', caseSensitive: false).firstMatch(htmlContent);
    String pageTitle = titleMatch?.group(1)?.trim() ?? 'Unknown Title';

    // Clean the title (remove site name, etc.)
    pageTitle = pageTitle.replaceAll(' - Blu-ray.com', '').trim();

    // Determine if this is a collection by looking for collection indicators
    final isCollection = _isCollectionPage(htmlContent);

    // Extract year range from page content for collections
    int? year;
    int? endYear;

    if (isCollection) {
      // Look for year range in the page header, like "(2006-2021)"
      final headerMatch = RegExp(r'<h3>[^<]*</h3>&nbsp;\((\d{4})-(\d{4})\)', caseSensitive: false).firstMatch(htmlContent);
      if (headerMatch != null) {
        year = int.tryParse(headerMatch.group(1)!);
        endYear = int.tryParse(headerMatch.group(2)!);
      } else {
        // Fallback: look for year links in the subheading
        final yearLinkMatch = RegExp(r'year=(\d{4})[^>]*>(\d{4})</a>-<a[^>]*year=(\d{4})[^>]*>(\d{4})</a>', caseSensitive: false).firstMatch(htmlContent);
        if (yearLinkMatch != null) {
          year = int.tryParse(yearLinkMatch.group(2)!);
          endYear = int.tryParse(yearLinkMatch.group(4)!);
        }
      }
    }

    // Extract movie items
    final movies = _extractMoviesFromPage(htmlContent, originalUrl, isCollection);

    return MovieInfo(
      url: originalUrl,
      title: _cleanMovieTitle(pageTitle),
      year: year,
      endYear: endYear,
      isCollection: isCollection,
      movies: movies,
    );
  }

  /// Determines if a page represents a movie collection
  bool _isCollectionPage(String htmlContent) {
    // First check: Look for the bundle section that indicates a collection
    final bundleStartText = 'This Blu-ray bundle includes the following titles, see individual titles for specs and details:';
    if (htmlContent.contains(bundleStartText)) {
      return true;
    }

    // Fallback: Look for collection indicators in the title
    final titleMatch = RegExp(r'<title>([^<]+)</title>', caseSensitive: false).firstMatch(htmlContent);
    if (titleMatch != null) {
      final title = titleMatch.group(1)!.toLowerCase();
      final collectionIndicators = [
        'collection',
        'film collection',
        'movie collection',
        'trilogy',
        'quadrilogy',
        'series',
        'saga',
        'complete series',
        '-film-',
        '-movie-',
      ];

      // Check title for collection keywords
      for (final indicator in collectionIndicators) {
        if (title.contains(indicator)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Extracts movie items from the page HTML
  List<MovieItem> _extractMoviesFromPage(String htmlContent, String originalUrl, bool isCollection) {
    final movies = <MovieItem>[];

    if (isCollection) {
      // For collections, look for individual movie entries in the bundle section
      movies.addAll(_extractCollectionMovies(htmlContent, originalUrl));
    }
    // For single movies, leave the movies array empty (movie info is in the main object)

    return movies;
  }

  /// Extracts movies from a collection page
  List<MovieItem> _extractCollectionMovies(String htmlContent, String originalUrl) {
    final movies = <MovieItem>[];

    // Extract only the content between the specific markers
    final bundleStartText = 'This Blu-ray bundle includes the following titles, see individual titles for specs and details:';

    final startIndex = htmlContent.indexOf(bundleStartText);
    if (startIndex == -1) {
      // No bundle section found, return empty list (single movie, not collection)
      return movies;
    }

    // Find the end of the bundle display section (before the review section)
    final endIndex = htmlContent.indexOf('<div id="movie_review_intro"', startIndex);
    String bundleContent;
    if (endIndex == -1) {
      // Try the broader end marker
      final broaderEndIndex = htmlContent.indexOf('Similar titles you might also like', startIndex);
      if (broaderEndIndex == -1) {
        return movies;
      }
      bundleContent = htmlContent.substring(startIndex, broaderEndIndex);
    } else {
      // Extract the bundle section up to the review section
      bundleContent = htmlContent.substring(startIndex, endIndex);
    }


    // Now parse movies only from this specific section
    final collectionPattern = RegExp(
      r'<a[^>]*class="hoverlink"[^>]*href="([^"]*movies/[^"]*/(\d+)/)"[^>]*title="([^"]*)"[^>]*>.*?<img[^>]*src="([^"]*covers/(\d+)_[^"]*\.jpg)"[^>]*></a>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    final matches = collectionPattern.allMatches(bundleContent);
    for (final match in matches) {
      final movieUrl = match.group(1);
      final titleWithYear = match.group(3); // This is the title attribute like "Casino Royale 4K (2006)"
      final coverImageUrl = match.group(4);
      final upc = match.group(5);

      if (movieUrl != null && titleWithYear != null &&
          !movieUrl.contains('search.php') &&
          !movieUrl.contains('movies.php') &&
          !movieUrl.contains('info.php') &&
          !movieUrl.contains('link.php') &&
          movieUrl != originalUrl.replaceAll('https://www.blu-ray.com', '')) {

        // Parse the title which includes year in parentheses
        final parsedTitle = _parseTitleAndYear(titleWithYear);
        final title = parsedTitle['title'] ?? titleWithYear;
        final year = parsedTitle['year'] != null ? int.tryParse(parsedTitle['year']) : null;
        final endYear = parsedTitle['endYear'] != null && parsedTitle['endYear'] != '-'
            ? int.tryParse(parsedTitle['endYear'])
            : null;
        final titleFormat = parsedTitle['format'] as String?;
        List<String>? formatList = titleFormat != null ? [titleFormat] : null;

        // Merge with URL-based format detection
        final urlFormats = _extractFormatsFromUrl(movieUrl);
        List<String>? finalFormats = formatList;
        if (finalFormats == null) {
          finalFormats = urlFormats.isNotEmpty ? urlFormats : null;
        } else if (urlFormats.isNotEmpty) {
          for (final urlFormat in urlFormats) {
            if (!finalFormats.contains(urlFormat)) {
              finalFormats.add(urlFormat);
            }
          }
        }

        movies.add(MovieItem(
          title: title,
          year: year,
          endYear: endYear,
          url: movieUrl.startsWith('http') ? movieUrl : 'https://www.blu-ray.com$movieUrl',
          coverImageUrl: coverImageUrl?.startsWith('http') == true ? coverImageUrl : 'https://images.static-bluray.com/$coverImageUrl',
          format: finalFormats,
          upc: upc != null ? BigInt.tryParse(upc) : null,
        ));
      }
    }

    // Remove duplicates based on URL
    final uniqueMovies = <String, MovieItem>{};
    for (final movie in movies) {
      if (movie.url != null) {
        uniqueMovies[movie.url!] = movie;
      }
    }

    return uniqueMovies.values.toList();
  }

  /// Extracts information for a single movie

  /// Parses title and year from a formatted string (advanced version from collection scraper)
  Map<String, dynamic> _parseTitleAndYear(String text) {
    final cleanText = cleanHtml(text);

    // Parse title and year from the title attribute
    // Format: "Movie Title Format (Year)" e.g., "Top Gun: Maverick 4K (2022)"
    // Also handle year ranges: "(2012-2020)" or "(2012-)" for ongoing collections
    final titleMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(cleanText);
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
      // Fallback: just look for any year in the text
      title = cleanText;
      final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(cleanText);
      if (yearMatch != null) {
        year = yearMatch.group(0);
        // Remove year from title if it's at the end
        title = cleanText.replaceAll(RegExp(r'\s*\(?\s*' + year! + r'\s*\)?\s*$'), '').trim();
      }
    }

    return {'title': title, 'year': year, 'endYear': endYear, 'format': format};
  }


  /// Extracts formats from URL
  List<String> _extractFormatsFromUrl(String url) {
    final formats = <String>[];
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('-4k-')) {
      formats.add('4K');
    }
    if (lowerUrl.contains('-blu-ray') || lowerUrl.contains('-bd-')) {
      formats.add('Blu-ray');
    }
    if (lowerUrl.contains('-dvd')) {
      formats.add('DVD');
    }

    return formats;
  }

  /// Cleans up movie titles
  String _cleanMovieTitle(String title) {
    return title
        .replaceAll(RegExp(r'\s+', multiLine: true), ' ')
        .replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '') // Remove trailing parentheses
        .trim();
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

  /// Fetches detailed information about a movie or collection from its Blu-ray.com URL
  Future<MovieInfo> fetchMovieInfo(String movieUrl) async {
    try {
      logScraper('Fetching movie info from: $movieUrl');

      final response = await _client.get(Uri.parse(movieUrl), headers: _headers);
      final htmlContent = response.body;

      logScraper('Movie page response length: ${htmlContent.length}');

      // Check for errors or blocks
      if (htmlContent.contains('No index') || htmlContent.length < 1000) {
        logScraper('Movie page appears to be blocked or empty');
        throw Exception('Unable to access movie page - may be blocked or invalid URL');
      }

      // Parse the movie/collection information
      final movieInfo = _parseMoviePage(htmlContent, movieUrl);

      logScraper('Successfully parsed movie info: ${movieInfo.title} (${movieInfo.isCollection ? 'collection' : 'single movie'})');
      return movieInfo;

    } catch (e) {
      logScraper('Failed to fetch movie info from $movieUrl', error: e);
      throw Exception('Failed to fetch movie information: $e');
    }
  }

  /// Validates if a user ID looks reasonable
  bool isValidUserId(String userId) {
    return RegExp(r'^\d+$').hasMatch(userId) && userId.length >= 3;
  }
}

