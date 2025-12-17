import 'package:logger/logger.dart';

/// Global logger instance for the application
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
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

  void logUI(String message, {dynamic data, dynamic error}) {
    if (error != null) {
      e('🖥️ UI Error: $message', error: error, stackTrace: StackTrace.current);
    } else if (data != null) {
      d('🖥️ UI: $message - Data: $data');
    } else {
      i('🖥️ UI: $message');
    }
  }

  void logState(String message, {dynamic data, dynamic error}) {
    if (error != null) {
      e('📊 State Error: $message', error: error, stackTrace: StackTrace.current);
    } else if (data != null) {
      d('📊 State: $message - Data: $data');
    } else {
      i('📊 State: $message');
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

void logUI(String message, {dynamic data, dynamic error}) {
  logger.logUI(message, data: data, error: error);
}

void logState(String message, {dynamic data, dynamic error}) {
  logger.logState(message, data: data, error: error);
}
