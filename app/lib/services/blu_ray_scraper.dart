import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../utils/logger.dart';

/// Service for scraping Blu-ray collection data from blu-ray.com via Dart API
class BluRayScraper {
  static const String _apiBaseUrl = 'http://localhost:3003';


  /// Fetches collection data from the Dart API
  Future<List<BluRayItem>> fetchCollection(String userId) async {
    try {
      logger.logScraper('Fetching collection data for user: $userId via API');

      final url = Uri.parse('$_apiBaseUrl/api/user/$userId/collection');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?)
            ?.map((item) => BluRayItem.fromJsonWithParsedFormat(item as Map<String, dynamic>))
            .toList() ?? [];

        logger.logScraper('Successfully fetched ${items.length} items from API');
        return items;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorData?['message'] ?? 'Unknown error';
        throw Exception('API returned error: $errorMessage');
      }
    } catch (e) {
      logger.logScraper('Failed to fetch collection from API', error: e);
      throw Exception('Failed to fetch Blu-ray collection: $e');
    }
  }

  /// Validates if a user ID looks reasonable
  bool isValidUserId(String userId) {
    return RegExp(r'^\d+$').hasMatch(userId) && userId.length >= 3;
  }
}
