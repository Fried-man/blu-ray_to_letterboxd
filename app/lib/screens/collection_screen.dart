import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/blu_ray_providers.dart';
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../services/blu_ray_collection_service.dart';
import '../utils/logger.dart';

// Top-level function for showing item details
void showItemDetails(BuildContext context, BluRayItem item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(item.title ?? 'Unknown Title'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Basic Info
            _buildDetailRow('Year', item.year),
            _buildDetailRow('Format', item.format),
            _buildDetailRow('Category', item.category),
            _buildDetailRow('Category ID', item.categoryId),

            const Divider(),

            // Product Info
            _buildDetailRow('UPC', item.upc),
            _buildDetailRow('Product ID', item.productId),
            _buildDetailRow('Global Product ID', item.globalProductId),
            _buildDetailRow('Global Parent ID', item.globalParentId),

            const Divider(),

            // Links
            _buildDetailRow('Movie URL', item.movieUrl),
            _buildDetailRow('Cover Image URL', item.coverImageUrl),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

class CollectionScreen extends ConsumerWidget {
  final String userId;

  const CollectionScreen({super.key, required this.userId});

  Future<List<BluRayItem>> _fetchCollectionForUser(String userId, WidgetRef ref) async {
    // First check cache
    final cache = ref.read(collectionCacheProvider);
    final cachedData = cache[userId];

    if (cachedData != null && cachedData.hasValue && !cachedData.isRefreshing) {
      logger.logUI('Using cached collection data for user $userId');
      return cachedData.value!;
    }

    logger.logUI('Fetching fresh collection data for user $userId');
    final service = BluRayCollectionService();

    try {
      final items = await service.fetchCollection(userId);
      // Cache the successful result
      ref.read(collectionCacheProvider.notifier).cacheCollection(userId, AsyncValue.data(items));
      return items;
    } catch (error, stackTrace) {
      // Cache the error too to avoid repeated failed requests
      ref.read(collectionCacheProvider.notifier).cacheCollection(userId, AsyncValue.error(error, stackTrace));
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.logUI('Building CollectionScreen for user $userId');

    // Cache is checked in the _fetchCollectionForUser method

    return FutureBuilder<List<BluRayItem>>(
      future: _fetchCollectionForUser(userId, ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Collection - User $userId'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading collection...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Collection - User $userId'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    logger.logUI('User tapped home button from error screen');
                    context.go('/');
                  },
                  tooltip: 'Home',
                ),
              ],
            ),
            body: Center(
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
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      logger.logUI('User tapped retry button for user $userId');
                      // This will trigger a rebuild and refetch
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];
        final summary = ref.watch(collectionSummaryProvider);
        final categories = ref.watch(availableCategoriesProvider);
        final formats = ref.watch(availableFormatsProvider);

        return Scaffold(
      appBar: AppBar(
        title: Text('Collection - User $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              logger.logUI('User tapped refresh button for user $userId');
              ref.read(collectionStateProvider.notifier).fetchCollection(userId);
            },
            tooltip: 'Refresh Collection',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              logger.logUI('User tapped home button');
              context.go('/');
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: Column(
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

              // Filters and Sorting
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by title, director, actors, or genre...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        logger.logUI('Search query changed: "$value"');
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // First row: Category, Format, Condition
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(selectedCategoryProvider),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Format',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(selectedFormatProvider),
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
                    const SizedBox(height: 12),

                    // Sort options
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Sort By',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(sortByProvider),
                            items: ref.watch(sortOptionsProvider).map((sortOption) {
                              return DropdownMenuItem(
                                value: sortOption,
                                child: Text(sortOption),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Sort by changed: "$value"');
                                ref.read(sortByProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Order',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(sortOrderProvider),
                            items: ref.watch(sortOrderOptionsProvider).map((order) {
                              return DropdownMenuItem(
                                value: order,
                                child: Text(order),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Sort order changed: "$value"');
                                ref.read(sortOrderProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Results section
              _ResultsSection(items: items, onItemTap: showItemDetails),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildItemCard(BuildContext context, BluRayItem item, void Function(BuildContext, BluRayItem) onItemTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          logger.logUI('User tapped item: ${item.title}');
          onItemTap(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              if (item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  constraints: const BoxConstraints(maxHeight: 200), // Max height constraint
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCoverImage(item.coverImageUrl!),
                  ),
                ),

              // Title and Year
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title ?? 'Unknown Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.year != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.year!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Format and Category badges
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (item.format != null)
                    _buildInfoChip(context, item.format!, Icons.album, Colors.blue),
                  if (item.category != null && item.category != 'Uncategorized')
                    _buildInfoChip(context, item.category!, Icons.category, Colors.green),
                ],
              ),
              const SizedBox(height: 8              ),

              // UPC if available
              if (item.upc != null)
                Text(
                  'UPC: ${item.upc}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              // Spacer for layout
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCoverImage(String mediumUrl) {
    // Try to get large version by replacing 'medium' with 'large'
    final largeUrl = mediumUrl.replaceAll('_medium', '_large');

    return Image.network(
      largeUrl,
      fit: BoxFit.contain, // Use contain to maintain aspect ratio
      errorBuilder: (context, error, stackTrace) {
        // If large fails, try medium
        return Image.network(
          mediumUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // If both fail, show fallback
            return Container(
              height: 150, // Fallback height
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                Icons.movie,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 150,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInfoChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}

class _ResultsSection extends ConsumerWidget {
  final List<BluRayItem> items;
  final void Function(BuildContext, BluRayItem) onItemTap;

  const _ResultsSection({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filter providers
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedFormat = ref.watch(selectedFormatProvider);
    final sortBy = ref.watch(sortByProvider);
    final sortOrder = ref.watch(sortOrderProvider);

    // Apply filters locally
    var filtered = items;

    // Apply category filter
    if (selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == selectedCategory).toList();
    }

    // Apply format filter
    if (selectedFormat != 'All') {
      filtered = filtered.where((item) => item.format == selectedFormat).toList();
    }

    // Apply search filter - only search in available fields
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((item) =>
          (item.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (item.year?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (item.format?.toLowerCase().contains(lowercaseQuery) ?? false)).toList();
    }

    // Apply sorting - only sort by available fields
    filtered.sort((a, b) {
      int compareResult = 0;

      switch (sortBy) {
        case 'Title':
          compareResult = (a.title ?? '').compareTo(b.title ?? '');
          break;
        case 'Year':
          compareResult = (a.year ?? '').compareTo(b.year ?? '');
          break;
        case 'Format':
          compareResult = (a.format ?? '').compareTo(b.format ?? '');
          break;
        case 'UPC':
          compareResult = (a.upc ?? '').compareTo(b.upc ?? '');
          break;
        default:
          compareResult = (a.title ?? '').compareTo(b.title ?? '');
      }

      return sortOrder == 'Ascending' ? compareResult : -compareResult;
    });

    logger.logUI('CollectionScreen displaying ${filtered.length} filtered items out of ${items.length} total');

    return Expanded(
      child: Column(
        children: [
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Showing ${filtered.length} of ${items.length} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Collection grid
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No items found matching your filters'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350, // Slightly smaller for better fit
                      childAspectRatio: 0.8, // Allow more vertical space for natural aspect ratios
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return CollectionScreen._buildItemCard(context, item, onItemTap);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
