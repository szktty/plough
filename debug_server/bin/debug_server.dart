#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8081', help: 'Server port')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  final result = parser.parse(args);

  if (result['help'] as bool) {
    print('Plough Debug Server');
    print('Usage: dart bin/debug_server.dart [options]');
    print(parser.usage);
    return;
  }

  final port = int.tryParse(result['port'] as String) ?? 8081;

  final server = DebugServer();
  await server.start(port);
}

class DebugServer {
  final Map<String, DebugSession> _sessions = {};
  final Set<WebSocketChannel> _webSocketClients = {};
  
  Future<void> start(int port) async {
    final router = Router()
      ..get('/', _handleIndex)
      ..get('/api/sessions', _handleGetSessions)
      ..post('/api/sessions', _handleCreateSession)
      ..get('/api/sessions/<sessionId>', _handleGetSession)
      ..post('/api/sessions/<sessionId>/diagnostics', _handlePostDiagnostics)
      ..get('/api/sessions/<sessionId>/stream', 
          webSocketHandler(_handleWebSocket))
      ..post('/api/sessions/<sessionId>/record/start', _handleStartRecording)
      ..post('/api/sessions/<sessionId>/record/stop', _handleStopRecording)
      ..get('/api/sessions/<sessionId>/export', _handleExportSession)
      ..post('/api/logs/batch', _handleLogsBatch)
      ..get('/api/status', _handleStatus);

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware)
        .addHandler(router.call);

    await serve(handler, 'localhost', port);
    
    print('🚀 Plough Debug Server running at http://localhost:$port');
    print('📊 Web Console: http://localhost:$port');
    print('🔍 API Status: http://localhost:$port/api/status');
    print('');
    print('Press Ctrl+C to stop the server');
  }

  Middleware get _corsMiddleware => (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    };
  };

  Response _handleIndex(Request request) {
    final html = _generateDebugConsoleHtml();
    return Response.ok(html, headers: {'Content-Type': 'text/html'});
  }

  Response _handleGetSessions(Request request) {
    final sessions = _sessions.entries.map((entry) {
      final session = entry.value;
      return {
        'session_id': entry.key,
        'created_at': session.createdAt.toIso8601String(),
        'buffer_summary': session.getBufferSummary(),
        'client_count': session.webSocketClients.length,
        'recording': session.isRecording,
      };
    }).toList();

    return Response.ok(
      jsonEncode({'sessions': sessions}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleCreateSession(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final sessionId = data['session_id'] as String? ?? 
        'session_${DateTime.now().millisecondsSinceEpoch}';

    if (!_sessions.containsKey(sessionId)) {
      _sessions[sessionId] = DebugSession(sessionId);
      print('📱 Created new session: $sessionId');
    }

    return Response.ok(
      jsonEncode({
        'session_id': sessionId,
        'created': true,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleGetSession(Request request) {
    final sessionId = request.params['sessionId']!;
    
    // Auto-create session if it doesn't exist
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    if (_sessions[sessionId] == session) {
      print('🔧 Auto-created session: $sessionId');
    }

    return Response.ok(
      jsonEncode({
        'session_id': sessionId,
        'created_at': session.createdAt.toIso8601String(),
        'buffer_summary': session.getBufferSummary(),
        'recent_gestures': session.getRecentGestures(20),
        'recent_renders': session.getRecentRenders(20),
        'recent_state_changes': session.getRecentStateChanges(20),
        'performance_metrics': session.getPerformanceMetrics(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handlePostDiagnostics(Request request) async {
    final sessionId = request.params['sessionId']!;
    
    // Auto-create session if it doesn't exist
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    if (_sessions[sessionId] == session) {
      print('🔧 Auto-created session: $sessionId');
    }

    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final dataType = data['type'] as String?;
    final eventData = data['data'] as Map<String, dynamic>? ?? {};

    // Add timestamp if not present
    eventData['timestamp'] ??= DateTime.now().toIso8601String();

    switch (dataType) {
      case 'gesture_event':
        session.addGestureEvent(eventData);
        _broadcastToWebSockets({
          'type': 'gesture_event',
          'session_id': sessionId,
          'data': eventData,
        });
      case 'render_event':
        session.addRenderEvent(eventData);
        _broadcastToWebSockets({
          'type': 'render_event',
          'session_id': sessionId,
          'data': eventData,
        });
      case 'state_change':
        session.addStateChange(eventData);
        _broadcastToWebSockets({
          'type': 'state_change',
          'session_id': sessionId,
          'data': eventData,
        });
      case 'performance_sample':
        session.addPerformanceSample(eventData);
      case 'snapshot':
        session.addSnapshot(eventData);
        _broadcastToWebSockets({
          'type': 'snapshot',
          'session_id': sessionId,
          'data': eventData,
        });
    }

    return Response.ok(
      jsonEncode({'success': true}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void _handleWebSocket(WebSocketChannel webSocket) {
    _webSocketClients.add(webSocket);
    print('🔌 WebSocket client connected (${_webSocketClients.length} total)');

    // Send connection established message
    webSocket.sink.add(jsonEncode({
      'type': 'connection_established',
      'timestamp': DateTime.now().toIso8601String(),
      'sessions': _sessions.keys.toList(),
    }));

    webSocket.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          print('📨 WebSocket message: ${data['type']}');
        } on Exception catch (e) {
          print('❌ Invalid WebSocket message: $e');
        }
      },
      onDone: () {
        _webSocketClients.remove(webSocket);
        print('🔌 WebSocket client disconnected (${_webSocketClients.length} total)');
      },
      onError: (Object error) {
        _webSocketClients.remove(webSocket);
        print('❌ WebSocket error: $error');
      },
    );
  }

  Future<Response> _handleStartRecording(Request request) async {
    final sessionId = request.params['sessionId']!;
    
    // Auto-create session if it doesn't exist
    final session = _sessions[sessionId] ??= DebugSession(sessionId);

    session.startRecording();
    _broadcastToWebSockets({
      'type': 'recording_started',
      'session_id': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return Response.ok(
      jsonEncode({'recording': true}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleStopRecording(Request request) async {
    final sessionId = request.params['sessionId']!;
    
    // Auto-create session if it doesn't exist
    final session = _sessions[sessionId] ??= DebugSession(sessionId);

    final eventCount = session.stopRecording();
    _broadcastToWebSockets({
      'type': 'recording_stopped',
      'session_id': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'event_count': eventCount,
    });

    return Response.ok(
      jsonEncode({
        'recording': false,
        'event_count': eventCount,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleExportSession(Request request) {
    final sessionId = request.params['sessionId']!;
    
    // Auto-create session if it doesn't exist
    final session = _sessions[sessionId] ??= DebugSession(sessionId);

    final exportData = {
      'session_id': sessionId,
      'created_at': session.createdAt.toIso8601String(),
      'exported_at': DateTime.now().toIso8601String(),
      'gesture_events': session.gestureEvents,
      'render_events': session.renderEvents,
      'state_changes': session.stateChanges,
      'performance_samples': session.performanceSamples,
      'snapshots': session.snapshots,
      'recording_data': session.recordingData,
    };

    return Response.ok(
      jsonEncode(exportData),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Legacy endpoint for existing client
  Future<Response> _handleLogsBatch(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final logs = data['logs'] as List<dynamic>? ?? [];

    // Create default session if none exists
    const sessionId = 'flutter_legacy';
    _sessions[sessionId] ??= DebugSession(sessionId);
    final session = _sessions[sessionId]!;

    // Convert logs to events
    for (final log in logs) {
      final logData = log as Map<String, dynamic>;
      session.addGestureEvent(logData);
      
      _broadcastToWebSockets({
        'type': 'log_event',
        'session_id': sessionId,
        'data': logData,
      });
    }

    return Response.ok(
      jsonEncode({'success': true, 'processed': logs.length}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleStatus(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'running',
        'server': 'Plough Debug Server (Dart)',
        'version': '1.0.0',
        'sessions': _sessions.length,
        'websocket_clients': _webSocketClients.length,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void _broadcastToWebSockets(Map<String, dynamic> message) {
    final messageStr = jsonEncode(message);
    final clientsToRemove = <WebSocketChannel>[];

    for (final client in _webSocketClients) {
      try {
        client.sink.add(messageStr);
      } on Exception {
        clientsToRemove.add(client);
      }
    }

    // Remove disconnected clients
    for (final client in clientsToRemove) {
      _webSocketClients.remove(client);
    }
  }

  String _generateDebugConsoleHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>Plough Debug Console (Dart)</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #1a1a1a; 
            color: #e0e0e0;
            height: 100vh;
            overflow: hidden;
        }
        .header {
            background: #2a2a2a;
            padding: 15px 20px;
            border-bottom: 1px solid #444;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .header h1 {
            color: #4CAF50;
            font-size: 24px;
        }
        .status {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .status-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #666;
            animation: pulse 2s infinite;
        }
        .status-dot.connected {
            background: #4CAF50;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        .main {
            display: flex;
            height: calc(100vh - 70px);
        }
        .sidebar {
            width: 300px;
            background: #2a2a2a;
            border-right: 1px solid #444;
            overflow-y: auto;
            padding: 20px;
        }
        .content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .tabs {
            display: flex;
            background: #2a2a2a;
            border-bottom: 1px solid #444;
        }
        .tab {
            padding: 12px 20px;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
        }
        .tab:hover {
            background: #333;
        }
        .tab.active {
            border-bottom-color: #4CAF50;
            color: #4CAF50;
        }
        .tab-content {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
        }
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        .metric-card {
            background: #2a2a2a;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #444;
        }
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #4CAF50;
        }
        .metric-label {
            color: #999;
            font-size: 0.9em;
            margin-top: 5px;
        }
        .event-log {
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 8px;
            padding: 15px;
            font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
            font-size: 12px;
            max-height: 500px;
            overflow-y: auto;
        }
        .event-entry {
            padding: 8px 0;
            border-bottom: 1px solid #333;
            word-wrap: break-word;
        }
        .event-entry:last-child {
            border-bottom: none;
        }
        .timestamp {
            color: #666;
        }
        .event-type {
            color: #4CAF50;
            font-weight: bold;
        }
        .session-item {
            padding: 12px;
            margin-bottom: 10px;
            background: #333;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .session-item:hover {
            background: #404040;
        }
        .session-item.active {
            background: #4CAF50;
            color: white;
        }
        button {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }
        button:hover {
            background: #45a049;
        }
        button:disabled {
            background: #666;
            cursor: not-allowed;
        }
        .controls {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .filter-controls {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }
        select, input {
            background: #333;
            color: #e0e0e0;
            border: 1px solid #555;
            padding: 8px 12px;
            border-radius: 4px;
        }
        .recording-indicator {
            color: #f44336;
            animation: blink 1s infinite;
        }
        @keyframes blink {
            0% { opacity: 1; }
            50% { opacity: 0.3; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Plough Debug Console</h1>
        <div class="status">
            <div class="status-dot" id="statusDot"></div>
            <span id="statusText">Connecting...</span>
        </div>
    </div>
    
    <div class="main">
        <div class="sidebar">
            <h3>Sessions</h3>
            <div class="controls">
                <button onclick="createSession()">New Session</button>
                <button onclick="refreshSessions()">Refresh</button>
            </div>
            <div id="sessionList"></div>
        </div>
        
        <div class="content">
            <div class="tabs">
                <div class="tab active" onclick="switchTab('overview')">Overview</div>
                <div class="tab" onclick="switchTab('events')">Events</div>
                <div class="tab" onclick="switchTab('performance')">Performance</div>
                <div class="tab" onclick="switchTab('recording')">Recording</div>
            </div>
            
            <div class="tab-content" id="overview">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value" id="sessionsCount">0</div>
                        <div class="metric-label">Active Sessions</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value" id="eventsCount">0</div>
                        <div class="metric-label">Total Events</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value" id="clientsCount">0</div>
                        <div class="metric-label">Connected Clients</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value" id="uptimeValue">0s</div>
                        <div class="metric-label">Server Uptime</div>
                    </div>
                </div>
                
                <h3>Recent Activity</h3>
                <div class="event-log" id="recentActivity"></div>
            </div>
            
            <div class="tab-content" id="events" style="display: none;">
                <div class="filter-controls">
                    <select id="eventTypeFilter">
                        <option value="">All Events</option>
                        <option value="gesture_event">Gesture Events</option>
                        <option value="render_event">Render Events</option>
                        <option value="state_change">State Changes</option>
                        <option value="performance_sample">Performance</option>
                    </select>
                    <input type="text" id="eventSearch" placeholder="Search events...">
                    <button onclick="clearEvents()">Clear</button>
                </div>
                <div class="event-log" id="eventLog"></div>
            </div>
            
            <div class="tab-content" id="performance" style="display: none;">
                <h3>Performance Metrics</h3>
                <div class="event-log" id="performanceLog"></div>
            </div>
            
            <div class="tab-content" id="recording" style="display: none;">
                <div class="controls">
                    <button id="recordBtn" onclick="toggleRecording()">Start Recording</button>
                    <button onclick="exportData()">Export Data</button>
                </div>
                <div id="recordingStatus"></div>
                <div class="event-log" id="recordingLog"></div>
            </div>
        </div>
    </div>
    
    <script>
        let ws = null;
        let currentSession = null;
        let recording = false;
        let startTime = Date.now();
        let events = [];
        
        // Initialize
        connectWebSocket();
        loadSessions();
        
        function connectWebSocket() {
            try {
                ws = new WebSocket('ws://localhost:8081/api/sessions/default/stream');
                
                ws.onopen = () => {
                    document.getElementById('statusDot').classList.add('connected');
                    document.getElementById('statusText').textContent = 'Connected';
                    console.log('WebSocket connected');
                };
                
                ws.onclose = () => {
                    document.getElementById('statusDot').classList.remove('connected');
                    document.getElementById('statusText').textContent = 'Disconnected';
                    console.log('WebSocket disconnected');
                    
                    // Reconnect after 3 seconds
                    setTimeout(connectWebSocket, 3000);
                };
                
                ws.onmessage = (event) => {
                    try {
                        const data = JSON.parse(event.data);
                        handleWebSocketMessage(data);
                    } catch (e) {
                        console.error('Error parsing WebSocket message:', e);
                    }
                };
                
                ws.onerror = (error) => {
                    console.error('WebSocket error:', error);
                };
            } catch (e) {
                console.error('Failed to connect WebSocket:', e);
                document.getElementById('statusText').textContent = 'Connection Failed';
            }
        }
        
        function handleWebSocketMessage(data) {
            console.log('WebSocket message:', data);
            
            if (data.type === 'connection_established') {
                updateMetrics();
                return;
            }
            
            // Add to events list
            events.unshift(data);
            if (events.length > 1000) events.pop();
            
            // Update displays
            addEventToLog('recentActivity', data);
            addEventToLog('eventLog', data);
            
            if (data.type === 'performance_sample') {
                addEventToLog('performanceLog', data);
            }
            
            updateMetrics();
        }
        
        function addEventToLog(logId, event) {
            const log = document.getElementById(logId);
            if (!log) return;
            
            const entry = document.createElement('div');
            entry.className = 'event-entry';
            
            const timestamp = new Date(event.timestamp || Date.now()).toLocaleTimeString();
            const type = event.type || 'unknown';
            
            entry.innerHTML = `
                <span class="timestamp">[` + timestamp + `]</span>
                <span class="event-type">` + type.toUpperCase() + `</span>
                ` + JSON.stringify(event.data || event, null, 2) + `
            `;
            
            log.insertBefore(entry, log.firstChild);
            
            // Keep only last 100 entries
            while (log.children.length > 100) {
                log.removeChild(log.lastChild);
            }
        }
        
        function updateMetrics() {
            document.getElementById('eventsCount').textContent = events.length;
            
            const uptime = Math.floor((Date.now() - startTime) / 1000);
            document.getElementById('uptimeValue').textContent = uptime + 's';
            
            // Update from server status
            fetch('/api/status')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('sessionsCount').textContent = data.sessions || 0;
                    document.getElementById('clientsCount').textContent = data.websocket_clients || 0;
                })
                .catch(e => console.error('Failed to fetch status:', e));
        }
        
        function loadSessions() {
            fetch('/api/sessions')
                .then(res => res.json())
                .then(data => {
                    const list = document.getElementById('sessionList');
                    list.innerHTML = data.sessions.map(session => `
                        <div class="session-item ` + (currentSession === session.session_id ? 'active' : '') + `" 
                             onclick="selectSession('` + session.session_id + `')">
                            <div><strong>` + session.session_id + `</strong></div>
                            <div style="font-size: 0.8em; color: #999;">
                                Events: ` + (session.buffer_summary?.gesture_events || 0) + `
                            </div>
                            <div style="font-size: 0.8em; color: #999;">
                                ` + new Date(session.created_at).toLocaleString() + `
                            </div>
                        </div>
                    `).join('');
                })
                .catch(e => console.error('Failed to load sessions:', e));
        }
        
        function createSession() {
            const sessionId = 'session_' + Date.now();
            fetch('/api/sessions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ session_id: sessionId })
            })
            .then(() => {
                loadSessions();
                selectSession(sessionId);
            })
            .catch(e => console.error('Failed to create session:', e));
        }
        
        function refreshSessions() {
            loadSessions();
        }
        
        function selectSession(sessionId) {
            currentSession = sessionId;
            loadSessions();
            console.log('Selected session:', sessionId);
        }
        
        function switchTab(tabName) {
            // Remove active class from all tabs
            document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.style.display = 'none');
            
            // Add active class to clicked tab
            event.target.classList.add('active');
            document.getElementById(tabName).style.display = 'block';
        }
        
        function toggleRecording() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            recording = !recording;
            const endpoint = recording ? 'start' : 'stop';
            
            fetch(`/api/sessions/` + currentSession + `/record/` + endpoint, { method: 'POST' })
                .then(() => {
                    const btn = document.getElementById('recordBtn');
                    btn.textContent = recording ? 'Stop Recording' : 'Start Recording';
                    btn.classList.toggle('recording-indicator', recording);
                    
                    document.getElementById('recordingStatus').textContent = 
                        recording ? '🔴 Recording in progress...' : '⏹️ Recording stopped';
                })
                .catch(e => console.error('Failed to toggle recording:', e));
        }
        
        function exportData() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            fetch(`/api/sessions/` + currentSession + `/export`)
                .then(res => res.json())
                .then(data => {
                    const blob = new Blob([JSON.stringify(data, null, 2)], 
                        { type: 'application/json' });
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = `plough-debug-` + currentSession + `-` + Date.now() + `.json`;
                    a.click();
                    URL.revokeObjectURL(url);
                })
                .catch(e => console.error('Failed to export data:', e));
        }
        
        function clearEvents() {
            events = [];
            document.getElementById('eventLog').innerHTML = '';
            document.getElementById('recentActivity').innerHTML = '';
        }
        
        // Auto-refresh every 5 seconds
        setInterval(updateMetrics, 5000);
        setInterval(loadSessions, 10000);
    </script>
</body>
</html>
''';
  }
}

class DebugSession {
  DebugSession(this.sessionId) : createdAt = DateTime.now();

  final String sessionId;
  final DateTime createdAt;
  final List<Map<String, dynamic>> gestureEvents = [];
  final List<Map<String, dynamic>> renderEvents = [];
  final List<Map<String, dynamic>> stateChanges = [];
  final List<Map<String, dynamic>> performanceSamples = [];
  final List<Map<String, dynamic>> snapshots = [];
  final List<Map<String, dynamic>> recordingData = [];
  final Set<WebSocketChannel> webSocketClients = {};
  
  bool isRecording = false;
  
  static const int maxBufferSize = 1000;

  void addGestureEvent(Map<String, dynamic> event) {
    gestureEvents.insert(0, event);
    if (gestureEvents.length > maxBufferSize) {
      gestureEvents.removeLast();
    }
    if (isRecording) recordingData.add({'type': 'gesture', 'data': event});
  }

  void addRenderEvent(Map<String, dynamic> event) {
    renderEvents.insert(0, event);
    if (renderEvents.length > maxBufferSize) {
      renderEvents.removeLast();
    }
    if (isRecording) recordingData.add({'type': 'render', 'data': event});
  }

  void addStateChange(Map<String, dynamic> event) {
    stateChanges.insert(0, event);
    if (stateChanges.length > maxBufferSize) {
      stateChanges.removeLast();
    }
    if (isRecording) recordingData.add({'type': 'state', 'data': event});
  }

  void addPerformanceSample(Map<String, dynamic> event) {
    performanceSamples.insert(0, event);
    if (performanceSamples.length > maxBufferSize) {
      performanceSamples.removeLast();
    }
    if (isRecording) recordingData.add({'type': 'performance', 'data': event});
  }

  void addSnapshot(Map<String, dynamic> event) {
    snapshots.insert(0, event);
    if (snapshots.length > 100) { // Keep fewer snapshots
      snapshots.removeLast();
    }
    if (isRecording) recordingData.add({'type': 'snapshot', 'data': event});
  }

  Map<String, dynamic> getBufferSummary() {
    return {
      'gesture_events': gestureEvents.length,
      'render_events': renderEvents.length,
      'state_changes': stateChanges.length,
      'performance_samples': performanceSamples.length,
      'snapshots': snapshots.length,
      'latest_snapshot': snapshots.isNotEmpty ? snapshots.first : null,
    };
  }

  List<Map<String, dynamic>> getRecentGestures(int count) {
    return gestureEvents.take(count).toList();
  }

  List<Map<String, dynamic>> getRecentRenders(int count) {
    return renderEvents.take(count).toList();
  }

  List<Map<String, dynamic>> getRecentStateChanges(int count) {
    return stateChanges.take(count).toList();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    if (performanceSamples.isEmpty) {
      return {
        'average_fps': 0,
        'dropped_frames': 0,
        'average_frame_time_ms': 0,
        'sample_count': 0,
      };
    }

    final fpsValues = performanceSamples
        .map((s) => s['fps'] as double? ?? 0.0)
        .where((fps) => fps > 0)
        .toList();

    final averageFps = fpsValues.isNotEmpty 
        ? fpsValues.reduce((a, b) => a + b) / fpsValues.length 
        : 0.0;

    final droppedFrames = performanceSamples
        .map((s) => s['dropped_frames'] as int? ?? 0)
        .reduce((a, b) => a + b);

    final frameTimes = performanceSamples
        .map((s) => s['frame_time_ms'] as double? ?? 0.0)
        .where((time) => time > 0)
        .toList();

    final averageFrameTime = frameTimes.isNotEmpty
        ? frameTimes.reduce((a, b) => a + b) / frameTimes.length
        : 0.0;

    return {
      'average_fps': double.parse(averageFps.toStringAsFixed(2)),
      'dropped_frames': droppedFrames,
      'average_frame_time_ms': double.parse(averageFrameTime.toStringAsFixed(2)),
      'sample_count': performanceSamples.length,
    };
  }

  void startRecording() {
    isRecording = true;
    recordingData.clear();
  }

  int stopRecording() {
    isRecording = false;
    return recordingData.length;
  }
}
