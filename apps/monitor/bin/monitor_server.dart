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
    print('Plough Monitor Server');
    print('Usage: dart bin/monitor_server.dart [options]');
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
      ..get('/api/sessions/<sessionId>/debug/drag-not-working', _handleDragNotWorkingDebug)
      ..get('/api/sessions/<sessionId>/debug/tap-not-working', _handleTapNotWorkingDebug)
      ..get('/api/sessions/<sessionId>/debug/rendering-issues', _handleRenderingIssuesDebug)
      ..get('/api/sessions/<sessionId>/debug/animation-stuck', _handleAnimationStuckDebug)
      ..get('/api/sessions/<sessionId>/debug/performance-drops', _handlePerformanceDropsDebug)
      ..post('/api/logs/batch', _handleLogsBatch)
      ..get('/api/status', _handleStatus);

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware)
        .addHandler(router.call);

    await serve(handler, 'localhost', port);
    
    print('🚀 Plough Monitor Server running at http://localhost:$port');
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
    
    // Add node_id field for backward compatibility
    if (eventData['targetNodeId'] != null) {
      eventData['node_id'] = eventData['targetNodeId'];
    }
    if (eventData['target'] != null) {
      eventData['node_id'] = eventData['target'];
    }
    
    // Set event_type field for easier filtering
    if (eventData['type'] != null) {
      eventData['event_type'] = eventData['type'];
    }

    print('📥 Received $dataType for node: ${eventData['node_id'] ?? eventData['targetNodeId'] ?? 'unknown'}');

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

  Response _handleDragNotWorkingDebug(Request request) {
    final sessionId = request.params['sessionId']!;
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    
    final nodeId = request.url.queryParameters['nodeId'];
    final analysis = session.debugDragNotWorking(nodeId);
    return Response.ok(
      jsonEncode(analysis),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleTapNotWorkingDebug(Request request) {
    final sessionId = request.params['sessionId']!;
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    
    final nodeId = request.url.queryParameters['nodeId'];
    final x = double.tryParse(request.url.queryParameters['x'] ?? '');
    final y = double.tryParse(request.url.queryParameters['y'] ?? '');
    final analysis = session.debugTapNotWorking(nodeId, x, y);
    return Response.ok(
      jsonEncode(analysis),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleRenderingIssuesDebug(Request request) {
    final sessionId = request.params['sessionId']!;
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    
    final linkId = request.url.queryParameters['linkId'];
    final analysis = session.debugRenderingIssues(linkId);
    return Response.ok(
      jsonEncode(analysis),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleAnimationStuckDebug(Request request) {
    final sessionId = request.params['sessionId']!;
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    
    final animationType = request.url.queryParameters['type'];
    final analysis = session.debugAnimationStuck(animationType);
    return Response.ok(
      jsonEncode(analysis),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handlePerformanceDropsDebug(Request request) {
    final sessionId = request.params['sessionId']!;
    final session = _sessions[sessionId] ??= DebugSession(sessionId);
    
    final timeRange = request.url.queryParameters['timeRange'];
    final analysis = session.debugPerformanceDrops(timeRange);
    return Response.ok(
      jsonEncode(analysis),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handleStatus(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'running',
        'server': 'Plough Monitor Server (Dart)',
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
    <title>Plough Monitor Console (Dart)</title>
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
        .debug-tool-group {
            margin-bottom: 15px;
            padding: 10px;
            background: #333;
            border-radius: 6px;
        }
        .debug-tool-group h5 {
            margin: 0 0 10px 0;
            color: #4CAF50;
        }
        .event-timeline {
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Plough Monitor Console</h1>
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
                <div class="tab" onclick="switchTab('analysis')">Analysis</div>
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
            
            <div class="tab-content" id="analysis" style="display: none;">
                <div class="controls">
                    <h4>Problem-Specific Debug Tools</h4>
                    <div class="debug-tool-group">
                        <h5>Gesture Issues</h5>
                        <input type="text" id="dragNodeId" placeholder="Node ID" style="width: 120px;">
                        <button onclick="debugDragNotWorking()">Debug Drag Not Working</button>
                        <br><br>
                        <input type="text" id="tapNodeId" placeholder="Node ID" style="width: 80px;">
                        <input type="number" id="tapX" placeholder="X" style="width: 60px;">
                        <input type="number" id="tapY" placeholder="Y" style="width: 60px;">
                        <button onclick="debugTapNotWorking()">Debug Tap Not Working</button>
                    </div>
                    <br>
                    <div class="debug-tool-group">
                        <h5>Rendering Issues</h5>
                        <input type="text" id="linkId" placeholder="Link ID" style="width: 120px;">
                        <button onclick="debugRenderingIssues()">Debug Link Rendering</button>
                    </div>
                    <br>
                    <div class="debug-tool-group">
                        <h5>Performance & Animation</h5>
                        <select id="animationType">
                            <option value="layout">Layout Animation</option>
                            <option value="drag">Drag Animation</option>
                            <option value="transition">Transition Animation</option>
                        </select>
                        <button onclick="debugAnimationStuck()">Debug Animation Stuck</button>
                        <br><br>
                        <select id="timeRange">
                            <option value="last1min">Last 1 minute</option>
                            <option value="last5min">Last 5 minutes</option>
                            <option value="last10min">Last 10 minutes</option>
                        </select>
                        <button onclick="debugPerformanceDrops()">Debug Performance Drops</button>
                    </div>
                </div>
                <div id="analysisResults"></div>
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
        
        function debugDragNotWorking() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            const nodeId = document.getElementById('dragNodeId').value;
            if (!nodeId) {
                alert('Please enter a Node ID');
                return;
            }
            
            fetch('/api/sessions/' + currentSession + '/debug/drag-not-working?nodeId=' + nodeId)
                .then(res => res.json())
                .then(data => {
                    displayDebugResults('Drag Not Working Debug', data);
                })
                .catch(e => console.error('Failed to debug drag issue:', e));
        }
        
        function debugTapNotWorking() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            const nodeId = document.getElementById('tapNodeId').value;
            const x = document.getElementById('tapX').value;
            const y = document.getElementById('tapY').value;
            
            if (!nodeId || !x || !y) {
                alert('Please enter Node ID, X, and Y coordinates');
                return;
            }
            
            fetch('/api/sessions/' + currentSession + '/debug/tap-not-working?nodeId=' + nodeId + '&x=' + x + '&y=' + y)
                .then(res => res.json())
                .then(data => {
                    displayDebugResults('Tap Not Working Debug', data);
                })
                .catch(e => console.error('Failed to debug tap issue:', e));
        }
        
        function debugRenderingIssues() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            const linkId = document.getElementById('linkId').value;
            if (!linkId) {
                alert('Please enter a Link ID');
                return;
            }
            
            fetch('/api/sessions/' + currentSession + '/debug/rendering-issues?linkId=' + linkId)
                .then(res => res.json())
                .then(data => {
                    displayDebugResults('Rendering Issues Debug', data);
                })
                .catch(e => console.error('Failed to debug rendering issue:', e));
        }
        
        function debugAnimationStuck() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            const animationType = document.getElementById('animationType').value;
            
            fetch('/api/sessions/' + currentSession + '/debug/animation-stuck?type=' + animationType)
                .then(res => res.json())
                .then(data => {
                    displayDebugResults('Animation Stuck Debug', data);
                })
                .catch(e => console.error('Failed to debug animation issue:', e));
        }
        
        function debugPerformanceDrops() {
            if (!currentSession) {
                alert('Please select a session first');
                return;
            }
            
            const timeRange = document.getElementById('timeRange').value;
            
            fetch('/api/sessions/' + currentSession + '/debug/performance-drops?timeRange=' + timeRange)
                .then(res => res.json())
                .then(data => {
                    displayDebugResults('Performance Drops Debug', data);
                })
                .catch(e => console.error('Failed to debug performance issue:', e));
        }
        
        function displayDebugResults(title, data) {
            const results = document.getElementById('analysisResults');
            
            const section = document.createElement('div');
            section.style.marginBottom = '30px';
            section.style.padding = '20px';
            section.style.background = '#2a2a2a';
            section.style.borderRadius = '8px';
            section.style.border = '1px solid #444';
            
            let html = '<h4 style="color: #4CAF50; margin-bottom: 15px;">🔍 ' + title + '</h4>';
            
            // Debug status
            if (data.problem_detected) {
                html += '<div style="background: #d32f2f; padding: 10px; border-radius: 4px; margin-bottom: 15px;">';
                html += '<strong>❌ Problem: </strong>' + data.problem_description;
                html += '</div>';
            } else {
                html += '<div style="background: #388e3c; padding: 10px; border-radius: 4px; margin-bottom: 15px;">';
                html += '<strong>✅ Status: </strong>No issues detected';
                html += '</div>';
            }
            
            // Event trace
            if (data.event_trace && data.event_trace.length > 0) {
                html += '<h5 style="color: #fff; margin: 15px 0 10px 0;">📋 Event Trace:</h5>';
                html += '<div style="background: #333; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 12px;">';
                data.event_trace.forEach(event => {
                    const status = event.status === 'success' ? '✅' : 
                                  event.status === 'missing' ? '❌' : 
                                  event.status === 'failed' ? '⚠️' : '🔍';
                    html += '<div style="margin: 2px 0;">';
                    html += status + ' ' + event.timestamp + ' - ' + event.event_type;
                    if (event.details) html += ' (' + event.details + ')';
                    html += '</div>';
                });
                html += '</div>';
            }
            
            // Analysis details
            if (data.analysis) {
                html += '<h5 style="color: #fff; margin: 15px 0 10px 0;">🔬 Analysis:</h5>';
                html += '<div style="background: #333; padding: 10px; border-radius: 4px;">';
                Object.keys(data.analysis).forEach(key => {
                    html += '<div><strong>' + key + ':</strong> ' + data.analysis[key] + '</div>';
                });
                html += '</div>';
            }
            
            // Root cause
            if (data.root_cause) {
                html += '<h5 style="color: #ff9800; margin: 15px 0 10px 0;">🛠️ Root Cause:</h5>';
                html += '<div style="background: #e65100; padding: 10px; border-radius: 4px;">';
                html += data.root_cause;
                html += '</div>';
            }
            
            // Recommendations
            if (data.recommendations && data.recommendations.length > 0) {
                html += '<h5 style="color: #2196f3; margin: 15px 0 10px 0;">💡 Recommendations:</h5>';
                html += '<ul style="color: #90caf9;">';
                data.recommendations.forEach(rec => {
                    html += '<li style="margin: 5px 0;">' + rec + '</li>';
                });
                html += '</ul>';
            }
            
            section.innerHTML = html;
            results.appendChild(section);
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
  int _lastGeneratedEventCount = 0;
  
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

  // Problem-specific Debug Methods
  Map<String, dynamic> debugDragNotWorking(String? nodeId) {
    if (nodeId == null || nodeId.isEmpty) {
      return {
        'problem_detected': true,
        'problem_description': 'No node ID provided for drag debug analysis',
        'recommendations': ['Please specify a node ID to analyze'],
      };
    }

    // Get all events related to this node
    final nodeEvents = _getNodeEvents(nodeId);
    final eventTrace = <Map<String, dynamic>>[];
    
    // Check gesture event sequence
    final tapDownEvents = nodeEvents.where((e) => 
        e['event_type'] == 'tap_down' || e['event_type'] == 'onTapDown' ||
        e['event_type'] == 'pointerDown' || 
        (e['data'] != null && (e['data']['type'] == 'pointerDown' || e['data']['type'] == 'tap'))).toList();
    final panStartEvents = nodeEvents.where((e) => 
        e['event_type'] == 'pan_start' || e['event_type'] == 'onPanStart' ||
        e['event_type'] == 'panStart' ||
        (e['data'] != null && e['data']['type'] == 'panStart')).toList();
    final panUpdateEvents = nodeEvents.where((e) => 
        e['event_type'] == 'pan_update' || e['event_type'] == 'onPanUpdate' ||
        e['event_type'] == 'panUpdate' ||
        (e['data'] != null && e['data']['type'] == 'panUpdate')).toList();
    final panEndEvents = nodeEvents.where((e) => 
        e['event_type'] == 'pan_end' || e['event_type'] == 'onPanEnd').toList();

    // Build event trace
    if (tapDownEvents.isNotEmpty) {
      eventTrace.add({
        'timestamp': _formatTimestamp(tapDownEvents.last['timestamp'] as String?),
        'event_type': 'Tap Down',
        'status': 'success',
        'details': 'Position: ${_getPosition(tapDownEvents.last)}',
      });
    } else {
      eventTrace.add({
        'timestamp': 'N/A',
        'event_type': 'Tap Down',
        'status': 'missing',
        'details': 'No tap down event recorded',
      });
    }

    if (panStartEvents.isNotEmpty) {
      eventTrace.add({
        'timestamp': _formatTimestamp(panStartEvents.last['timestamp'] as String?),
        'event_type': 'Pan Start',
        'status': 'success',
        'details': 'Drag initiated',
      });
    } else {
      eventTrace.add({
        'timestamp': 'N/A',
        'event_type': 'Pan Start',
        'status': 'missing',
        'details': 'Drag gesture not detected',
      });
    }

    if (panUpdateEvents.isNotEmpty) {
      eventTrace.add({
        'timestamp': _formatTimestamp(panUpdateEvents.last['timestamp'] as String?),
        'event_type': 'Pan Update',
        'status': 'success',
        'details': '${panUpdateEvents.length} update events',
      });
    } else {
      eventTrace.add({
        'timestamp': 'N/A',
        'event_type': 'Pan Update',
        'status': 'missing',
        'details': 'No drag movement detected',
      });
    }

    // Analyze the problem
    String? rootCause;
    final recommendations = <String>[];
    bool problemDetected = false;

    if (tapDownEvents.isEmpty) {
      problemDetected = true;
      rootCause = 'No tap events detected on node $nodeId. The node may not have a GestureDetector or hit testing is failing.';
      recommendations.addAll([
        'Check if GraphNodeView has a GestureDetector widget',
        'Verify node boundaries are correctly calculated',
        'Ensure the node is not covered by another widget',
      ]);
    } else if (panStartEvents.isEmpty) {
      problemDetected = true;
      rootCause = 'Tap detected but drag gesture not initiated. The GestureDetector may be missing onPanStart callback.';
      recommendations.addAll([
        'Add onPanStart callback to GestureDetector',
        'Check if conflicting gesture detectors are consuming the events',
        'Verify drag behavior is enabled for this node type',
      ]);
    } else if (panUpdateEvents.isEmpty) {
      problemDetected = true;
      rootCause = 'Drag started but no movement updates. Position updates may be blocked.';
      recommendations.addAll([
        'Check onPanUpdate callback implementation',
        'Verify node position is being updated in state',
        'Check if layout algorithm is overriding position changes',
      ]);
    }

    // Check for node state issues  
    final positionChanges = stateChanges.where((e) => 
        (e['node_id'] == nodeId || e['target'] == nodeId || 
         e['targetNodeId'] == nodeId ||
         (e['data'] != null && e['data']['target'] == nodeId)) &&
        (e['property'] == 'position' || e['type'] == 'nodePosition' ||
         (e['data'] != null && e['data']['type'] == 'nodePosition'))).toList();
    
    final analysis = {
      'node_events_found': nodeEvents.length,
      'last_position_update': positionChanges.isNotEmpty 
          ? _formatTimestamp(positionChanges.last['timestamp'] as String?) 
          : 'Never',
      'gesture_detector_active': tapDownEvents.isNotEmpty,
      'drag_callbacks_working': panStartEvents.isNotEmpty,
    };

    return {
      'problem_detected': problemDetected,
      'problem_description': problemDetected 
          ? 'Node $nodeId is not responding to drag gestures'
          : 'Node $nodeId drag functionality appears normal',
      'event_trace': eventTrace,
      'analysis': analysis,
      'root_cause': rootCause,
      'recommendations': recommendations,
    };
  }

  Map<String, dynamic> debugTapNotWorking(String? nodeId, double? x, double? y) {
    return {'message': 'Tap debug analysis for node: $nodeId at ($x, $y)'};
  }

  Map<String, dynamic> debugRenderingIssues(String? linkId) {
    return {'message': 'Rendering debug analysis for link: $linkId'};
  }

  Map<String, dynamic> debugAnimationStuck(String? animationType) {
    return {'message': 'Animation debug analysis for type: $animationType'};
  }

  Map<String, dynamic> debugPerformanceDrops(String? timeRange) {
    return {'message': 'Performance debug analysis for range: $timeRange'};
  }

  // Helper methods for debug analysis
  List<Map<String, dynamic>> _getNodeEvents(String nodeId) {
    return [...gestureEvents, ...renderEvents, ...stateChanges]
        .where((e) => 
          // Check multiple possible node ID fields
          e['node_id'] == nodeId || 
          e['target_node_id'] == nodeId ||
          e['targetNodeId'] == nodeId || // Enhanced client format
          e['target'] == nodeId || // State change format
          (e['data'] != null && (
            e['data']['node_id'] == nodeId ||
            e['data']['targetNodeId'] == nodeId ||
            e['data']['target'] == nodeId ||
            (e['data']['selectedNodeId'] == nodeId) ||
            (e['data']['draggedNodeIds'] != null && 
             (e['data']['draggedNodeIds'] as List).contains(nodeId))
          ))
        )
        .toList();
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:'
             '${dt.minute.toString().padLeft(2, '0')}:'
             '${dt.second.toString().padLeft(2, '0')}.'
             '${(dt.millisecond ~/ 10).toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _getPosition(Map<String, dynamic> event) {
    final pos = event['position'] as Map<String, dynamic>?;
    if (pos != null) {
      return '(${pos['x']?.toStringAsFixed(0) ?? '?'}, ${pos['y']?.toStringAsFixed(0) ?? '?'})';
    }
    final x = event['x'] as double?;
    final y = event['y'] as double?;
    if (x != null && y != null) {
      return '(${x.toStringAsFixed(0)}, ${y.toStringAsFixed(0)})';
    }
    return 'Unknown';
  }

  // Sample Data Generation
  void generateSampleData(String scenario) {
    final now = DateTime.now();
    _lastGeneratedEventCount = 0;

    switch (scenario) {
      case 'drag_not_working':
        _generateDragNotWorkingData(now);
        break;
      case 'tap_not_responding':
        _generateTapNotRespondingData(now);
        break;
      default:
        _generateDragNotWorkingData(now);
    }
  }

  void _generateDragNotWorkingData(DateTime baseTime) {
    const nodeId = 'node_test_123';
    
    // 1. ノードがレンダリングされる
    _addTimestampedEvent(renderEvents, {
      'event_type': 'node_render',
      'node_id': nodeId,
      'component': 'GraphNodeView',
      'data': {
        'node_id': nodeId,
        'position': {'x': 150.0, 'y': 200.0},
        'size': {'width': 80.0, 'height': 60.0},
        'bounds': {
          'left': 150.0, 'top': 200.0, 
          'right': 230.0, 'bottom': 260.0
        },
        'visible': true,
        'draggable': true,
      },
    }, baseTime);

    // 2. ユーザーがタップダウン（成功）
    _addTimestampedEvent(gestureEvents, {
      'event_type': 'onTapDown',
      'node_id': nodeId,
      'position': {'x': 165.0, 'y': 220.0},
      'was_consumed': true,
      'hit_test_result': 'success',
      'target_bounds': {
        'left': 150.0, 'top': 200.0,
        'right': 230.0, 'bottom': 260.0
      },
    }, baseTime.add(const Duration(milliseconds: 500)));

    // 3. パンスタートが呼ばれない（問題の原因）
    // このイベントは意図的に生成しない

    // 4. ユーザーがタップアップ
    _addTimestampedEvent(gestureEvents, {
      'event_type': 'onTapUp',
      'node_id': nodeId,
      'position': {'x': 165.0, 'y': 220.0},
      'was_consumed': true,
    }, baseTime.add(const Duration(milliseconds: 800)));

    _lastGeneratedEventCount = 3;
  }

  void _generateTapNotRespondingData(DateTime baseTime) {
    const nodeId = 'node_test_456';
    
    // 1. ノードがレンダリングされる
    _addTimestampedEvent(renderEvents, {
      'event_type': 'node_render',
      'node_id': nodeId,
      'data': {
        'node_id': nodeId,
        'position': {'x': 300.0, 'y': 400.0},
        'size': {'width': 100.0, 'height': 80.0},
        'bounds': {
          'left': 300.0, 'top': 400.0,
          'right': 400.0, 'bottom': 480.0
        },
        'visible': true,
      },
    }, baseTime);

    // 2. ユーザーがタップ（境界外）
    _addTimestampedEvent(gestureEvents, {
      'event_type': 'attempted_tap',
      'position': {'x': 280.0, 'y': 390.0}, // ノード境界外
      'hit_test_result': 'miss',
      'target_node_id': null,
      'intended_node_id': nodeId, // 意図されたノード
      'distance_to_node': 28.28,
    }, baseTime.add(const Duration(milliseconds: 300)));

    _lastGeneratedEventCount = 2;
  }

  void _addTimestampedEvent(List<Map<String, dynamic>> eventList, 
                           Map<String, dynamic> event, DateTime timestamp) {
    event['timestamp'] = timestamp.toIso8601String();
    eventList.insert(0, event);
    if (eventList.length > maxBufferSize) {
      eventList.removeLast();
    }
  }

  int getLastGeneratedEventCount() => _lastGeneratedEventCount;

  // Node Event History
  Map<String, dynamic> getNodeEventHistory(String nodeId) {
    final nodeEvents = _getNodeEvents(nodeId);
    
    // Sort by timestamp
    nodeEvents.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] as String? ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b['timestamp'] as String? ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    // Build timeline
    final timeline = nodeEvents.map((event) {
      String eventType = 'unknown';
      String description = 'Unknown event';
      Map<String, dynamic>? data;

      if (gestureEvents.contains(event)) {
        eventType = 'gesture';
        final gestureType = event['event_type'] ?? 
                           (event['data'] != null ? event['data']['type'] : 'unknown');
        description = '$gestureType at ${_getPosition(event)}';
        data = {
          'was_consumed': event['was_consumed'] ?? 
                         (event['data'] != null ? event['data']['wasConsumed'] : null),
          'hit_test_result': event['hit_test_result'],
          'callback_invoked': event['data'] != null ? event['data']['callbackInvoked'] : null,
          'target_node_id': event['targetNodeId'] ?? event['node_id'] ?? 
                           (event['data'] != null ? event['data']['targetNodeId'] : null),
        };
      } else if (renderEvents.contains(event)) {
        eventType = 'render';
        final renderPhase = event['event_type'] ?? 
                           (event['data'] != null ? event['data']['phase'] : 'unknown');
        description = '$renderPhase - ${event['component'] ?? 'component'}';
        data = event['data'] as Map<String, dynamic>? ?? {
          'duration': event['duration'],
          'affected_nodes': event['affected_nodes'],
          'trigger': event['trigger'],
        };
      } else if (stateChanges.contains(event)) {
        eventType = 'state';
        final changeType = event['property'] ?? event['type'] ?? 
                          (event['data'] != null ? event['data']['type'] : 'unknown');
        description = '$changeType changed';
        data = {
          'old_value': event['old_value'] ?? 
                      (event['data'] != null ? event['data']['oldValue'] : null),
          'new_value': event['new_value'] ?? 
                      (event['data'] != null ? event['data']['newValue'] : null),
          'target': event['target'] ?? event['targetNodeId'] ?? 
                   (event['data'] != null ? event['data']['target'] : null),
          'source': event['data'] != null ? event['data']['source'] : null,
        };
      }

      return {
        'timestamp': _formatTimestamp(event['timestamp'] as String?),
        'type': eventType,
        'description': description,
        'data': data,
      };
    }).toList();

    return {
      'node_id': nodeId,
      'total_events': nodeEvents.length,
      'event_types': {
        'gesture_events': nodeEvents.where((e) => gestureEvents.contains(e)).length,
        'render_events': nodeEvents.where((e) => renderEvents.contains(e)).length,
        'state_changes': nodeEvents.where((e) => stateChanges.contains(e)).length,
      },
      'timeline': timeline,
      'first_event': timeline.isNotEmpty ? timeline.first['timestamp'] : null,
      'last_event': timeline.isNotEmpty ? timeline.last['timestamp'] : null,
    };
  }

  // Legacy Analysis Methods (keeping for backward compatibility)
  Map<String, dynamic> analyzeNotifications() {
    final allEvents = [...gestureEvents, ...renderEvents, ...stateChanges];
    
    if (allEvents.isEmpty) {
      return {
        'total_events': 0,
        'excessive_notifications': 0,
        'duplicate_notifications': 0,
        'notification_frequency': 0.0,
        'issues': [],
      };
    }

    // Sort events by timestamp
    allEvents.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] as String? ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b['timestamp'] as String? ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    final issues = <String>[];
    int excessiveCount = 0;
    int duplicateCount = 0;
    
    // Check for excessive notifications (>10 events per second)
    if (allEvents.length > 1) {
      final firstTime = DateTime.tryParse(allEvents.first['timestamp'] as String? ?? '') ?? DateTime.now();
      final lastTime = DateTime.tryParse(allEvents.last['timestamp'] as String? ?? '') ?? DateTime.now();
      final duration = lastTime.difference(firstTime).inMilliseconds / 1000.0;
      final frequency = duration > 0 ? allEvents.length / duration : 0.0;
      
      if (frequency > 10) {
        issues.add('High notification frequency detected: ${frequency.toStringAsFixed(2)} events/sec');
        excessiveCount = (frequency * duration - 10 * duration).round().clamp(0, allEvents.length);
      }
    }

    // Check for duplicate events
    final seen = <String>{};
    for (final event in allEvents) {
      final key = '${event['type']}_${event['timestamp']}_${event.hashCode}';
      if (seen.contains(key)) {
        duplicateCount++;
      }
      seen.add(key);
    }

    if (duplicateCount > 0) {
      issues.add('$duplicateCount duplicate events detected');
    }

    // Check for rapid consecutive events of same type
    for (int i = 1; i < allEvents.length; i++) {
      final prev = allEvents[i - 1];
      final curr = allEvents[i];
      
      if (prev['type'] == curr['type']) {
        final prevTime = DateTime.tryParse(prev['timestamp'] as String? ?? '') ?? DateTime.now();
        final currTime = DateTime.tryParse(curr['timestamp'] as String? ?? '') ?? DateTime.now();
        
        if (currTime.difference(prevTime).inMilliseconds < 10) {
          issues.add('Rapid consecutive ${prev['type']} events detected (<10ms apart)');
        }
      }
    }

    final duration = allEvents.length > 1 
        ? DateTime.tryParse(allEvents.last['timestamp'] as String? ?? '')!
            .difference(DateTime.tryParse(allEvents.first['timestamp'] as String? ?? '')!)
            .inMilliseconds / 1000.0
        : 1.0;

    return {
      'total_events': allEvents.length,
      'excessive_notifications': excessiveCount,
      'duplicate_notifications': duplicateCount,
      'notification_frequency': duration > 0 ? allEvents.length / duration : 0.0,
      'issues': issues,
      'recommendations': _getNotificationRecommendations(issues),
    };
  }

  Map<String, dynamic> analyzeGestures() {
    if (gestureEvents.isEmpty) {
      return {
        'total_gestures': 0,
        'consumed_gestures': 0,
        'failed_gestures': 0,
        'success_rate': 0.0,
        'issues': [],
      };
    }

    final issues = <String>[];
    int consumedCount = 0;
    int failedCount = 0;
    final gestureTypes = <String, int>{};
    final responseTimeStats = <double>[];

    for (final event in gestureEvents) {
      final eventType = event['event_type'] as String? ?? 'unknown';
      final wasConsumed = event['was_consumed'] as bool? ?? false;
      final responseTime = event['response_time_ms'] as double?;
      
      gestureTypes[eventType] = (gestureTypes[eventType] ?? 0) + 1;
      
      if (wasConsumed) {
        consumedCount++;
      } else {
        failedCount++;
        issues.add('Gesture $eventType was not consumed at ${event['timestamp']}');
      }
      
      if (responseTime != null) {
        responseTimeStats.add(responseTime);
        if (responseTime > 100) {
          issues.add('Slow gesture response: ${responseTime}ms for $eventType');
        }
      }
    }

    final successRate = gestureEvents.length > 0 
        ? (consumedCount / gestureEvents.length) * 100 
        : 0.0;

    // Check for gesture conflicts
    final tapCount = gestureTypes['tap'] ?? 0;
    final dragCount = gestureTypes['drag'] ?? 0;
    if (tapCount > 0 && dragCount > 0) {
      final ratio = tapCount / (tapCount + dragCount);
      if (ratio < 0.1 || ratio > 0.9) {
        issues.add('Potential gesture conflict: unusual tap/drag ratio');
      }
    }

    return {
      'total_gestures': gestureEvents.length,
      'consumed_gestures': consumedCount,
      'failed_gestures': failedCount,
      'success_rate': successRate,
      'gesture_types': gestureTypes,
      'average_response_time': responseTimeStats.isNotEmpty 
          ? responseTimeStats.reduce((a, b) => a + b) / responseTimeStats.length 
          : 0.0,
      'issues': issues,
      'recommendations': _getGestureRecommendations(issues, successRate),
    };
  }

  Map<String, dynamic> analyzeRebuilds() {
    final rebuildEvents = renderEvents.where((e) => e['event_type'] == 'rebuild').toList();
    
    if (rebuildEvents.isEmpty) {
      return {
        'total_rebuilds': 0,
        'excessive_rebuilds': 0,
        'rebuild_frequency': 0.0,
        'issues': [],
      };
    }

    final issues = <String>[];
    final componentRebuilds = <String, int>{};
    int excessiveCount = 0;

    // Analyze rebuild patterns
    for (final event in rebuildEvents) {
      final component = event['component'] as String? ?? 'unknown';
      componentRebuilds[component] = (componentRebuilds[component] ?? 0) + 1;
    }

    // Check for excessive rebuilds per component
    componentRebuilds.forEach((component, count) {
      if (count > 10) {
        issues.add('Component $component rebuilt $count times (potentially excessive)');
        excessiveCount += count - 10;
      }
    });

    // Check rebuild frequency
    if (rebuildEvents.length > 1) {
      final firstTime = DateTime.tryParse(rebuildEvents.first['timestamp'] as String? ?? '') ?? DateTime.now();
      final lastTime = DateTime.tryParse(rebuildEvents.last['timestamp'] as String? ?? '') ?? DateTime.now();
      final duration = lastTime.difference(firstTime).inMilliseconds / 1000.0;
      final frequency = duration > 0 ? rebuildEvents.length / duration : 0.0;
      
      if (frequency > 5) {
        issues.add('High rebuild frequency: ${frequency.toStringAsFixed(2)} rebuilds/sec');
      }
    }

    // Check for unnecessary rebuilds (rebuilds without state changes)
    final stateChangeTimestamps = stateChanges.map((e) => e['timestamp']).toSet();
    final unnecessaryRebuilds = rebuildEvents.where((rebuild) {
      final rebuildTime = rebuild['timestamp'];
      return !stateChangeTimestamps.contains(rebuildTime);
    }).length;

    if (unnecessaryRebuilds > 0) {
      issues.add('$unnecessaryRebuilds potentially unnecessary rebuilds detected');
    }

    final duration = rebuildEvents.length > 1 
        ? DateTime.tryParse(rebuildEvents.last['timestamp'] as String? ?? '')!
            .difference(DateTime.tryParse(rebuildEvents.first['timestamp'] as String? ?? '')!)
            .inMilliseconds / 1000.0
        : 1.0;

    return {
      'total_rebuilds': rebuildEvents.length,
      'excessive_rebuilds': excessiveCount,
      'unnecessary_rebuilds': unnecessaryRebuilds,
      'rebuild_frequency': duration > 0 ? rebuildEvents.length / duration : 0.0,
      'component_rebuilds': componentRebuilds,
      'issues': issues,
      'recommendations': _getRebuildRecommendations(issues),
    };
  }

  Map<String, dynamic> analyzeLinks() {
    final linkEvents = renderEvents.where((e) => 
        e['event_type'] == 'link_render' || e['component'] == 'link').toList();
    
    if (linkEvents.isEmpty) {
      return {
        'total_links': 0,
        'properly_connected': 0,
        'connection_issues': 0,
        'issues': [],
      };
    }

    final issues = <String>[];
    int properlyConnected = 0;
    int connectionIssues = 0;

    for (final event in linkEvents) {
      final linkData = event['link_data'] as Map<String, dynamic>? ?? {};
      final sourceConnected = linkData['source_connected'] as bool? ?? false;
      final targetConnected = linkData['target_connected'] as bool? ?? false;
      final linkId = linkData['link_id'] as String? ?? 'unknown';
      
      if (sourceConnected && targetConnected) {
        properlyConnected++;
      } else {
        connectionIssues++;
        if (!sourceConnected) {
          issues.add('Link $linkId: source not properly connected to node boundary');
        }
        if (!targetConnected) {
          issues.add('Link $linkId: target not properly connected to node boundary');
        }
      }

      // Check for overlapping links
      final position = linkData['position'] as Map<String, dynamic>?;
      if (position != null) {
        final x = position['x'] as double? ?? 0.0;
        final y = position['y'] as double? ?? 0.0;
        
        // Simple overlap detection (could be improved)
        final overlapping = linkEvents.where((other) {
          if (other == event) return false;
          final otherData = other['link_data'] as Map<String, dynamic>? ?? {};
          final otherPos = otherData['position'] as Map<String, dynamic>?;
          if (otherPos == null) return false;
          
          final otherX = otherPos['x'] as double? ?? 0.0;
          final otherY = otherPos['y'] as double? ?? 0.0;
          
          return (x - otherX).abs() < 5 && (y - otherY).abs() < 5;
        }).length;
        
        if (overlapping > 0) {
          issues.add('Link $linkId: potentially overlapping with other links');
        }
      }
    }

    return {
      'total_links': linkEvents.length,
      'properly_connected': properlyConnected,
      'connection_issues': connectionIssues,
      'connection_rate': linkEvents.length > 0 
          ? (properlyConnected / linkEvents.length) * 100 
          : 0.0,
      'issues': issues,
      'recommendations': _getLinkRecommendations(issues),
    };
  }

  Map<String, dynamic> analyzeAnimations() {
    final animationEvents = renderEvents.where((e) => 
        e['event_type'] == 'animation' || e['has_animation'] == true).toList();
    
    if (animationEvents.isEmpty) {
      return {
        'total_animations': 0,
        'completed_animations': 0,
        'failed_animations': 0,
        'issues': [],
      };
    }

    final issues = <String>[];
    int completedCount = 0;
    int failedCount = 0;
    final animationDurations = <double>[];

    for (final event in animationEvents) {
      final animationData = event['animation_data'] as Map<String, dynamic>? ?? {};
      final status = animationData['status'] as String? ?? 'unknown';
      final duration = animationData['duration_ms'] as double?;
      final type = animationData['type'] as String? ?? 'unknown';
      
      if (status == 'completed') {
        completedCount++;
      } else if (status == 'failed' || status == 'cancelled') {
        failedCount++;
        issues.add('Animation $type failed with status: $status');
      }
      
      if (duration != null) {
        animationDurations.add(duration);
        
        // Check for unusually long animations
        if (duration > 1000) {
          issues.add('Long animation detected: ${duration}ms for $type');
        }
        
        // Check for too short animations (might indicate jank)
        if (duration < 16 && status == 'completed') {
          issues.add('Very short animation: ${duration}ms for $type (possible frame skip)');
        }
      }

      // Check for layout animations during drag
      if (type == 'layout' && animationData['during_drag'] == true) {
        issues.add('Layout animation triggered during drag operation');
      }
    }

    final successRate = animationEvents.length > 0 
        ? (completedCount / animationEvents.length) * 100 
        : 0.0;

    return {
      'total_animations': animationEvents.length,
      'completed_animations': completedCount,
      'failed_animations': failedCount,
      'success_rate': successRate,
      'average_duration': animationDurations.isNotEmpty 
          ? animationDurations.reduce((a, b) => a + b) / animationDurations.length 
          : 0.0,
      'issues': issues,
      'recommendations': _getAnimationRecommendations(issues, successRate),
    };
  }
  List<String> _getNotificationRecommendations(List<String> issues) {
    final recommendations = <String>[];
    
    if (issues.any((issue) => issue.contains('High notification frequency'))) {
      recommendations.add('Consider implementing notification throttling or debouncing');
      recommendations.add('Use ValueNotifier.removeListener() to avoid memory leaks');
    }
    
    if (issues.any((issue) => issue.contains('duplicate events'))) {
      recommendations.add('Implement event deduplication logic');
      recommendations.add('Check for multiple listeners on the same ValueNotifier');
    }
    
    if (issues.any((issue) => issue.contains('Rapid consecutive'))) {
      recommendations.add('Add minimum time intervals between similar events');
      recommendations.add('Consider using Timer.periodic for batch processing');
    }
    
    return recommendations;
  }

  List<String> _getGestureRecommendations(List<String> issues, double successRate) {
    final recommendations = <String>[];
    
    if (successRate < 80) {
      recommendations.add('Investigate gesture handling logic - success rate is low');
      recommendations.add('Check for proper gesture detector hierarchy');
    }
    
    if (issues.any((issue) => issue.contains('Slow gesture response'))) {
      recommendations.add('Optimize gesture handling code to reduce response time');
      recommendations.add('Consider using GestureDetector.onTapDown for immediate feedback');
    }
    
    if (issues.any((issue) => issue.contains('gesture conflict'))) {
      recommendations.add('Review gesture detector configuration');
      recommendations.add('Consider using GestureArena for complex gesture handling');
    }
    
    return recommendations;
  }

  List<String> _getRebuildRecommendations(List<String> issues) {
    final recommendations = <String>[];
    
    if (issues.any((issue) => issue.contains('rebuilt') && issue.contains('times'))) {
      recommendations.add('Use const constructors where possible');
      recommendations.add('Implement shouldRebuild logic in custom widgets');
      recommendations.add('Consider using RepaintBoundary to isolate repaints');
    }
    
    if (issues.any((issue) => issue.contains('High rebuild frequency'))) {
      recommendations.add('Implement debouncing for rapid state changes');
      recommendations.add('Use AnimatedBuilder instead of setState for animations');
    }
    
    if (issues.any((issue) => issue.contains('unnecessary rebuilds'))) {
      recommendations.add('Review state management - avoid rebuilds without state changes');
      recommendations.add('Use Selector or Consumer widgets for targeted rebuilds');
    }
    
    return recommendations;
  }

  List<String> _getLinkRecommendations(List<String> issues) {
    final recommendations = <String>[];
    
    if (issues.any((issue) => issue.contains('not properly connected'))) {
      recommendations.add('Check node boundary calculation logic');
      recommendations.add('Verify link endpoint positioning algorithms');
      recommendations.add('Consider using node center points as fallback');
    }
    
    if (issues.any((issue) => issue.contains('overlapping'))) {
      recommendations.add('Implement link routing algorithms to avoid overlaps');
      recommendations.add('Add link offset calculations for multiple connections');
      recommendations.add('Consider curved or bezier link rendering');
    }
    
    return recommendations;
  }

  List<String> _getAnimationRecommendations(List<String> issues, double successRate) {
    final recommendations = <String>[];
    
    if (successRate < 90) {
      recommendations.add('Review animation controller lifecycle management');
      recommendations.add('Check for proper animation disposal');
    }
    
    if (issues.any((issue) => issue.contains('Long animation'))) {
      recommendations.add('Consider shorter animation durations for better UX');
      recommendations.add('Use Curves.fastOutSlowIn for natural feeling animations');
    }
    
    if (issues.any((issue) => issue.contains('during drag'))) {
      recommendations.add('Disable layout animations during user interactions');
      recommendations.add('Use separate animation controllers for drag vs layout');
    }
    
    if (issues.any((issue) => issue.contains('frame skip'))) {
      recommendations.add('Check for heavy computations during animation');
      recommendations.add('Use Isolates for heavy work during animations');
    }
    
    return recommendations;
  }
}
