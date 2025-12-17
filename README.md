# Blu-ray to Letterboxd

A Flutter web application that scrapes Blu-ray collection data from blu-ray.com and displays it in a user-friendly interface.

## Features

- 🔍 **Blu-ray Collection Scraping**: Fetches movie data from blu-ray.com collections
- 🌐 **Web-First Design**: Built for web deployment with responsive UI
- 📊 **State Management**: Uses Riverpod for clean state management
- 🧭 **Navigation**: GoRouter for declarative routing
- 📝 **Comprehensive Logging**: Detailed logging for debugging and monitoring
- 🔄 **Cross-Platform**: Works on web, desktop, and mobile

## Architecture

- **Frontend**: Flutter web app with modern UI
- **Backend Proxy**: Node.js/Express server to handle CORS for web scraping
- **State Management**: Riverpod providers
- **Routing**: GoRouter
- **HTTP Client**: Dio with custom interceptors
- **Logging**: Custom logger with multiple loggers (Network, Scraper, UI, State)

## Prerequisites

- Flutter SDK (3.0+)
- Node.js (16+)
- npm or yarn

## Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd blu-ray_to_letterboxd
```

### 2. Install Flutter Dependencies
```bash
cd app
flutter pub get
```

### 3. Setup Proxy Server
```bash
cd proxy-server
npm install
```

### 4. Run the Application

**Option A: VS Code Launch (Recommended)**

Use the pre-configured VS Code launch configurations:

1. Open in VS Code
2. Go to Run & Debug (Ctrl+Shift+D)
3. Select "Launch Full App (Proxy + Web + Chrome)" from the dropdown
4. Click the green play button

This will automatically:
- Kill any existing processes on ports 3002 and 8082
- Start the proxy server on port 3002 and wait for it to be ready
- Start the Flutter web app on port 8082 and wait for it to be ready
- Open Chrome to http://localhost:8082

**Alternative VS Code Launches:**
- "Launch App (Proxy + Web)" - Starts services without opening Chrome
- "Start Proxy Server Only" - Only starts the proxy server (cleans up first)
- "Start Flutter Web Only" - Only starts the web app (cleans up first)

**Option B: Manual Terminal Commands**

Start the proxy server:
```bash
cd proxy-server
npm start
```
*Server runs on http://localhost:3002*

In a new terminal, start the Flutter web app:
```bash
cd app
flutter run -d web-server --web-port=8082
```
*App runs on http://localhost:8082*

**Option B: Production**

For production deployment, both the proxy server and Flutter web app need to be deployed to the same domain to avoid CORS issues.

## Usage

1. Open the web app in your browser
2. Enter a Blu-ray.com user ID (e.g., `987553`)
3. Click "Fetch Collection"
4. View your Blu-ray collection with filtering options

## API Endpoints

### Proxy Server Endpoints

- `GET /health` - Health check
- `GET /api/blu-ray/collection/:userId` - Fetch collection data
- `GET /api/blu-ray/collection/:userId?action=exportcsv` - Fetch CSV export

### Data Structure

Each Blu-ray item contains:
- Title and year
- Format and edition
- Category and genre
- URLs and image URLs
- Condition and location
- Purchase details

## Development

### Running Tests
```bash
cd app
flutter test
```

### Building for Production
```bash
cd app
flutter build web
```

### Proxy Server Development
```bash
cd proxy-server
npm run dev  # if you add a dev script
```

## Troubleshooting

### Port Conflicts
The VS Code launch configurations automatically clean up existing processes. If you still get "address already in use" errors:

1. Manually kill processes:
   - Windows: `taskkill /F /PID <PID>` (find PIDs with `netstat -ano | findstr :3002`)
   - Linux/Mac: `kill -9 $(lsof -ti:3002)`

2. Or change ports in the code:
   - `proxy-server/server.js`: Change PORT variable
   - `lib/services/blu_ray_scraper.dart`: Update _proxyBaseUrl
   - Run with different --web-port

### Blank White Screen
If the web app shows a blank white screen:
1. Check that both proxy (port 3002) and web app (port 8082) are running
2. Verify proxy health: `http://localhost:3002/health`
3. Check browser console for JavaScript errors
4. Try refreshing the page after services are fully started

### CORS Issues
- For development: Use the local proxy server
- For production: Deploy proxy and web app to same domain

### Network Errors
- Check that blu-ray.com is accessible
- Verify user ID exists and collection is public
- Check proxy server logs for errors

## Project Structure

```
├── app/                          # Flutter application
│   ├── lib/
│   │   ├── main.dart             # App entry point
│   │   ├── models/               # Data models
│   │   ├── providers/            # Riverpod providers
│   │   ├── router/               # GoRouter configuration
│   │   ├── screens/              # UI screens
│   │   ├── services/             # Business logic & API calls
│   │   └── utils/                # Utilities (logger, etc.)
│   ├── test/                     # Unit and integration tests
│   ├── web/                      # Web build assets
│   └── pubspec.yaml              # Flutter dependencies
├── proxy-server/                 # CORS proxy server
│   ├── server.js                 # Express server
│   └── package.json              # Node.js dependencies
├── scripts/                      # Development scripts
└── README.md                     # This file
```

## Technologies Used

- **Flutter**: UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **GoRouter**: Navigation
- **Dio**: HTTP client
- **Express.js**: Proxy server
- **Axios**: Server-side HTTP requests

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Support

For issues and questions:
- Check the troubleshooting section
- Review the logs for error details
- Ensure all prerequisites are installed