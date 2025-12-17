#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');

let flutterProcess = null;

console.log('🚀 Starting Flutter Web App...');

// Function to kill existing Flutter process
function killExistingFlutter() {
    console.log('🧹 Cleaning up existing Flutter process...');

    return new Promise((resolve) => {
        const command = process.platform === 'win32'
            ? 'for /f "tokens=5" %a in (\'netstat -ano ^| findstr :8082\') do taskkill /PID %a /F 2>nul'
            : 'lsof -ti:8082 | xargs kill -9 2>/dev/null || true';

        exec(command, { shell: true }, () => {
            setTimeout(resolve, 500);
        });
    });
}

// Main start sequence
async function startFlutter() {
    try {
        // Kill existing Flutter process
        await killExistingFlutter();

        console.log('📋 App will run on port 8082');

        // Start Flutter web app
        flutterProcess = spawn('flutter', ['run', '-d', 'web-server', '--web-port=8082'], {
            cwd: path.join(__dirname, '..', 'app'),
            stdio: ['inherit', 'inherit', 'inherit'],
            shell: true
        });

        flutterProcess.on('error', (error) => {
            console.error('❌ Failed to start Flutter web app:', error.message);
            process.exit(1);
        });

        console.log('✅ Flutter web app starting...');
        console.log('🌐 Open your browser to: http://localhost:8082');

    } catch (error) {
        console.error('❌ Start failed:', error.message);
        process.exit(1);
    }
}

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down Flutter web app...');
    if (flutterProcess) flutterProcess.kill('SIGINT');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down Flutter web app...');
    if (flutterProcess) flutterProcess.kill('SIGTERM');
    process.exit(0);
});

// Start Flutter
startFlutter();
