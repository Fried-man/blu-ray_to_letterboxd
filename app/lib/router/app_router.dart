import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/collection_screen.dart';
import '../utils/logger.dart';

/// App router configuration using Go Router
final appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        logger.logUI('Navigating to home screen');
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/collection',
      name: 'collection',
      builder: (context, state) {
        logger.logUI('Navigating to collection screen');
        return const CollectionScreen();
      },
    ),
  ],
);
