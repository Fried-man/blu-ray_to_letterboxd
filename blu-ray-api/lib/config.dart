import 'dart:io';

/// Configuration for the Blu-ray API server
class ApiConfig {
  final String host;
  final int port;
  final Duration requestTimeout;
  final int maxRetries;
  final bool enableCors;

  const ApiConfig({
    this.host = '0.0.0.0',
    this.port = 3002,
    this.requestTimeout = const Duration(seconds: 15),
    this.maxRetries = 3,
    this.enableCors = true,
  });

  /// Create configuration from environment variables
  factory ApiConfig.fromEnvironment() {
    return ApiConfig(
      host: Platform.environment['HOST'] ?? '0.0.0.0',
      port: int.tryParse(Platform.environment['PORT'] ?? '3002') ?? 3002,
      requestTimeout: Duration(
        seconds: int.tryParse(Platform.environment['REQUEST_TIMEOUT_SECONDS'] ?? '15') ?? 15,
      ),
      maxRetries: int.tryParse(Platform.environment['MAX_RETRIES'] ?? '3') ?? 3,
      enableCors: Platform.environment['ENABLE_CORS']?.toLowerCase() != 'false',
    );
  }

  @override
  String toString() {
    return 'ApiConfig(host: $host, port: $port, requestTimeout: $requestTimeout, maxRetries: $maxRetries, enableCors: $enableCors)';
  }
}
