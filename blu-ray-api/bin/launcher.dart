#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Launcher for the complete Blu-ray application stack
class AppLauncher {
  Process? _apiProcess;
  Process? _flutterProcess;

  /// Launch both API server and Flutter web app
  Future<void> launchFullApp() async {
    print('🚀 Launching Blu-ray API + Web App...');

    try {
      // Kill existing processes
      await _killExistingProcesses();

      // Start API server
      await _startApiServer();

      // Wait for API to be ready
      await _waitForApiReady();

      // Start Flutter web app
      await _startFlutterApp();

      // Wait for Flutter to be ready
      await _waitForFlutterReady();

      // Optionally open Chrome
      _openChrome();

      print('🎉 All services started successfully!');
      print('🔍 API Health: http://localhost:3002/health');
      print('🎬 Collection API: http://localhost:3002/api/collection/{userId}');
      print('🌐 Web App: http://localhost:8082');
      print('🔄 Services are running. Press Ctrl+C to stop.');

      // Keep running until interrupted
      await _handleShutdown();

    } catch (e) {
      print('❌ Launch failed: $e');
      await _shutdown();
      exit(1);
    }
  }

  /// Launch only the API server
  Future<void> launchApiOnly() async {
    print('🚀 Starting Blu-ray API Server...');

    try {
      await _killExistingApiProcess();
      await _startApiServer();

      print('✅ API server started successfully!');
      print('🔍 Health check: http://localhost:3002/health');
      print('🎬 Collection API: http://localhost:3002/api/collection/{userId}');

      await _handleShutdown();

    } catch (e) {
      print('❌ API launch failed: $e');
      await _shutdown();
      exit(1);
    }
  }

  /// Launch only the Flutter web app
  Future<void> launchWebAppOnly() async {
    print('🚀 Starting Flutter Web App...');

    try {
      await _killExistingFlutterProcess();
      await _startFlutterApp();

      print('✅ Flutter web app started successfully!');
      print('🌐 Open your browser to: http://localhost:8082');

      await _handleShutdown();

    } catch (e) {
      print('❌ Web app launch failed: $e');
      await _shutdown();
      exit(1);
    }
  }

  Future<void> _killExistingProcesses() async {
    print('🧹 Cleaning up existing processes...');
    await Future.wait([
      _killExistingApiProcess(),
      _killExistingFlutterProcess(),
    ]);
    // Give processes time to fully terminate
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> _killExistingApiProcess() async {
    await _killProcessOnPort(3002);
  }

  Future<void> _killExistingFlutterProcess() async {
    await _killProcessOnPort(8082);
  }

  Future<void> _killProcessOnPort(int port) async {
    try {
      if (Platform.isWindows) {
        await Process.run(
          'cmd',
          ['/c', 'for /f "tokens=5" %a in (\'netstat -ano ^| findstr :$port\') do taskkill /PID %a /F 2>nul'],
          runInShell: true,
        );
      } else {
        await Process.run(
          'bash',
          ['-c', 'lsof -ti:$port | xargs kill -9 2>/dev/null || true'],
          runInShell: true,
        );
      }
    } catch (e) {
      // Ignore errors when killing processes
    }
  }

  Future<void> _startApiServer() async {
    print('📋 Starting API Server on port 3002...');

    final workingDir = Directory.current.parent.path;
    final apiDir = '$workingDir${Platform.pathSeparator}blu-ray-api';

    _apiProcess = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      workingDirectory: apiDir,
      mode: ProcessStartMode.inheritStdio,
    );

    _apiProcess!.exitCode.then((code) {
      if (code != 0) {
        print('❌ API server exited with code $code');
      }
    });
  }

  Future<void> _startFlutterApp() async {
    print('📋 Starting Flutter Web App on port 8082...');

    final workingDir = Directory.current.parent.path;
    final appDir = '$workingDir${Platform.pathSeparator}app';

    _flutterProcess = await Process.start(
      'flutter',
      ['run', '-d', 'web-server', '--web-port=8082'],
      workingDirectory: appDir,
      mode: ProcessStartMode.inheritStdio,
    );

    _flutterProcess!.exitCode.then((code) {
      if (code != 0) {
        print('❌ Flutter app exited with code $code');
      }
    });
  }

  Future<void> _waitForApiReady() async {
    print('⏳ Waiting for API server...');
    await _waitForService('http://localhost:3002/health', 'API server', 30);
  }

  Future<void> _waitForFlutterReady() async {
    print('⏳ Waiting for Flutter web app...');
    await _waitForService('http://localhost:8082/', 'Flutter web app', 60);
  }

  Future<void> _waitForService(String url, String serviceName, int maxAttempts) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 3));
        if (response.statusCode == 200) {
          print('✅ $serviceName is ready!');
          return;
        }
      } catch (e) {
        // Service not ready yet
      }

      print('⏳ Waiting for $serviceName... (attempt $attempt/$maxAttempts)');
      await Future.delayed(Duration(seconds: 1));
    }

    throw Exception('$serviceName failed to start within ${maxAttempts}s');
  }

  void _openChrome() {
    const url = 'http://localhost:8082';
    print('📋 Opening Chrome...');

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

  Future<void> _handleShutdown() async {
    // Set up signal handlers
    ProcessSignal.sigint.watch().listen((_) async {
      print('\n🛑 Shutting down services...');
      await _shutdown();
      exit(0);
    });

    ProcessSignal.sigterm.watch().listen((_) async {
      print('\n🛑 Shutting down services...');
      await _shutdown();
      exit(0);
    });

    // Wait indefinitely
    await Future.delayed(Duration(days: 365));
  }

  Future<void> _shutdown() async {
    if (_apiProcess != null) {
      _apiProcess!.kill(ProcessSignal.sigint);
    }
    if (_flutterProcess != null) {
      _flutterProcess!.kill(ProcessSignal.sigint);
    }

    // Give processes time to shut down gracefully
    await Future.delayed(Duration(seconds: 2));
  }
}

void main(List<String> args) async {
  final launcher = AppLauncher();

  if (args.isEmpty) {
    // Default: launch full app
    await launcher.launchFullApp();
  } else {
    switch (args[0]) {
      case 'api':
        await launcher.launchApiOnly();
      case 'web':
        await launcher.launchWebAppOnly();
      case 'full':
        await launcher.launchFullApp();
      default:
        print('Usage: dart run bin/launcher.dart [api|web|full]');
        print('  api  - Launch API server only');
        print('  web  - Launch Flutter web app only');
        print('  full - Launch both API and web app (default)');
        exit(1);
    }
  }
}
