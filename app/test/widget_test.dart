import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blu_ray_to_letterboxd/services/blu_ray_scraper.dart';
import 'package:blu_ray_to_letterboxd/models/blu_ray_item.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'widget_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late BluRayScraper scraper;

  setUp(() {
    mockClient = MockClient();
    scraper = BluRayScraper();
  });

  group('BluRayScraper Tests', () {
    test('isValidUserId returns true for valid numeric IDs', () {
      expect(scraper.isValidUserId('987553'), isTrue);
      expect(scraper.isValidUserId('123456'), isTrue);
      expect(scraper.isValidUserId('1'), isTrue);
    });

    test('isValidUserId returns false for invalid IDs', () {
      expect(scraper.isValidUserId(''), isFalse);
      expect(scraper.isValidUserId('abc'), isFalse);
      expect(scraper.isValidUserId('123abc'), isFalse);
      expect(scraper.isValidUserId('12'), isFalse); // Too short
    });

    test('_extractYear extracts year from various formats', () {
      expect(scraper.extractYear('The Movie (2023)'), equals('2023'));
      expect(scraper.extractYear('Film 1999 DVD'), equals('1999'));
      expect(scraper.extractYear('No year here'), isNull);
      expect(scraper.extractYear('2020 release'), equals('2020'));
    });

    test('_cleanHtml removes HTML tags and entities', () {
      expect(scraper.cleanHtml('<b>Bold Text</b>'), equals('Bold Text'));
      expect(scraper.cleanHtml('&amp;'), equals('&'));
      expect(scraper.cleanHtml('<a href="#">Link</a>'), equals('Link'));
      expect(scraper.cleanHtml('Normal text'), equals('Normal text'));
    });
  });
}
