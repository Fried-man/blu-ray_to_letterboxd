#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Starting Blu-ray Proxy Server...');
console.log('📋 Server will run on port 3002');

// Start proxy server
const proxyProcess = spawn('npm', ['start'], {
    cwd: path.join(__dirname, '..', 'proxy-server'),
    stdio: ['inherit', 'inherit', 'inherit'],
    shell: true
});

proxyProcess.on('error', (error) => {
    console.error('❌ Failed to start proxy server:', error.message);
    process.exit(1);
});

console.log('✅ Proxy server starting...');
console.log('🔍 Health check: http://localhost:3002/health');

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down proxy server...');
    proxyProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down proxy server...');
    proxyProcess.kill('SIGTERM');
    process.exit(0);
});
