import 'package:logger/logger.dart';

/// Global logger instance for the application
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);

/// Extension methods for easier logging
extension LoggerExtension on Logger {
  void logNetwork(String message, {dynamic data, dynamic error}) {
    if (error != null) {
      e('🌐 Network Error: $message', error: error, stackTrace: StackTrace.current);
    } else if (data != null) {
      d('🌐 Network: $message - Data: $data');
    } else {
      i('🌐 Network: $message');
    }
  }

  void logScraper(String message, {dynamic data, dynamic error}) {
    if (error != null) {
      e('🎬 Scraper Error: $message', error: error, stackTrace: StackTrace.current);
    } else if (data != null) {
      d('🎬 Scraper: $message - Data: $data');
    } else {
      i('🎬 Scraper: $message');
    }
  }

  void logApi(String message, {dynamic data, dynamic error}) {
    if (error != null) {
      e('🔗 API Error: $message', error: error, stackTrace: StackTrace.current);
    } else if (data != null) {
      d('🔗 API: $message - Data: $data');
    } else {
      i('🔗 API: $message');
    }
  }
}

/// Simple logging functions for easy access
void logNetwork(String message, {dynamic data, dynamic error}) {
  logger.logNetwork(message, data: data, error: error);
}

void logScraper(String message, {dynamic data, dynamic error}) {
  logger.logScraper(message, data: data, error: error);
}

void logApi(String message, {dynamic data, dynamic error}) {
  logger.logApi(message, data: data, error: error);
}
