import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/blu_ray_providers.dart';
import '../models/blu_ray_item.dart';
import '../utils/logger.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionStateProvider);
    final filteredItems = ref.watch(filteredItemsProvider);
    final summary = ref.watch(collectionSummaryProvider);
    final categories = ref.watch(availableCategoriesProvider);
    final formats = ref.watch(availableFormatsProvider);

    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedFormat = ref.watch(selectedFormatProvider);

    logger.logUI('Building CollectionScreen with ${filteredItems.length} filtered items');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blu-ray Collection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              logger.logUI('User tapped refresh button');
              ref.read(collectionStateProvider.notifier).reset();
              context.go('/');
            },
            tooltip: 'Fetch Different Collection',
          ),
        ],
      ),
      body: collectionAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading collection...'),
            ],
          ),
        ),
        error: (error, stackTrace) {
          logger.logUI('CollectionScreen displaying error', error: error);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load collection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    logger.logUI('User tapped retry button');
                    context.go('/');
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
        data: (items) {
          logger.logUI('CollectionScreen displaying ${items.length} items');
          return Column(
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${items.length} total items',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By Category: ${summary.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by title',
                        hintText: 'Type to search movies...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        logger.logUI('Search query changed: "$value"');
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      controller: TextEditingController(text: searchQuery),
                    ),
                    const SizedBox(height: 16),

                    // Category and Format filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedCategory,
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Category filter changed: "$value"');
                                ref.read(selectedCategoryProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Format',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedFormat,
                            items: formats.map((format) {
                              return DropdownMenuItem(
                                value: format,
                                child: Text(format),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Format filter changed: "$value"');
                                ref.read(selectedFormatProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing ${filteredItems.length} of ${items.length} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

              // Collection list
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text('No items found matching your filters'),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return ListTile(
                            title: Text(item.title ?? 'Unknown Title'),
                            subtitle: Text(
                              [
                                if (item.year != null) item.year,
                                if (item.format != null) item.format,
                                if (item.category != null && item.category != 'Uncategorized')
                                  item.category,
                              ].join(' • '),
                            ),
                            trailing: item.condition != null
                                ? Chip(label: Text(item.condition!))
                                : null,
                            onTap: () {
                              logger.logUI('User tapped item: ${item.title}');
                              // Could navigate to detail view here
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
