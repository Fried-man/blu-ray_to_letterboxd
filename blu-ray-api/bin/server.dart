import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:blu_ray_api/services/blu_ray_scraper.dart';
import 'package:blu_ray_api/config.dart';

// CORS middleware
Middleware corsMiddleware = (Handler innerHandler) {
  return (Request request) async {
    final response = await innerHandler(request);
    return response.change(headers: {
      ...response.headers,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
    });
  };
};

// Load configuration
final _config = ApiConfig.fromEnvironment();

// Create scraper instance
final _scraper = BluRayScraper();

// Store startup timestamp
DateTime? _startupTime;

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/health', _healthHandler)
  ..get('/api/collection/<userId>', _collectionHandler);

Response _rootHandler(Request req) {
  return Response.ok('Blu-ray API Server\n');
}

Response _healthHandler(Request request) {
  return Response.ok(
    jsonEncode({
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'startedAt': _startupTime?.toIso8601String(),
      'service': 'blu-ray-api',
    }),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _collectionHandler(Request request) async {
  final userId = request.params['userId'];

  if (userId == null || userId.isEmpty) {
    return Response(
      400,
      body: jsonEncode({
        'error': 'User ID is required',
        'message': 'Please provide a valid user ID as a path parameter',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  // Validate user ID format
  if (!_scraper.isValidUserId(userId)) {
    return Response(
      400,
      body: jsonEncode({
        'error': 'Invalid user ID format',
        'message': 'User ID must be numeric and at least 3 digits long',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  try {
    final items = await _scraper.fetchCollection(userId);

    return Response.ok(
      jsonEncode({
        'userId': userId,
        'count': items.length,
        'items': items.map((item) => item.toMap()).toList(),
      }),
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response(
      500,
      body: jsonEncode({
        'error': 'Failed to fetch collection',
        'message': e.toString(),
        'userId': userId,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}

void main(List<String> args) async {
  // Record startup time
  _startupTime = DateTime.now();

  print('Starting Blu-ray API Server with config: $_config');

  // Use configured host and port
  final ip = InternetAddress(_config.host);

  // Configure a pipeline that logs requests and handles CORS.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_config.enableCors ? corsMiddleware : (innerHandler) => innerHandler)
      .addHandler(_router.call);

  final server = await serve(handler, ip, _config.port);
  print('Blu-ray API Server listening on http://${server.address.host}:${server.port}');
  print('Health check: http://localhost:${server.port}/health');
  print('Collection API: http://localhost:${server.port}/api/collection/{userId}');
}
