import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/blu_ray_providers.dart';
import '../utils/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitId() {
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

    logger.logUI('Navigating to collection screen for user ID: $id');
    context.go('/user/$id/collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blu-ray to Letterboxd'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              logger.logUI('User clicked GitHub icon');
              const url = 'https://github.com/Fried-man/blu-ray_to_letterboxd';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                logger.logUI('Could not launch GitHub URL');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open GitHub link')),
                  );
                }
              }
            },
            icon: const FaIcon(FontAwesomeIcons.github),
            tooltip: 'View on GitHub',
          ),
        ],
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
            Text(
              'Please enter your user ID from blu-ray.com to view your collection.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              onPressed: _submitId,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Collection',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  logger.logUI('User clicked "My name is Ben" link');
                  context.go('/user/987553/collection');
                },
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: [
                      const TextSpan(text: 'My name is '),
                      TextSpan(
                        text: 'Ben',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
