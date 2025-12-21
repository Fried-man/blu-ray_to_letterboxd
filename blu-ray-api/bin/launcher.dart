#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Launcher for the complete Blu-ray application stack
class AppLauncher {
  Process? _apiProcess;
  Process? _flutterProcess;

  int apiPort = 3003;

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
      print('🔍 API Health: http://localhost:$apiPort/health');
      print('🎬 Collection API: http://localhost:$apiPort/api/user/{userId}/collection');
      print('🌐 Web App: Running in Chrome browser');
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

      final port = Platform.environment['PORT'] ?? '3003';
      print('✅ API server started successfully!');
      print('🔍 Health check: http://localhost:$port/health');
      print('🎬 Collection API: http://localhost:$port/api/user/{userId}/collection');

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
      print('🌐 Web App: Running in Chrome browser');

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
    // Give processes time to fully terminate and sockets to be released
    print('⏳ Waiting for processes to terminate...');
    await Future.delayed(Duration(seconds: 3));

    // Double-check and kill any remaining processes
    await Future.wait([
      _killExistingApiProcess(),
      _killExistingFlutterProcess(),
    ]);
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _killExistingApiProcess() async {
    await _killProcessOnPort(apiPort);
  }

  Future<void> _killExistingFlutterProcess() async {
    // Kill any running flutter processes
    await _killFlutterProcesses();
  }

  Future<void> _killFlutterProcesses() async {
    try {
      if (Platform.isWindows) {
        await Process.run(
          'powershell.exe',
          ['-Command', r'''
            Get-Process -Name "flutter*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue;
            Get-Process -Name "dart*" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*flutter*" } | Stop-Process -Force -ErrorAction SilentlyContinue
          '''],
          runInShell: true,
        );
      } else {
        await Process.run(
          'pkill',
          ['-f', 'flutter'],
          runInShell: true,
        );
      }
    } catch (e) {
      // Ignore errors when killing processes
      print('Warning: Failed to kill Flutter processes: $e');
    }
  }

  Future<void> _killProcessOnPort(int port) async {
    try {
      if (Platform.isWindows) {
        // More robust Windows process killing using PowerShell
        await Process.run(
          'powershell.exe',
          ['-Command', '''
            \$processes = netstat -ano | findstr :$port | ForEach-Object {
              \$fields = \$_ -split '\\s+';
              if (\$fields.Length -ge 5 -and \$fields[1] -match ':$port') {
                \$pid = \$fields[4];
                try {
                  Stop-Process -Id \$pid -Force -ErrorAction Stop;
                  Write-Host "Killed process \$pid on port $port";
                } catch {
                  # Process might already be gone
                }
              }
            }
          '''],
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
      print('Warning: Failed to kill processes on port $port: $e');
    }
  }

  Future<void> _startApiServer() async {
    // Use the configured port
    final port = apiPort.toString();
    print('📋 Starting API Server on port $port...');

    // Wait for port to be available
    await _waitForPortAvailable(apiPort);

    // Set PORT environment variable for the child process
    final env = Map<String, String>.from(Platform.environment);
    env['PORT'] = port;

    // API server runs in current directory (blu-ray-api)
    if (Platform.isWindows) {
      // On Windows, run dart through cmd to ensure PATH is available
      _apiProcess = await Process.start(
        'cmd',
        ['/c', 'dart', 'run', 'bin/server.dart'],
        workingDirectory: '.',
        mode: ProcessStartMode.inheritStdio,
        environment: env,
      );
    } else {
      // On other platforms, run dart directly
      _apiProcess = await Process.start(
        'dart',
        ['run', 'bin/server.dart'],
        workingDirectory: '.',
        mode: ProcessStartMode.inheritStdio,
        environment: env,
      );
    }

    _apiProcess!.exitCode.then((code) {
      if (code != 0) {
        print('❌ API server exited with code $code');
      }
    });
  }

  Future<void> _startFlutterApp() async {
    print('📋 Starting Flutter Web App...');

    // Check if we're in the right directory structure
    final appDir = Directory('../app');
    if (!await appDir.exists()) {
      throw Exception('Flutter app directory not found at ../app. Make sure you\'re running from blu-ray-api directory.');
    }

    final pubspecFile = File('../app/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      throw Exception('Flutter project not found in ../app directory (missing pubspec.yaml).');
    }

    // Flutter app runs in ../app directory
    if (Platform.isWindows) {
      // On Windows, run flutter through cmd to ensure PATH is available
      _flutterProcess = await Process.start(
        'cmd',
        ['/c', 'flutter', 'run', '-d', 'chrome'],
        workingDirectory: '../app',
        mode: ProcessStartMode.inheritStdio,
        environment: Platform.environment,
      );
    } else {
      // On other platforms, run flutter directly
      _flutterProcess = await Process.start(
        'flutter',
        ['run', '-d', 'chrome'],
        workingDirectory: '../app',
        mode: ProcessStartMode.inheritStdio,
        environment: Platform.environment,
      );
    }

    _flutterProcess!.exitCode.then((code) {
      if (code != 0) {
        print('❌ Flutter app exited with code $code');
      }
    });
  }

  Future<void> _waitForApiReady() async {
    print('⏳ Waiting for API server...');
    await _waitForService('http://localhost:$apiPort/health', 'API server', 30);
  }

  Future<void> _waitForFlutterReady() async {
    print('⏳ Waiting for Flutter web app...');
    // Wait a bit for Flutter to start in Chrome
    await Future.delayed(Duration(seconds: 5));
    print('✅ Flutter web app is ready!');
  }

  Future<void> _waitForPortAvailable(int port) async {
    for (var attempt = 1; attempt <= 10; attempt++) {
      try {
        // Try to bind to the port briefly to check if it's available
        final server = await ServerSocket.bind(InternetAddress.anyIPv4, port, backlog: 1);
        await server.close();
        print('✅ Port $port is available');
        return;
      } catch (e) {
        // Port is still in use
      }

      print('⏳ Waiting for port $port to become available... (attempt $attempt/10)');
      await Future.delayed(Duration(seconds: 1));
    }

    throw Exception('Port $port is still in use after 10 seconds');
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
    // Browser is already opened by Flutter run -d chrome
    print('📋 Browser should be opening automatically...');
  }

  Future<void> _handleShutdown() async {
    // Set up signal handlers
    ProcessSignal.sigint.watch().listen((_) async {
      print('\n🛑 Shutting down services...');
      await _shutdown();
      exit(0);
    });

    // SIGTERM may not be available on all platforms (like Windows)
    try {
      ProcessSignal.sigterm.watch().listen((_) async {
        print('\n🛑 Shutting down services...');
        await _shutdown();
        exit(0);
      });
    } catch (e) {
      // SIGTERM not supported on this platform, continue without it
    }

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
