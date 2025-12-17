#!/usr/bin/env dart

import 'dart:io';

/// Simple script to open Chrome to the Flutter web app
void main() {
  const url = 'http://localhost:8082';

  print('🚀 Opening $url in Chrome...');

  try {
    if (Platform.isWindows) {
      Process.runSync('cmd', ['/c', 'start chrome "$url"']);
    } else if (Platform.isMacOS) {
      Process.runSync('open', ['-a', 'Google Chrome', url]);
    } else {
      // Linux and other systems
      Process.runSync('google-chrome', [url]);
    }
    print('✅ Chrome opened successfully!');
  } catch (e) {
    print('❌ Failed to open Chrome: $e');
    print('💡 Please manually open: $url');
  }
}
