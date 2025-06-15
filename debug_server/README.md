# Plough Debug Server (Dart)

A debug server built in Dart for the Plough library.

## Features

- **Dart Native**: No Python dependencies, runs on Dart only
- **Real-time Monitoring**: Live debugging via WebSocket
- **Web Console**: Browser-based debug interface
- **Session Management**: Support for multiple debug sessions
- **Recording Feature**: Record and replay debug events
- **Data Export**: Detailed data output in JSON format

## Installation

```bash
cd debug_server
dart pub get
```

## Usage

### Starting the Server

```bash
# Start with default port (8081)
dart run bin/debug_server.dart

# Start with custom port
dart run bin/debug_server.dart --port 8090

# Show help
dart run bin/debug_server.dart --help
```

### Accessing the Web Console

Open the following URLs in your browser:
- **Main Console**: `http://localhost:8081`
- **Server Status**: `http://localhost:8081/api/status`

## API Endpoints

### Session Management
- `GET /api/sessions` - List active sessions
- `POST /api/sessions` - Create new session
- `GET /api/sessions/{id}` - Get session details
- `GET /api/sessions/{id}/export` - Export session data

### Real-time Communication
- `GET /api/sessions/{id}/stream` - WebSocket connection
- `POST /api/sessions/{id}/diagnostics` - Send diagnostic data

### Recording
- `POST /api/sessions/{id}/record/start` - Start recording
- `POST /api/sessions/{id}/record/stop` - Stop recording

### Legacy Compatibility
- `POST /api/logs/batch` - Receive logs for existing clients
- `GET /api/status` - Check server status

## Flutter App Integration

Update `example/lib/main.dart` for automatic connection:

```dart
import 'package:plough/src/debug/external_debug_client.dart';

void main() async {
  // Existing configuration...
  await Plough().initializeDebugFeatures(
    enableServer: true,
    enablePerformanceMonitoring: true,
    serverPort: 8080, // Built-in server
  );

  // Connect to Dart debug server
  if (kDebugMode) {
    externalDebugClient.setServerUrl('http://localhost:8081');
    externalDebugClient.enable();
  }

  runApp(MyApp());
}
```

## Web Console Features

### Overview Tab
- Number of active sessions
- Total event count
- Connected client count
- Server uptime
- Recent activity

### Events Tab
- Real-time display of all events
- Filtering by event type
- Text search
- Clear event log

### Performance Tab
- Display performance metrics
- FPS monitoring
- Frame time analysis

### Recording Tab
- Start/stop session recording
- Export recorded data
- Display recording status

## Diagnostic Data Format

The server receives and processes the following diagnostic data:

```json
{
  "type": "gesture_event",
  "data": {
    "timestamp": "2024-01-01T12:00:00.000Z",
    "event_type": "tap",
    "position": {"x": 150, "y": 200},
    "node_id": "node_123",
    "was_consumed": true
  }
}
```

### Supported Data Types
- `gesture_event` - Gesture events
- `render_event` - Rendering events
- `state_change` - State changes
- `performance_sample` - Performance samples
- `snapshot` - Graph snapshots

## Troubleshooting

### Server Won't Start
```bash
# Check if port is in use
lsof -i :8081

# Try a different port
dart run bin/debug_server.dart --port 8082
```

### Dependency Errors
```bash
# Re-fetch packages
dart pub get

# Check Dart SDK version
dart --version
```

### WebSocket Connection Errors
- Check browser developer tools for console errors
- Verify firewall settings
- Check CORS configuration

## Developer Information

### Server Extension
Adding new API endpoints:

```dart
// Add to router in bin/debug_server.dart
router.get('/api/custom', _handleCustomEndpoint);

Response _handleCustomEndpoint(Request request) {
  return Response.ok(
    jsonEncode({'message': 'Custom endpoint'}),
    headers: {'Content-Type': 'application/json'},
  );
}
```

### Custom Data Processing
Add support for new data types to the `DebugSession` class:

```dart
void addCustomEvent(Map<String, dynamic> event) {
  customEvents.insert(0, event);
  if (customEvents.length > maxBufferSize) {
    customEvents.removeLast();
  }
  if (isRecording) recordingData.add({'type': 'custom', 'data': event});
}
```

## Performance

- **Memory Usage**: Buffer up to 1000 events per session
- **Concurrency**: Support for multiple concurrent WebSocket clients
- **Scalability**: Handles high-volume event streams

## License

This project is provided under the same license as the Plough library.