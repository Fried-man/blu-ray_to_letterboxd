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

### 3. Install Dart API Dependencies
```bash
cd blu-ray-api
dart pub get
```

### 4. Run the Application

**Option A: VS Code Launch (Recommended)**

Use the pre-configured VS Code launch configurations:

1. Open in VS Code
2. Go to Run & Debug (Ctrl+Shift+D)
3. Select one of the launch options:
   - **"Launch Full App (API + Web)"** - Starts both API and web app with process management
   - **"Launch Full App (Compound)"** - Starts both services using compound launch
   - **"Start API Server Only"** - Only starts the API server
   - **"Start Flutter Web Only"** - Only starts the web app

The launchers will automatically:
- Kill any existing processes on ports 3002 and 8082
- Start the Dart API server on port 3002 and wait for it to be ready
- Start the Flutter web app on port 8082 and wait for it to be ready
- Keep all services running and handle graceful shutdown

**Option B: Dart Launcher (Terminal)**

Use the Dart launcher script to start all services:

```bash
# Launch both API server and Flutter web app
cd blu-ray-api
dart run bin/launcher.dart

# Or specify what to launch
dart run bin/launcher.dart full    # Both API and web app
dart run bin/launcher.dart api     # API server only
dart run bin/launcher.dart web     # Flutter web app only
```

**Option C: Manual Terminal Commands**

Start the API server:
```bash
cd blu-ray-api
dart run bin/server.dart
```
*API server runs on http://localhost:3002*

In a new terminal, start the Flutter web app:
```bash
cd app
flutter run -d web-server --web-port=8082
```
*Web app runs on http://localhost:8082*

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
The VS Code launch configurations and Dart launcher automatically clean up existing processes. If you still get "address already in use" errors:

1. Manually kill processes:
   - Windows: `taskkill /F /PID <PID>` (find PIDs with `netstat -ano | findstr :3002` or `:8082`)
   - Linux/Mac: `kill -9 $(lsof -ti:3002)` or `kill -9 $(lsof -ti:8082)`

2. Or change ports in environment variables:
   - API server: Set `PORT=3003` (default: 3002)
   - Flutter web app: Use `--web-port=8083` (default: 8082)

3. Or modify the VS Code launch configurations to use different ports

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
├── app/                          # Flutter web application
│   ├── lib/
│   │   ├── main.dart             # App entry point
│   │   ├── models/               # Data models
│   │   ├── providers/            # Riverpod providers
│   │   ├── router/               # GoRouter configuration
│   │   ├── screens/              # UI screens
│   │   ├── services/             # API client
│   │   └── utils/                # Utilities (logger, etc.)
│   ├── test/                     # Unit and integration tests
│   ├── web/                      # Web build assets
│   └── pubspec.yaml              # Flutter dependencies
├── blu-ray-api/                  # Dart API server
│   ├── lib/
│   │   ├── models/               # Data models
│   │   ├── services/             # Scraping logic
│   │   ├── utils/                # Utilities
│   │   └── config.dart           # Configuration
│   ├── bin/
│   │   ├── server.dart           # API server
│   │   └── launcher.dart         # Application launcher
│   └── pubspec.yaml              # Dart dependencies
└── README.md                     # This file
```

## Technologies Used

- **Flutter**: Web UI framework
- **Dart**: Programming language for both client and server
- **Riverpod**: State management
- **GoRouter**: Navigation
- **HTTP**: HTTP client (Flutter) and server (Dart API)
- **Shelf**: Dart web server framework
- **CSV**: Data parsing

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