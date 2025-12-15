#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Starting Flutter Web App...');
console.log('📋 App will run on port 8082');

// Start Flutter web app
const flutterProcess = spawn('flutter', ['run', '-d', 'web-server', '--web-port=8082'], {
    cwd: path.join(__dirname, '..'),
    stdio: ['inherit', 'inherit', 'inherit'],
    shell: true
});

flutterProcess.on('error', (error) => {
    console.error('❌ Failed to start Flutter web app:', error.message);
    process.exit(1);
});

console.log('✅ Flutter web app starting...');
console.log('🌐 Open your browser to: http://localhost:8082');

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down Flutter web app...');
    flutterProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down Flutter web app...');
    flutterProcess.kill('SIGTERM');
    process.exit(0);
});
