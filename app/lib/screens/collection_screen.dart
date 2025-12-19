import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/blu_ray_providers.dart';
import '../models/blu_ray_item.dart';
import '../services/blu_ray_collection_service.dart';
import '../utils/logger.dart';

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
        final filteredItems = ref.watch(filteredItemsProvider);
        final summary = ref.watch(collectionSummaryProvider);
        final categories = ref.watch(availableCategoriesProvider);
        final formats = ref.watch(availableFormatsProvider);

        final searchQuery = ref.watch(searchQueryProvider);
        final selectedCategory = ref.watch(selectedCategoryProvider);
        final selectedFormat = ref.watch(selectedFormatProvider);

        logger.logUI('CollectionScreen displaying ${filteredItems.length} filtered items out of ${items.length} total');

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
                      controller: TextEditingController(text: searchQuery),
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
                        const SizedBox(width: 8),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Condition',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(selectedConditionProvider),
                            items: ref.watch(availableConditionsProvider).map((condition) {
                              return DropdownMenuItem(
                                value: condition,
                                child: Text(condition),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Condition filter changed: "$value"');
                                ref.read(selectedConditionProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Second row: Watched, Wishlist, Sort By, Sort Order
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Watched',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(selectedWatchedProvider),
                            items: ref.watch(availableWatchedProvider).map((watched) {
                              return DropdownMenuItem(
                                value: watched,
                                child: Text(watched),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Watched filter changed: "$value"');
                                ref.read(selectedWatchedProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Wishlist',
                              border: OutlineInputBorder(),
                            ),
                            value: ref.watch(selectedWishlistProvider),
                            items: ref.watch(availableWishlistProvider).map((wishlist) {
                              return DropdownMenuItem(
                                value: wishlist,
                                child: Text(wishlist),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                logger.logUI('Wishlist filter changed: "$value"');
                                ref.read(selectedWishlistProvider.notifier).state = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
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

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing ${filteredItems.length} of ${items.length} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

              // Collection grid
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text('No items found matching your filters'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildItemCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, BluRayItem item) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          logger.logUI('User tapped item: ${item.title}');
          _showItemDetails(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  if (item.condition != null)
                    _buildInfoChip(context, item.condition!, Icons.inventory, Colors.orange),
                ],
              ),
              const SizedBox(height: 8),

              // Director and Rating
              if (item.director != null || item.rating != null)
                Row(
                  children: [
                    if (item.director != null)
                      Expanded(
                        child: Text(
                          'Director: ${item.director}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (item.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.rating!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

              // Genre and Runtime
              if (item.genre != null || item.runtime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [
                      if (item.genre != null) 'Genre: ${item.genre}',
                      if (item.runtime != null) 'Runtime: ${item.runtime}',
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Status indicators
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (item.watched == 'Yes')
                        Icon(Icons.visibility, size: 16, color: Colors.green),
                      if (item.wishlist == 'Yes')
                        Icon(Icons.star, size: 16, color: Colors.amber),
                      if (item.loanStatus != null && item.loanStatus!.isNotEmpty)
                        Icon(Icons.person, size: 16, color: Colors.blue),
                    ],
                  ),
                  if (item.price != null)
                    Text(
                      '\$${item.price}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon, Color color) {
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

  void _showItemDetails(BuildContext context, BluRayItem item) {
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
              _buildDetailRow('Condition', item.condition),

              const Divider(),

              // Media Info
              _buildDetailRow('Director', item.director),
              _buildDetailRow('Actors', item.actors),
              _buildDetailRow('Genre', item.genre),
              _buildDetailRow('Rating', item.rating),
              _buildDetailRow('Runtime', item.runtime),
              _buildDetailRow('Studio', item.studio),

              const Divider(),

              // Collection Info
              _buildDetailRow('UPC', item.upc),
              _buildDetailRow('ASIN', item.asin),
              _buildDetailRow('IMDB ID', item.imdbId),
              _buildDetailRow('Region', item.region),
              _buildDetailRow('Edition', item.edition),

              const Divider(),

              // Status Info
              _buildDetailRow('Watched', item.watched),
              _buildDetailRow('Wishlist', item.wishlist),
              _buildDetailRow('Loan Status', item.loanStatus),
              _buildDetailRow('Loaned To', item.loanTo),
              _buildDetailRow('Loan Date', item.loanDate),

              const Divider(),

              // Purchase Info
              _buildDetailRow('Purchase Date', item.purchaseDate),
              _buildDetailRow('Price', item.price),
              _buildDetailRow('Location', item.location),
              _buildDetailRow('Date Added', item.dateAdded),

              // Notes
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const Divider(),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.notes!),
              ],
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
}
