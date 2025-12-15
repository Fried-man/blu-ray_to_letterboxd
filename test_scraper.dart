#!/usr/bin/env dart
/// Standalone test runner for Blu-ray scraper
/// Run with: dart test_scraper.dart

import 'dart:async';
import 'lib/services/blu_ray_scraper.dart';
import 'lib/services/blu_ray_collection_service.dart';

void main() async {
  print('🧪 Blu-ray Scraper End-to-End Test Runner');
  print('=' * 50);

  final scraper = BluRayScraper();
  final service = BluRayCollectionService();

  // Test user ID 987553 as requested
  await testUserId('987553', scraper, service);

  // Test with a few other user IDs to compare
  await testUserId('123456', scraper, service);
  await testUserId('000001', scraper, service);

  print('\n✅ All tests completed!');
}

Future<void> testUserId(String userId, BluRayScraper scraper, BluRayCollectionService service) async {
  print('\n🔍 Testing User ID: $userId');
  print('-' * 30);

  try {
    print('📡 Fetching collection...');
    final items = await scraper.fetchCollection(userId);

    print('✅ Successfully fetched ${items.length} items');

    if (items.isNotEmpty) {
      print('\n📋 First 3 items:');
      for (var i = 0; i < items.length && i < 3; i++) {
        final item = items[i];
        print('  ${i + 1}. ${item.title ?? 'No Title'} (${item.year ?? 'No Year'}) - ${item.format ?? 'No Format'}');
        if (item.category != null) {
          print('     Category: ${item.category}');
        }
      }

      // Test service methods
      final summary = service.getCollectionSummary(items);
      print('\n📊 Collection Summary: $summary');

      final categories = service.getCategories(items);
      print('📂 Categories: $categories');

      final formats = service.getFormats(items);
      print('💿 Formats: $formats');

    } else {
      print('📭 Collection appears to be empty or private');
    }

  } catch (e) {
    print('❌ Failed: $e');

    if (e.toString().contains('Access blocked') || e.toString().contains('No index')) {
      print('   This is likely because the collection is private or requires login');
    }
  }
}
