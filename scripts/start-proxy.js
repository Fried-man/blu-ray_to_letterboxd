#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');

let proxyProcess = null;

console.log('🚀 Starting Blu-ray Proxy Server...');

// Function to kill existing proxy process
function killExistingProxy() {
    console.log('🧹 Cleaning up existing proxy process...');

    return new Promise((resolve) => {
        const command = process.platform === 'win32'
            ? 'for /f "tokens=5" %a in (\'netstat -ano ^| findstr :3002\') do taskkill /PID %a /F 2>nul'
            : 'lsof -ti:3002 | xargs kill -9 2>/dev/null || true';

        exec(command, { shell: true }, () => {
            setTimeout(resolve, 500);
        });
    });
}

// Main start sequence
async function startProxy() {
    try {
        // Kill existing proxy
        await killExistingProxy();

        console.log('📋 Server will run on port 3002');

        // Start proxy server
        proxyProcess = spawn('npm', ['start'], {
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

    } catch (error) {
        console.error('❌ Start failed:', error.message);
        process.exit(1);
    }
}

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down proxy server...');
    if (proxyProcess) proxyProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down proxy server...');
    if (proxyProcess) proxyProcess.kill('SIGTERM');
    process.exit(0);
});

// Start the proxy
startProxy();
