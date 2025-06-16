# CLAUDE.md - Monitor Server

This file provides guidance for AI assistants working with the Plough Monitor Server project. Please follow these instructions when helping with development, troubleshooting, or maintenance.

## Project Overview

The Plough Monitor Server is a standalone Dart application that provides real-time monitoring capabilities for the Plough graph visualization library. It serves as a bridge between Flutter applications and web-based debugging tools, offering comprehensive monitoring and analysis features.

### Architecture

- **Backend**: Pure Dart server using Shelf framework
- **Frontend**: Embedded HTML/CSS/JavaScript web console
- **Communication**: WebSocket for real-time data, HTTP REST API for session management
- **Data Storage**: In-memory buffers with configurable limits
- **Session Management**: Multi-session support with automatic session creation

## Development Commands

### Server Management
```bash
# Start server with default settings
dart run bin/monitor_server.dart

# Start with custom port
dart run bin/monitor_server.dart --port 8090

# Quick start script
./start.sh

# Install dependencies
dart pub get

# Check server health
curl http://localhost:8081/api/status
```

### Testing and Debugging
```bash
# Test WebSocket connection
wscat -c ws://localhost:8081/api/sessions/test/stream

# Check active sessions
curl http://localhost:8081/api/sessions

# Send test diagnostic data
curl -X POST http://localhost:8081/api/sessions/test/diagnostics \
  -H "Content-Type: application/json" \
  -d '{"type":"gesture_event","data":{"test":true}}'
```

## Code Structure and Guidelines

### Core Components

1. **`bin/monitor_server.dart`** - Main server entry point
   - Command-line argument parsing
   - Server initialization and routing
   - CORS middleware configuration

2. **`MonitorServer` class** - Core server logic
   - HTTP request handlers
   - WebSocket management
   - Session orchestration

3. **`MonitorSession` class** - Session data management
   - Event buffering (max 1000 events per type)
   - Recording functionality
   - Performance metrics calculation

### API Design Patterns

All endpoints follow RESTful conventions:
- `GET` for data retrieval
- `POST` for data creation/submission
- Auto-creation of sessions when accessed
- Consistent JSON response format
- CORS headers for web console access

### Data Flow

1. Flutter app sends diagnostic data via HTTP POST
2. Server stores data in session buffers
3. WebSocket clients receive real-time updates
4. Web console displays formatted data
5. Optional recording saves events for later analysis

## Configuration and Customization

### Server Configuration

Default settings in `MonitorServer.start()`:
- Port: 8081 (configurable via `--port`)
- Host: localhost only (security consideration)
- Buffer size: 1000 events per type
- WebSocket timeout: No explicit timeout

### Adding New Data Types

To support additional diagnostic data:

1. **Add handler in `_handlePostDiagnostics()`**:
```dart
case 'custom_event':
  session.addCustomEvent(eventData);
  _broadcastToWebSockets({
    'type': 'custom_event',
    'session_id': sessionId,
    'data': eventData,
  });
```

2. **Extend `MonitorSession` class**:
```dart
final List<Map<String, dynamic>> customEvents = [];

void addCustomEvent(Map<String, dynamic> event) {
  customEvents.insert(0, event);
  if (customEvents.length > maxBufferSize) {
    customEvents.removeLast();
  }
  if (isRecording) recordingData.add({'type': 'custom', 'data': event});
}
```

3. **Update web console JavaScript**:
```javascript
if (data.type === 'custom_event') {
  addEventToLog('customLog', data.data);
}
```

### Performance Tuning

#### Memory Management
- Buffer sizes are limited to prevent memory leaks
- Old events are automatically removed (FIFO)
- Sessions can be manually cleaned up if needed

#### Network Optimization
- Event batching in Flutter client (500ms intervals)
- WebSocket message filtering by session
- Compression could be added for large payloads

#### Concurrency
- Multiple WebSocket clients supported
- Session isolation prevents cross-contamination
- Thread-safe operations (Dart isolate model)

## Integration Guidelines

### Flutter App Setup

Required configuration in Flutter app:
```dart
import 'package:plough/src/debug/external_debug_client.dart';

void main() async {
  // Enable Plough debug features
  await Plough().initializeDebugFeatures(
    enableServer: true,
    enablePerformanceMonitoring: true,
    serverPort: 8080, // Internal server
  );

  // Connect to external debug server
  if (kDebugMode) {
    externalDebugClient.setServerUrl('http://localhost:8081');
    externalDebugClient.enable();
  }

  runApp(MyApp());
}
```

### Client-Side Data Sending

Standard diagnostic data format:
```dart
// Send gesture event
externalDebugClient.sendLog(
  category: LogCategory.gesture,
  level: 'DEBUG',
  message: 'Node interaction detected',
  metadata: {
    'event_type': 'tap',
    'node_id': nodeId,
    'position': {'x': position.dx, 'y': position.dy},
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

## Troubleshooting Common Issues

### Server Startup Problems

1. **Port already in use**:
   ```bash
   # Find process using port
   lsof -i :8081
   
   # Kill process or use different port
   dart run bin/monitor_server.dart --port 8082
   ```

2. **Permission errors**:
   - Ensure user has permission to bind to port
   - Try higher port numbers (> 1024)

3. **Dependency issues**:
   ```bash
   # Clean and reinstall
   dart pub deps
   dart pub get
   ```

### Connection Issues

1. **WebSocket connection fails**:
   - Check browser console for CORS errors
   - Verify server is running and accessible
   - Test with curl or wscat

2. **No data appearing**:
   - Confirm Flutter app is sending data
   - Check session ID matches
   - Verify server logs for incoming requests

3. **Performance degradation**:
   - Monitor memory usage (session buffers)
   - Check for excessive WebSocket clients
   - Consider reducing buffer sizes

### Data Issues

1. **Missing events**:
   - Check buffer overflow (increase maxBufferSize)
   - Verify event type handlers are registered
   - Ensure proper JSON formatting

2. **Incorrect timestamps**:
   - Server adds timestamps if missing
   - Client should send ISO 8601 format
   - Consider timezone handling

## Security Considerations

### Network Security
- Server binds to localhost only by default
- No authentication mechanism (development tool)
- CORS allows all origins (* wildcard)

### Data Privacy
- All data stored in memory (not persisted)
- Session data cleared on server restart
- No sensitive data should be logged

### Production Usage
**IMPORTANT**: This monitor server is intended for development only:
- Never deploy to production environments
- Contains no security hardening
- Exposes detailed application internals
- No rate limiting or input validation

## Maintenance and Updates

### Regular Maintenance
- Monitor Dart SDK compatibility
- Update dependencies periodically
- Test with latest Plough library versions
- Review and update documentation

### Adding Features
When adding new functionality:
1. Follow existing code patterns
2. Add appropriate error handling
3. Update web console if needed
4. Document new APIs
5. Test with multiple sessions

### Version Management
- Maintain backward compatibility with Flutter client
- Use semantic versioning for releases
- Document breaking changes clearly
- Provide migration guides when needed

## Best Practices

### Code Quality
- Use descriptive variable names
- Add comments for complex logic
- Handle errors gracefully
- Follow Dart style guidelines

### Performance
- Avoid blocking operations in handlers
- Use appropriate data structures
- Monitor memory usage patterns
- Implement graceful degradation

### User Experience
- Provide clear error messages
- Include helpful debugging information
- Make web console intuitive
- Ensure responsive design

### Testing
- Test with multiple concurrent sessions
- Verify WebSocket stability
- Check memory leak scenarios
- Test error recovery paths

This monitor server is a powerful tool for understanding and optimizing Plough-based applications. Use it to identify performance bottlenecks, debug gesture handling issues, and monitor real-time application behavior during development.