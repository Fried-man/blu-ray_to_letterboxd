import 'dart:async';
import 'dart:html' as html show window, Blob, Url, AnchorElement;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/blu_ray_providers.dart';
import 'package:blu_ray_shared/blu_ray_item.dart';
import '../services/blu_ray_collection_service.dart';
import '../utils/logger.dart';
import '../utils/csv_export_utils.dart';

/// Progress callback for CSV export operations
typedef CsvExportProgressCallback = void Function(String message, int current, int total);

// Helper function to get year display text
String? getYearDisplayText(BluRayItem item) {
  final startYear = item.year;
  final endYear = item.endYear;

  if (startYear != null && endYear != null) {
    // Both years available - show range
    return '$startYear-$endYear';
  } else if (startYear != null) {
    // Only start year available
    return startYear.toString();
  } else if (endYear != null) {
    // Only end year available (unlikely but handle it)
    return endYear.toString();
  }

  // No year information available
  return null;
}

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
            _buildDetailRow('Year', getYearDisplayText(item)),
            _buildDetailRow('Format', item.format?.join(', ')),
            _buildDetailRow('Category ID', item.categoryId),

            const Divider(),

            // Product Info
            _buildDetailRow('UPC', item.upc?.toString()),
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

/// Progress modal for CSV export operations
class _CsvExportProgressDialog extends StatefulWidget {
  final Stream<String> progressStream;
  final VoidCallback onCancel;

  const _CsvExportProgressDialog({
    required this.progressStream,
    required this.onCancel,
  });

  @override
  State<_CsvExportProgressDialog> createState() => _CsvExportProgressDialogState();
}

class _CsvExportProgressDialogState extends State<_CsvExportProgressDialog> {
  String _currentMessage = 'Initializing export...';
  int _currentItem = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    widget.progressStream.listen((message) {
      if (mounted) {
        setState(() {
          _currentMessage = message;
          // Try to extract progress numbers from message
          final progressMatch = RegExp(r'(\d+)/(\d+)').firstMatch(message);
          if (progressMatch != null) {
            _currentItem = int.tryParse(progressMatch.group(1) ?? '0') ?? 0;
            _totalItems = int.tryParse(progressMatch.group(2) ?? '0') ?? 0;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalItems > 0 ? _currentItem / _totalItems : 0.0;

    return Dialog(
      child: FractionallySizedBox(
        widthFactor: 1 / 3,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exporting to CSV',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress > 0 ? progress : null, // Indeterminate if no progress
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Text(
                  _currentMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_totalItems > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$_currentItem of $_totalItems items processed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionScreen extends ConsumerWidget {
  final String userId;

  const CollectionScreen({super.key, required this.userId});

  Future<void> _exportToCsv(BuildContext context, WidgetRef ref) async {
    // Get the current collection data
    final items = ref.read(collectionStateProvider).maybeWhen(
      data: (items) => items,
      orElse: () => <BluRayItem>[],
    );

    if (items.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items to export')),
        );
      }
      return;
    }

    // Create a stream controller for progress updates
    final progressController = StreamController<String>.broadcast();
    bool isCancelled = false;

    // Show progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _CsvExportProgressDialog(
          progressStream: progressController.stream,
          onCancel: () {
            isCancelled = true;
            progressController.close();
            Navigator.of(dialogContext).pop();
          },
        ),
      );
    }

    try {
      // Convert to CSV with progress callback
      final csvContent = await CsvExportUtils.convertToLetterboxdCsv(
        items,
        onProgress: (message, current, total) {
          if (!isCancelled) {
            progressController.add(message);
          }
        },
      );

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      progressController.close();

      if (isCancelled) {
        logger.logUI('CSV export cancelled by user');
        return;
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final filename = 'blu-ray-collection-letterboxd-$timestamp.csv';

      if (kIsWeb) {
        // Web platform - use HTML5 download
        final blob = html.Blob([csvContent], 'text/csv;charset=utf-8;');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url);
        anchor.setAttribute('download', filename);
        anchor.click();
        html.Url.revokeObjectUrl(url);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported ${items.length} items to $filename')),
          );
        }
      } else {
        // Mobile platforms - could save to downloads folder
        // For now, show a message that this feature is web-only
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV export is currently available on web only')),
          );
        }
      }

      logger.logUI('Successfully exported ${items.length} items to CSV');
    } catch (error) {
      // Close progress dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      progressController.close();

      logger.logUI('Error exporting to CSV: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error exporting CSV')),
        );
      }
    }
  }

  Future<List<BluRayItem>> _fetchCollectionForUser(String userId, WidgetRef ref) async {
    // First check cache
    final cache = ref.read(collectionCacheProvider);
    final cachedData = cache[userId];

    if (cachedData != null && cachedData.hasValue && !cachedData.isRefreshing) {
      logger.logUI('Using cached collection data for user $userId');
      // Populate the state provider with cached data
      ref.read(collectionStateProvider.notifier).loadCachedCollection(cachedData);
      return cachedData.value!;
    }

    logger.logUI('Fetching fresh collection data for user $userId');
    final service = BluRayCollectionService();

    try {
      final items = await service.fetchCollection(userId);
      // Populate the state provider with the fetched data
      final AsyncValue<List<BluRayItem>> asyncData = AsyncValue.data(items);
      ref.read(collectionStateProvider.notifier).loadCachedCollection(asyncData);
      // Cache the successful result
      ref.read(collectionCacheProvider.notifier).cacheCollection(userId, asyncData);
      return items;
    } catch (error, stackTrace) {
      // Populate the state provider with the error
      final AsyncValue<List<BluRayItem>> asyncError = AsyncValue.error(error, stackTrace);
      ref.read(collectionStateProvider.notifier).loadCachedCollection(asyncError);
      // Cache the error too to avoid repeated failed requests
      ref.read(collectionCacheProvider.notifier).cacheCollection(userId, asyncError);
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
                  Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load collection',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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

        final formats = ref.watch(availableFormatsProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text('Collection - User $userId'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  logger.logUI('User tapped save CSV button for user $userId');
                  await _exportToCsv(context, ref);
                },
                tooltip: 'Export to Letterboxd CSV',
              ),
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

              // Collapsible Filters and Sorting
              _CollapsibleFiltersSection(formats: formats),

              // Results section
              _ResultsSection(onItemTap: showItemDetails),
            ],
          ),
        );
      },
    );
  }


  static Widget buildCoverImage(String mediumUrl) {
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

  static Widget buildInfoChip(BuildContext context, String label, IconData icon, Color color) {
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

class _CollapsibleFiltersSection extends ConsumerStatefulWidget {
  final List<String> formats;

  const _CollapsibleFiltersSection({required this.formats});

  @override
  ConsumerState<_CollapsibleFiltersSection> createState() => _CollapsibleFiltersSectionState();
}

class _CollapsibleFiltersSectionState extends ConsumerState<_CollapsibleFiltersSection> {
  bool _isExpanded = false; // Default to closed

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Search & Filters',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      children: [
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

              // Format filter
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Format',
                  border: OutlineInputBorder(),
                ),
                value: ref.watch(selectedFormatProvider),
                items: widget.formats.map((format) {
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
      ],
    );
  }
}

class _ResultsSection extends ConsumerWidget {
  final void Function(BuildContext, BluRayItem) onItemTap;

  const _ResultsSection({required this.onItemTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the optimized filtered provider instead of doing expensive work in build
    final filteredItems = ref.watch(filteredItemsProvider);
    final totalItems = ref.watch(collectionStateProvider).maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    logger.logUI('CollectionScreen displaying ${filteredItems.length} filtered items out of $totalItems total');

    return Expanded(
      child: Column(
        children: [
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Showing ${filteredItems.length} of $totalItems items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Collection grid with optimized performance
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('No items found matching your filters'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    // Add item key for better performance
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _ItemCard(
                        key: ValueKey(item.productId ?? item.title ?? index),
                        item: item,
                        onItemTap: onItemTap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final BluRayItem item;
  final void Function(BuildContext, BluRayItem) onItemTap;

  const _ItemCard({
    super.key,
    required this.item,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CollectionScreen.buildCoverImage(item.coverImageUrl!),
                  ),
                ),

              // Title
              Text(
                item.title ?? 'Unknown Title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Format badges and Year
              Row(
                children: [
                  // Format chips on the left
                  if (item.format != null && item.format!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.format!.map((format) =>
                        CollectionScreen.buildInfoChip(context, format, Icons.album, Theme.of(context).colorScheme.secondary)
                      ).toList(),
                    ),

                  // Expanded spacer
                  if (item.format != null && item.format!.isNotEmpty && getYearDisplayText(item) != null)
                    const Spacer(),

                  // Year chip on the right
                  if (getYearDisplayText(item) != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getYearDisplayText(item)!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              // Expanded spacer to push content up and button down
              const Spacer(),

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

              // Movie URL button if available
              if (item.movieUrl != null && item.movieUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      logger.logUI('User tapped movie URL button for: ${item.title}');
                      final url = item.movieUrl!;

                      try {
                        if (kIsWeb) {
                          // Use web-specific URL opening
                          html.window.open(url, '_blank');
                        } else {
                          // Use url_launcher for mobile platforms
                          final uri = Uri.parse(url);
                          await launchUrl(uri);
                        }
                      } catch (e) {
                        logger.logUI('Could not launch URL: $url, error: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open movie page')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View on Blu-ray.com'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
