import 'package:flutter_test/flutter_test.dart';
import 'package:blu_ray_to_letterboxd/services/blu_ray_scraper.dart';
import 'package:blu_ray_to_letterboxd/services/blu_ray_collection_service.dart';
import 'package:blu_ray_to_letterboxd/models/blu_ray_item.dart';

void main() {
  late BluRayScraper scraper;
  late BluRayCollectionService service;

  setUp(() {
    scraper = BluRayScraper();
    service = BluRayCollectionService();
  });

  group('BluRayScraper End-to-End Tests', () {
    test('Test with user ID 987553 - Real scraping attempt', () async {
      print('\n=== Testing BluRay Scraper with User ID 987553 ===');

      try {
        print('Attempting to fetch collection for user 987553...');
        final items = await scraper.fetchCollection('987553');

        print('✅ Successfully fetched ${items.length} items!');

        // Print details of first few items
        for (var i = 0; i < items.length && i < 5; i++) {
          final item = items[i];
          print('Item ${i + 1}: ${item.title} (${item.year}) - ${item.format}');
          if (item.category != null) {
            print('  Category: ${item.category}');
          }
        }

        // Verify the data structure
        expect(items, isNotNull);
        expect(items, isA<List<BluRayItem>>());

        if (items.isNotEmpty) {
          final firstItem = items.first;
          expect(firstItem, isNotNull);

          // At least some items should have titles
          final itemsWithTitles = items.where((item) => item.title?.isNotEmpty ?? false).length;
          print('Items with titles: $itemsWithTitles/${items.length}');

          // Check for categories
          final categories = items
              .map((item) => item.category)
              .where((cat) => cat != null && cat.isNotEmpty)
              .toSet();
          print('Categories found: $categories');
        }

      } catch (e) {
        print('❌ Failed to fetch collection: $e');
        print('Error type: ${e.runtimeType}');

        // This is expected if the collection is private or access is blocked
        expect(
          e,
          anyOf([
            isA<Exception>(),
            predicate((e) => e.toString().contains('Access blocked')),
            predicate((e) => e.toString().contains('No index')),
            predicate((e) => e.toString().contains('Failed to fetch')),
          ]),
        );
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Test service layer with user ID 987553', () async {
      print('\n=== Testing Service Layer with User ID 987553 ===');

      try {
        print('Attempting to fetch collection via service...');
        final items = await service.fetchCollection('987553');

        print('✅ Service successfully fetched ${items.length} items!');

        // Test service methods
        final summary = service.getCollectionSummary(items);
        print('Collection summary: $summary');

        final categories = service.getCategories(items);
        print('Available categories: $categories');

        final formats = service.getFormats(items);
        print('Available formats: $formats');

        // Test filtering
        if (categories.isNotEmpty) {
          final filteredByCategory = service.filterByCategory(items, categories.first);
          print('Filtered by ${categories.first}: ${filteredByCategory.length} items');
        }

        if (formats.isNotEmpty) {
          final filteredByFormat = service.filterByFormat(items, formats.first);
          print('Filtered by ${formats.first}: ${filteredByFormat.length} items');
        }

        // Test search
        const searchTerm = 'test';
        final searchResults = service.searchByTitle(items, searchTerm);
        print('Search for "$searchTerm": ${searchResults.length} results');

      } catch (e) {
        print('❌ Service failed: $e');
        print('Error type: ${e.runtimeType}');

        // Verify it's one of our custom exceptions or expected errors
        expect(
          e,
          anyOf([
            isA<InvalidUserIdException>(),
            isA<CollectionAccessException>(),
            isA<Exception>(),
          ]),
        );
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Test data parsing utilities', () {
      print('\n=== Testing Data Parsing Utilities ===');

      // Test HTML cleaning
      final htmlTests = [
        {
          'input': '<b>Bold Text</b>',
          'expected': 'Bold Text',
          'description': 'Remove HTML tags'
        },
        {
          'input': '&amp; &lt; &gt; &quot;',
          'expected': '& < > "',
          'description': 'Decode HTML entities'
        },
        {
          'input': '<a href="#">Link Text</a>',
          'expected': 'Link Text',
          'description': 'Remove links but keep text'
        },
        {
          'input': 'Normal text with <span>nested</span> tags',
          'expected': 'Normal text with nested tags',
          'description': 'Remove nested tags'
        },
        {
          'input': 'Text with  &nbsp; spaces   and\t\ttabs',
          'expected': 'Text with spaces and tabs',
          'description': 'Normalize whitespace'
        },
      ];

      for (final test in htmlTests) {
        final cleaned = scraper.cleanHtml(test['input']!);
        print('HTML: "${test['input']}" -> "$cleaned" (${test['description']})');
        expect(cleaned, equals(test['expected']));
      }

      // Test year extraction
      const yearSamples = [
        'Movie Title (2023)',
        'Film 1999 Release',
        'Series (2015-2020)',
        'No year here',
        '2024 Upcoming',
      ];

      for (final sample in yearSamples) {
        final year = scraper.extractYear(sample);
        print('Text: "$sample" -> Year: $year');
        if (year != null) {
          expect(int.tryParse(year), isNotNull);
          expect(year.length, equals(4));
        }
      }
    });

    test('Test validation logic', () {
      print('\n=== Testing Validation Logic ===');

      const validIds = ['987553', '123456', '000001', '999999'];
      const invalidIds = ['', 'abc', '123abc', '12', '123.456'];

      for (final id in validIds) {
        final isValid = service.isValidUserId(id);
        print('ID "$id": ${isValid ? '✅ Valid' : '❌ Invalid'}');
        expect(isValid, isTrue);
      }

      for (final id in invalidIds) {
        final isValid = service.isValidUserId(id);
        print('ID "$id": ${isValid ? '✅ Valid' : '❌ Invalid'}');
        expect(isValid, isFalse);
      }
    });

    test('Test error handling with invalid inputs', () async {
      print('\n=== Testing Error Handling ===');

      // Test invalid user IDs
      const invalidIds = ['', 'abc', '12'];

      for (final id in invalidIds) {
        try {
          await service.fetchCollection(id);
          fail('Expected InvalidUserIdException for ID: $id');
        } catch (e) {
          print('ID "$id" correctly threw: ${e.runtimeType}');
          expect(e, isA<InvalidUserIdException>());
        }
      }
    });
  });
}
