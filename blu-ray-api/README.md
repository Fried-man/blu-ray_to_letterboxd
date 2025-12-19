# Blu-ray API

A Dart server API for scraping Blu-ray collection data from blu-ray.com.

## Features

- **Health Endpoint**: Check server status
- **Collection Endpoint**: Fetch Blu-ray collection data by user ID
- **Configuration**: Environment variable-based configuration
- **CORS Support**: Cross-origin resource sharing enabled
- **Logging**: Comprehensive logging for debugging

## Endpoints

### GET /health
Returns server health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-12-16T20:58:35.872891",
  "service": "blu-ray-api"
}
```

### GET /api/user/{userId}/collection
Fetches Blu-ray collection data for the specified user ID.

**Parameters:**
- `userId` (path): Numeric user ID (must be 3+ digits)

**Success Response (200):**
```json
{
  "userId": "987553",
  "count": 25,
  "items": [
    {
      "Title": "The Shawshank Redemption",
      "Year": "1994",
      "Format": "Blu-ray",
      "Category": "Drama"
    }
  ]
}
```

**Error Response (400/500):**
```json
{
  "error": "Invalid user ID format",
  "message": "User ID must be numeric and at least 3 digits long"
}
```

## Configuration

Configure the server using environment variables:

- `PORT`: Server port (default: 3002)
- `HOST`: Server host (default: 0.0.0.0)
- `REQUEST_TIMEOUT_SECONDS`: HTTP request timeout (default: 15)
- `MAX_RETRIES`: Maximum retry attempts (default: 3)
- `ENABLE_CORS`: Enable CORS headers (default: true)

## Installation & Setup

### Prerequisites
- Dart SDK (3.10+)

### Install Dependencies
```bash
dart pub get
```

### Run the Server

**Option A: Full Application Launcher (Recommended)**
```bash
# Launch both API server and Flutter web app
dart run bin/launcher.dart

# Or specify components
dart run bin/launcher.dart full    # Both API and web app
dart run bin/launcher.dart api     # API server only
dart run bin/launcher.dart web     # Flutter web app only
```

**Option B: API Server Only**
```bash
dart run bin/server.dart
```

The server will start on `http://localhost:3002` by default.

## Testing

### Health Check
```bash
curl http://localhost:3002/health
```

### Collection Fetch
```bash
curl http://localhost:3002/api/user/987553/collection
```

## Project Structure

```
├── lib/
│   ├── models/
│   │   └── blu_ray_item.dart    # Data model for Blu-ray items
│   ├── services/
│   │   └── blu_ray_scraper.dart # Scraping logic
│   ├── utils/
│   │   └── logger.dart          # Logging utilities
│   └── config.dart              # Configuration management
├── bin/
│   └── server.dart              # Server entry point
└── test/
    └── server_test.dart         # Unit tests
```

## Architecture

The API consists of:

1. **Shelf Server**: HTTP server framework
2. **Scraper Service**: Handles Blu-ray.com data extraction
3. **Data Models**: Structured representation of collection items
4. **Configuration**: Environment-based settings
5. **Logging**: Debug and monitoring logs

## Data Model

Each Blu-ray item includes fields like:
- Title, Year, Format
- Region, Edition, Condition
- UPC, Category, Genre
- Director, Actors, Runtime
- And many more...

## Error Handling

The API provides detailed error messages for:
- Invalid user IDs
- Network failures
- Scraping errors
- Access restrictions (private collections)

## Development

### Running Tests
```bash
dart test
```

### Code Analysis
```bash
dart analyze
```

### Formatting
```bash
dart format .
```

## License

MIT License