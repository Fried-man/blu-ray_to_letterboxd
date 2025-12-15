#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Launching Blu-ray to Letterboxd (Proxy + Web)...');
console.log('📋 Starting Proxy Server on port 3002...');

// Start proxy server
const proxyProcess = spawn('npm', ['start'], {
    cwd: path.join(__dirname, '..', 'proxy-server'),
    stdio: ['inherit', 'inherit', 'inherit'],
    shell: true
});

proxyProcess.on('error', (error) => {
    console.error('❌ Failed to start proxy server:', error.message);
});

console.log('📋 Starting Flutter Web App on port 8082...');

// Wait a moment for proxy to start, then start Flutter
setTimeout(() => {
    const flutterProcess = spawn('flutter', ['run', '-d', 'web-server', '--web-port=8082'], {
        cwd: path.join(__dirname, '..'),
        stdio: ['inherit', 'inherit', 'inherit'],
        shell: true
    });

    flutterProcess.on('error', (error) => {
        console.error('❌ Failed to start Flutter web app:', error.message);
    });

    console.log('✅ Services starting...');
    console.log('🌐 Open your browser to: http://localhost:8082');
    console.log('🔍 Proxy health check: http://localhost:3002/health');

}, 2000);

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down services...');
    proxyProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down services...');
    proxyProcess.kill('SIGTERM');
    process.exit(0);
});
