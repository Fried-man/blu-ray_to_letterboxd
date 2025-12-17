@echo off
echo 🚀 Starting Blu-ray API + Web App...

echo 📋 Starting API Server on port 3002...
start /B cmd /c "cd blu-ray-api && dart run bin/server.dart"

echo ⏳ Waiting for API server...
timeout /t 3 /nobreak > nul

echo 📋 Starting Flutter Web App on port 8082...
start /B cmd /c "cd app && flutter run -d web-server --web-port=8082"

echo ⏳ Waiting for Flutter web app...
timeout /t 8 /nobreak > nul

echo ✅ Services started!
echo 🔍 API Health: http://localhost:3002/health
echo 🎬 Collection API: http://localhost:3002/api/collection/{userId}
echo 🌐 Web App: http://localhost:8082

echo 📋 Opening browser...
start http://localhost:8082

echo 🎉 Both services are running! Press Ctrl+C to stop.
pause
