#!/usr/bin/env node

const { exec } = require('child_process');
const path = require('path');

console.log('🚀 Opening Blu-ray to Letterboxd in Chrome...');

// Wait a bit for servers to start
setTimeout(() => {
    const url = 'http://localhost:8082';

    // Detect platform and open Chrome
    const platform = process.platform;
    let command;

    if (platform === 'win32') {
        // Windows
        command = `start chrome "${url}"`;
    } else if (platform === 'darwin') {
        // macOS
        command = `open -a "Google Chrome" "${url}"`;
    } else {
        // Linux
        command = `google-chrome "${url}" || chromium-browser "${url}" || xdg-open "${url}"`;
    }

    console.log(`📱 Opening ${url} in Chrome...`);

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`❌ Failed to open Chrome: ${error.message}`);
            console.log('💡 Please manually open: http://localhost:8082');
            return;
        }
        console.log('✅ Chrome opened successfully!');
    });
}, 3000); // Wait 3 seconds for servers to start
