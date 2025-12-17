#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');
const http = require('http');

let proxyProcess = null;
let flutterProcess = null;

console.log('🚀 Launching Blu-ray to Letterboxd (Proxy + Web)...');

// Function to kill existing processes
function killExistingProcesses() {
    console.log('🧹 Cleaning up existing processes...');

    return new Promise((resolve) => {
        const commands = [];

        if (process.platform === 'win32') {
            // Windows: use netstat and taskkill
            commands.push('for /f "tokens=5" %a in (\'netstat -ano ^| findstr :3002\') do taskkill /PID %a /F 2>nul');
            commands.push('for /f "tokens=5" %a in (\'netstat -ano ^| findstr :8082\') do taskkill /PID %a /F 2>nul');
        } else {
            // Unix-like systems
            commands.push('lsof -ti:3002 | xargs kill -9 2>/dev/null || true');
            commands.push('lsof -ti:8082 | xargs kill -9 2>/dev/null || true');
        }

        let completed = 0;
        const total = commands.length;

        commands.forEach(cmd => {
            exec(cmd, { shell: true }, () => {
                completed++;
                if (completed >= total) {
                    setTimeout(resolve, 1000); // Wait 1 second for cleanup
                }
            });
        });

        if (commands.length === 0) {
            setTimeout(resolve, 500);
        }
    });
}

// Function to check if proxy server is ready
function checkProxyHealth() {
    return new Promise((resolve, reject) => {
        let attempts = 0;
        const maxAttempts = 30; // 30 seconds max
        let isResolved = false;

        const checkHealth = () => {
            if (isResolved) return; // Already resolved, stop checking

            attempts++;
            if (attempts > maxAttempts) {
                if (!isResolved) {
                    isResolved = true;
                    reject(new Error('Proxy server failed to start within 30 seconds'));
                }
                return;
            }

            const req = http.request({
                hostname: 'localhost',
                port: 3002,
                path: '/health',
                method: 'GET',
                timeout: 2000
            }, (res) => {
                if (isResolved) return;

                if (res.statusCode === 200) {
                    console.log('✅ Proxy server is ready!');
                    isResolved = true;
                    resolve(true);
                } else {
                    console.log('⏳ Proxy server responding but not ready...');
                    setTimeout(checkHealth, 1000);
                }
            });

            req.on('error', () => {
                if (isResolved) return;

                console.log(`⏳ Waiting for proxy server... (attempt ${attempts}/${maxAttempts})`);
                setTimeout(checkHealth, 1000);
            });

            req.on('timeout', () => {
                if (isResolved) return;

                req.destroy();
                console.log('⏳ Proxy server timeout, retrying...');
                setTimeout(checkHealth, 1000);
            });

            req.end();
        };

        // Start checking after initial delay
        setTimeout(checkHealth, 1000);
    });
}

// Function to check if Flutter web server is ready
function checkFlutterReady() {
    return new Promise((resolve, reject) => {
        let attempts = 0;
        const maxAttempts = 60; // 60 seconds max for Flutter (takes longer to compile)
        let isResolved = false;

        const checkReady = () => {
            if (isResolved) return; // Already resolved, stop checking

            attempts++;
            if (attempts > maxAttempts) {
                if (!isResolved) {
                    isResolved = true;
                    reject(new Error('Flutter web app failed to start within 60 seconds'));
                }
                return;
            }

            const req = http.request({
                hostname: 'localhost',
                port: 8082,
                path: '/',
                method: 'GET',
                timeout: 3000
            }, (res) => {
                if (isResolved) return;

                console.log('✅ Flutter web app is ready!');
                isResolved = true;
                resolve(true);
            });

            req.on('error', () => {
                if (isResolved) return;

                console.log(`⏳ Waiting for Flutter web app... (attempt ${attempts}/${maxAttempts})`);
                setTimeout(checkReady, 1000);
            });

            req.on('timeout', () => {
                if (isResolved) return;

                req.destroy();
                console.log('⏳ Flutter web app timeout, retrying...');
                setTimeout(checkReady, 1000);
            });

            req.end();
        };

        // Start checking after initial delay
        setTimeout(checkReady, 2000);
    });
}

// Main launch sequence
async function launchApp() {
    try {
        // Step 1: Kill existing processes
        await killExistingProcesses();

        // Step 2: Start proxy server
        console.log('📋 Starting Proxy Server on port 3002...');
        proxyProcess = spawn('npm', ['start'], {
            cwd: path.join(__dirname, '..', 'proxy-server'),
            stdio: ['inherit', 'inherit', 'inherit'],
            shell: true
        });

        proxyProcess.on('error', (error) => {
            console.error('❌ Failed to start proxy server:', error.message);
        });

        // Step 3: Wait for proxy to be ready
        console.log('⏳ Waiting for proxy server...');
        await checkProxyHealth();

        // Step 4: Start Flutter web app
        console.log('📋 Starting Flutter Web App on port 8082...');
        flutterProcess = spawn('flutter', ['run', '-d', 'web-server', '--web-port=8082'], {
            cwd: path.join(__dirname, '..', 'app'),
            stdio: ['inherit', 'inherit', 'inherit'],
            shell: true
        });

        flutterProcess.on('error', (error) => {
            console.error('❌ Failed to start Flutter web app:', error.message);
        });

        // Step 5: Wait for Flutter to be ready
        console.log('⏳ Waiting for Flutter web app...');
        await checkFlutterReady();

        console.log('✅ Services started successfully!');
        console.log('🌐 Open your browser to: http://localhost:8082');
        console.log('🔍 Proxy health check: http://localhost:3002/health');
        console.log('🔄 Services are running. Press Ctrl+C to stop.');

    } catch (error) {
        console.error('❌ Launch failed:', error.message);
        process.exit(1);
    }
}

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down services...');
    if (proxyProcess) proxyProcess.kill('SIGINT');
    if (flutterProcess) flutterProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down services...');
    if (proxyProcess) proxyProcess.kill('SIGTERM');
    if (flutterProcess) flutterProcess.kill('SIGTERM');
    process.exit(0);
});

// Start the launch process
launchApp();
