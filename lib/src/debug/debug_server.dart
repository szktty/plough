import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';

/// HTTP server for monitoring
///
/// Provides a web interface for real-time monitoring of logs and graph state
@internal
class PloughMonitorServer {
  factory PloughMonitorServer() => _instance ??= PloughMonitorServer._();
  PloughMonitorServer._();

  static PloughMonitorServer? _instance;

  /// Support cleanup for hot reload
  static void resetInstance() {
    _instance?._forceShutdown();
    _instance = null;
  }

  HttpServer? _server;
  int _port = 8080;
  final List<WebSocket> _clients = [];
  final List<Map<String, dynamic>> _logBuffer = [];
  final int _maxLogBuffer = 1000;

  bool get isRunning => _server != null;
  int get port => _port;
  String get url => 'http://localhost:$_port';

  /// Start monitoring server
  Future<void> start({int port = 8080, bool tryAlternativePorts = true}) async {
    if (_server != null) {
      logWarning(
        LogCategory.debug,
        'Debug server is already running on port $_port',
      );
      return;
    }

    _port = port;

    // List of alternative ports
    final portsToTry = tryAlternativePorts
        ? [port, port + 1, port + 2, port + 10, port + 100]
        : [port];

    for (final tryPort in portsToTry) {
      try {
        _port = tryPort;

        // Attempt to stop existing server first, as port might be in use
        await _tryCleanupExistingServer();

        // Bind to localhost only (to bypass macOS sandbox restrictions)
        _server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          _port,
          shared: true,
        );
        logInfo(LogCategory.debug, 'Monitor server started on $url');
        logInfo(LogCategory.debug, 'Server port: ${_server!.port}');
        logInfo(
          LogCategory.debug,
          'Server address: ${_server!.address.address}',
        );

        // Set up listener and test immediately
        _server!.listen(
          (HttpRequest request) {
            logInfo(LogCategory.debug, 'Got HTTP request!');
            _handleRequest(request);
          },
          onError: (dynamic error) {
            logError(LogCategory.debug, 'Server request error: $error');
          },
          onDone: () {
            logInfo(LogCategory.debug, 'Server connection closed');
          },
        );

        // Verify if the server is actually listening
        logInfo(
          LogCategory.debug,
          'Server listening: address=${_server!.address}, port=${_server!.port}',
        );

        // Test if the server is working correctly
        Future<void>.delayed(
          const Duration(milliseconds: 100),
        ).then((_) => _testServerConnection());

        return; // Success
      } on SocketException catch (e) {
        logWarning(
          LogCategory.debug,
          'Failed to start server on port $tryPort: ${e.message}',
        );
        _server = null;

        if (tryPort == portsToTry.last) {
          // Failed even on the last port
          logError(
            LogCategory.debug,
            'Failed to start monitor server on any port: $portsToTry',
          );
          throw SocketException(
            'Failed to start monitor server on any port: $portsToTry',
          );
        }
      }
    }
  }

  /// Tests server connection
  Future<void> _testServerConnection() async {
    try {
      final client = HttpClient();

      // Set User-Agent
      client.userAgent = 'PloughMonitorServer/1.0';

      final request = await client.getUrl(
        Uri.parse('http://localhost:$_port/test'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        logInfo(LogCategory.debug, 'Server connection test successful');
      } else {
        logWarning(
          LogCategory.debug,
          'Server connection test failed: ${response.statusCode}',
        );
      }

      client.close();
    } catch (e) {
      logWarning(LogCategory.debug, 'Server connection test failed: $e');
      logWarning(
        LogCategory.debug,
        'This may be due to macOS sandbox restrictions',
      );

      // Suggest alternative in case of macOS sandbox issues
      logInfo(
        LogCategory.debug,
        'Alternative: Use the CLI monitor server (dart monitor/monitor_server.dart)',
      );
    }
  }

  /// Attempts to clean up existing server
  Future<void> _tryCleanupExistingServer() async {
    try {
      // Attempt a short connection to check for an existing server
      final socket = await Socket.connect(
        'localhost',
        _port,
        timeout: const Duration(milliseconds: 100),
      );
      await socket.close();
      // If connected, wait a bit and retry
      logWarning(
        LogCategory.debug,
        'Found existing server on port $_port, waiting for cleanup...',
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } on SocketException {
      // If unable to connect, no issue (port is free)
    }
  }

  /// Stops the monitoring server
  Future<void> stop() async {
    if (_server == null) return;

    // Disconnect all clients
    for (final client in _clients) {
      await client.close();
    }
    _clients.clear();

    await _server!.close();
    _server = null;
    logInfo(LogCategory.debug, 'Monitor server stopped');
  }

  /// Forces shutdown (synchronous)
  void _forceShutdown() {
    try {
      for (final client in _clients) {
        client.close();
      }
      _clients.clear();

      _server?.close(force: true);
      _server = null;
    } on Exception {
      // Ignore errors
    }
  }

  /// Broadcasts log
  void broadcastLog(LogCategory category, String level, String message) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'category': category.name,
      'level': level,
      'message': message,
    };

    // Add to buffer
    _logBuffer.add(logEntry);
    if (_logBuffer.length > _maxLogBuffer) {
      _logBuffer.removeAt(0);
    }

    // Broadcast to connected clients
    final data = jsonEncode({'type': 'log', 'data': logEntry});

    _clients.removeWhere((client) {
      try {
        client.add(data);
        return false;
      } catch (e) {
        return true; // Remove disconnected client
      }
    });
  }

  /// Broadcasts graph state
  void broadcastGraphState(Map<String, dynamic> state) {
    final data = jsonEncode({'type': 'graph_state', 'data': state});

    _clients.removeWhere((client) {
      try {
        client.add(data);
        return false;
      } catch (e) {
        return true;
      }
    });
  }

  void _handleRequest(HttpRequest request) {
    try {
      logInfo(
        LogCategory.debug,
        'Received request: ${request.method} ${request.uri.path}',
      );
      logInfo(LogCategory.debug, 'Headers: ${request.headers}');
      logInfo(
        LogCategory.debug,
        'Remote: ${request.connectionInfo?.remoteAddress}',
      );
      logInfo(LogCategory.debug, 'Protocol: ${request.protocolVersion}');

      final uri = request.uri;

      // Simple test response
      if (uri.path == '/test') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.text
          ..write('Debug server is working!')
          ..close();
        return;
      }

      if (uri.path == '/') {
        _serveDebugPage(request);
      } else if (uri.path == '/ws') {
        _handleWebSocket(request);
      } else if (uri.path == '/api/logs') {
        _serveLogs(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    } catch (e, stackTrace) {
      logError(LogCategory.debug, 'Error handling request: $e');
      logError(LogCategory.debug, 'Stack trace: $stackTrace');

      try {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Internal Server Error')
          ..close();
      } on Exception {
        // Response already closed
      }
    }
  }

  void _serveDebugPage(HttpRequest request) {
    try {
      logDebug(LogCategory.debug, 'Serving debug page');
      final html = _generateDebugPageHtml();
      request.response
        ..headers.contentType = ContentType.html
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..write(html)
        ..close();
      logDebug(LogCategory.debug, 'Debug page served successfully');
    } catch (e) {
      logError(LogCategory.debug, 'Error serving debug page: $e');
      rethrow;
    }
  }

  void _handleWebSocket(HttpRequest request) {
    WebSocketTransformer.upgrade(request).then((WebSocket socket) {
      _clients.add(socket);
      logDebug(
        LogCategory.debug,
        'WebSocket client connected (${_clients.length} total)',
      );

      // Send past logs on connection
      for (final log in _logBuffer) {
        socket.add(jsonEncode({'type': 'log', 'data': log}));
      }

      socket.listen(
        (data) {
          // Handle messages from client (for future extension)
        },
        onDone: () {
          _clients.remove(socket);
          logDebug(
            LogCategory.debug,
            'WebSocket client disconnected (${_clients.length} total)',
          );
        },
        onError: (Object error) {
          _clients.remove(socket);
          logWarning(LogCategory.debug, 'WebSocket error: $error');
        },
      );
    });
  }

  void _serveLogs(HttpRequest request) {
    try {
      logDebug(LogCategory.debug, 'API /api/logs requested');

      // For now, return only buffered logs (simple)
      final response = {'logs': _logBuffer, 'count': _logBuffer.length};

      logDebug(
        LogCategory.debug,
        'Returning ${_logBuffer.length} logs from buffer',
      );

      request.response
        ..headers.contentType = ContentType.json
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        ..headers.add('Access-Control-Allow-Headers', 'Content-Type')
        ..write(jsonEncode(response))
        ..close();

      logDebug(LogCategory.debug, 'API response sent successfully');
    } catch (e, stackTrace) {
      logError(LogCategory.debug, 'Error in _serveLogs: $e');
      logError(LogCategory.debug, 'Stack trace: $stackTrace');

      try {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'error': 'Internal server error',
              'message': e.toString(),
            }),
          )
          ..close();
      } catch (closeError) {
        logError(LogCategory.debug, 'Error closing response: $closeError');
      }
    }
  }

  String _generateDebugPageHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>Plough Monitor Console</title>
    <meta charset="utf-8">
    <style>
        body { font-family: monospace; margin: 0; padding: 20px; background: #1e1e1e; color: #d4d4d4; }
        .header { border-bottom: 1px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .controls { margin-bottom: 20px; }
        .controls button { margin-right: 10px; padding: 5px 10px; }
        .log-container { height: 70vh; overflow-y: auto; border: 1px solid #333; padding: 10px; background: #252526; }
        .log-entry { margin-bottom: 5px; }
        .log-timestamp { color: #569cd6; }
        .log-category { color: #4ec9b0; }
        .log-level-DEBUG { color: #9cdcfe; }
        .log-level-INFO { color: #4fc1ff; }
        .log-level-WARNING { color: #ffcc02; }
        .log-level-ERROR { color: #f44747; }
        .filter-controls { margin-bottom: 10px; }
        .filter-controls select, .filter-controls input { margin-right: 10px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Plough Monitor Console</h1>
        <p>Real-time log monitoring and debug information</p>
    </div>
    
    <div class="controls">
        <button onclick="clearLogs()">Clear Logs</button>
        <button onclick="exportLogs()">Export Logs</button>
        <span id="status">Connecting...</span>
    </div>
    
    <div class="filter-controls">
        <select id="categoryFilter">
            <option value="">All Categories</option>
            <option value="gesture">Gesture</option>
            <option value="selection">Selection</option>
            <option value="drag">Drag</option>
            <option value="tap">Tap</option>
            <option value="layout">Layout</option>
            <option value="rendering">Rendering</option>
            <option value="graph">Graph</option>
            <option value="performance">Performance</option>
            <option value="debug">Debug</option>
            <option value="state">State</option>
            <option value="animation">Animation</option>
            <option value="hitTest">HitTest</option>
        </select>
        
        <select id="levelFilter">
            <option value="">All Levels</option>
            <option value="DEBUG">Debug</option>
            <option value="INFO">Info</option>
            <option value="WARNING">Warning</option>
            <option value="ERROR">Error</option>
        </select>
        
        <input type="text" id="searchFilter" placeholder="Search message...">
    </div>
    
    <div class="log-container" id="logContainer"></div>
    
    <script>
        const ws = new WebSocket('ws://localhost:$_port/ws');
        const logContainer = document.getElementById('logContainer');
        const statusElement = document.getElementById('status');
        let logs = [];
        
        ws.onopen = () => {
            statusElement.textContent = 'Connected';
            statusElement.style.color = '#4fc1ff';
        };
        
        ws.onclose = () => {
            statusElement.textContent = 'Disconnected';
            statusElement.style.color = '#f44747';
        };
        
        ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            if (message.type === 'log') {
                logs.push(message.data);
                if (logs.length > 1000) logs.shift();
                updateLogDisplay();
            }
        };
        
        function updateLogDisplay() {
            const categoryFilter = document.getElementById('categoryFilter').value;
            const levelFilter = document.getElementById('levelFilter').value;
            const searchFilter = document.getElementById('searchFilter').value.toLowerCase();
            
            const filteredLogs = logs.filter(log => {
                if (categoryFilter && log.category !== categoryFilter) return false;
                if (levelFilter && log.level !== levelFilter) return false;
                if (searchFilter && !log.message.toLowerCase().includes(searchFilter)) return false;
                return true;
            });
            
            logContainer.innerHTML = filteredLogs.map(log => {
                const time = new Date(log.timestamp).toLocaleTimeString();
                return '<div class="log-entry">' +
                    '<span class="log-timestamp">[' + time + ']</span>' +
                    '<span class="log-category">[' + log.category + ']</span>' +
                    '<span class="log-level-' + log.level + '">[' + log.level + ']</span>' +
                    log.message +
                    '</div>';
            }).join('');
            
            logContainer.scrollTop = logContainer.scrollHeight;
        }
        
        function clearLogs() {
            logs = [];
            updateLogDisplay();
        }
        
        function exportLogs() {
            const data = JSON.stringify(logs, null, 2);
            const blob = new Blob([data], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'plough-debug-' + new Date().toISOString() + '.json';
            a.click();
            URL.revokeObjectURL(url);
        }
        
        // Handle filter change
        document.getElementById('categoryFilter').addEventListener('change', updateLogDisplay);
        document.getElementById('levelFilter').addEventListener('change', updateLogDisplay);
        document.getElementById('searchFilter').addEventListener('input', updateLogDisplay);
    </script>
</body>
</html>
''';
  }
}
