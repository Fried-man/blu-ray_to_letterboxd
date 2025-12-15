import 'lib/services/blu_ray_collection_service.dart';

void main() async {
  print('🧪 Testing BluRayCollectionService directly...');

  final service = BluRayCollectionService();

  try {
    print('Fetching collection for user 987553...');
    final items = await service.fetchCollection('987553');

    print('✅ Success! Fetched ${items.length} items');

    for (var i = 0; i < items.length && i < 5; i++) {
      final item = items[i];
      print('  ${i + 1}. ${item.title} (${item.year})');
    }

  } catch (e) {
    print('❌ Error: $e');
    print('Error type: ${e.runtimeType}');
  }
}
