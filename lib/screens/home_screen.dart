import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/blu_ray_providers.dart';
import '../utils/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitId() async {
    final id = _controller.text.trim();

    if (id.isEmpty) {
      logger.logUI('User tried to submit empty ID');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your blu-ray.com ID')),
      );
      return;
    }

    final service = ref.read(bluRayServiceProvider);
    if (!service.isValidUserId(id)) {
      logger.logUI('User submitted invalid ID format: $id');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid blu-ray.com user ID (numbers only)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    logger.logUI('Starting collection fetch for user ID: $id');

    try {
      final notifier = ref.read(collectionStateProvider.notifier);
      await notifier.fetchCollection(id);

      logger.logUI('Successfully fetched collection, navigating to collection screen');
      if (mounted) {
        context.go('/collection');
      }
    } catch (e) {
      logger.logUI('Collection fetch failed', error: e);

      String errorMessage = 'Failed to fetch collection';
      if (e.toString().contains('InvalidUserIdException')) {
        errorMessage = 'Invalid user ID format';
      } else if (e.toString().contains('CollectionAccessException')) {
        errorMessage = 'Unable to access collection. The collection might be private.';
      } else {
        errorMessage = 'Network error: ${e.toString()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blu-ray to Letterboxd'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your blu-ray.com ID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enter your user ID from blu-ray.com to import your collection.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Blu-ray.com User ID',
                hintText: 'Enter your blu-ray.com user ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              onSubmitted: (_) => _submitId(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitId,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Fetch Collection',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
