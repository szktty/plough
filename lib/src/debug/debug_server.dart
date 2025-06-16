import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';

/// デバッグ用HTTPサーバー
///
/// リアルタイムでログやグラフの状態を監視できるWebインターフェースを提供
@internal
class PloughDebugServer {
  PloughDebugServer._();

  factory PloughDebugServer() => _instance ??= PloughDebugServer._();

  static PloughDebugServer? _instance;

  /// Hot reload時のクリーンアップをサポート
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

  /// デバッグサーバーを開始
  Future<void> start({int port = 8080, bool tryAlternativePorts = true}) async {
    if (_server != null) {
      logWarning(
          LogCategory.debug, 'Debug server is already running on port $_port');
      return;
    }

    _port = port;

    // 代替ポートのリスト
    final portsToTry = tryAlternativePorts
        ? [port, port + 1, port + 2, port + 10, port + 100]
        : [port];

    for (final tryPort in portsToTry) {
      try {
        _port = tryPort;

        // 既存のサーバーがポートを使用している可能性があるため、まず停止を試みる
        await _tryCleanupExistingServer();

        // ローカルホストのみでバインド（macOS サンドボックスの制限を回避）
        _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _port, shared: true);
        logInfo(LogCategory.debug, 'Debug server started on $url');
        logInfo(LogCategory.debug, 'Server port: ${_server!.port}');
        logInfo(LogCategory.debug, 'Server address: ${_server!.address.address}');

        // リスナーを設定してすぐにテスト
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
        
        // サーバーが実際にリスニングしているか確認
        logInfo(LogCategory.debug, 
            'Server listening: address=${_server!.address}, port=${_server!.port}');
        
        // サーバーが正しく動作しているかテスト
        Future<void>.delayed(const Duration(milliseconds: 100))
            .then((_) => _testServerConnection());
        
        return; // 成功
      } on SocketException catch (e) {
        logWarning(LogCategory.debug,
            'Failed to start server on port $tryPort: ${e.message}');
        _server = null;

        if (tryPort == portsToTry.last) {
          // 最後のポートでも失敗
          logError(LogCategory.debug,
              'Failed to start debug server on any port: $portsToTry');
          throw SocketException(
              'Failed to start debug server on any port: $portsToTry');
        }
      }
    }
  }
  
  /// サーバーの接続テスト
  Future<void> _testServerConnection() async {
    try {
      final client = HttpClient();
      
      // User-Agentを設定
      client.userAgent = 'PloughDebugServer/1.0';
      
      final request = await client.getUrl(Uri.parse('http://localhost:$_port/test'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        logInfo(LogCategory.debug, 'Server connection test successful');
      } else {
        logWarning(LogCategory.debug, 
            'Server connection test failed: ${response.statusCode}');
      }
      
      client.close();
    } catch (e) {
      logWarning(LogCategory.debug, 'Server connection test failed: $e');
      logWarning(LogCategory.debug, 
          'This may be due to macOS sandbox restrictions');
      
      // macOS サンドボックスの問題の場合の代替案を提示
      logInfo(LogCategory.debug, 
          'Alternative: Use the CLI debug server (dart debug/simple_server.dart)');
    }
  }

  /// 既存のサーバーのクリーンアップを試みる
  Future<void> _tryCleanupExistingServer() async {
    try {
      // 短時間だけ接続を試みて、既存のサーバーがあるか確認
      final socket = await Socket.connect(
        'localhost',
        _port,
        timeout: const Duration(milliseconds: 100),
      );
      await socket.close();
      // 接続できた場合は、少し待ってから再試行
      logWarning(LogCategory.debug,
          'Found existing server on port $_port, waiting for cleanup...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } on SocketException {
      // 接続できない場合は問題なし（ポートが空いている）
    }
  }

  /// デバッグサーバーを停止
  Future<void> stop() async {
    if (_server == null) return;

    // 全クライアントを切断
    for (final client in _clients) {
      await client.close();
    }
    _clients.clear();

    await _server!.close();
    _server = null;
    logInfo(LogCategory.debug, 'Debug server stopped');
  }

  /// 強制的にシャットダウン（同期的）
  void _forceShutdown() {
    try {
      for (final client in _clients) {
        client.close();
      }
      _clients.clear();

      _server?.close(force: true);
      _server = null;
    } on Exception {
      // エラーを無視
    }
  }

  /// ログをブロードキャスト
  void broadcastLog(LogCategory category, String level, String message) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'category': category.name,
      'level': level,
      'message': message,
    };

    // バッファに追加
    _logBuffer.add(logEntry);
    if (_logBuffer.length > _maxLogBuffer) {
      _logBuffer.removeAt(0);
    }

    // 接続中のクライアントにブロードキャスト
    final data = jsonEncode({
      'type': 'log',
      'data': logEntry,
    });

    _clients.removeWhere((client) {
      try {
        client.add(data);
        return false;
      } catch (e) {
        return true; // 切断されたクライアントを削除
      }
    });
  }

  /// グラフ状態をブロードキャスト
  void broadcastGraphState(Map<String, dynamic> state) {
    final data = jsonEncode({
      'type': 'graph_state',
      'data': state,
    });

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
      logInfo(LogCategory.debug,
          'Received request: ${request.method} ${request.uri.path}');
      logInfo(LogCategory.debug,
          'Headers: ${request.headers}');
      logInfo(LogCategory.debug,
          'Remote: ${request.connectionInfo?.remoteAddress}');
      logInfo(LogCategory.debug,
          'Protocol: ${request.protocolVersion}');

      final uri = request.uri;
      
      // シンプルなテストレスポンス
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
      logDebug(LogCategory.debug,
          'WebSocket client connected (${_clients.length} total)');

      // 接続時に過去のログを送信
      for (final log in _logBuffer) {
        socket.add(jsonEncode({
          'type': 'log',
          'data': log,
        }));
      }

      socket.listen(
        (data) {
          // クライアントからのメッセージ処理（将来の拡張用）
        },
        onDone: () {
          _clients.remove(socket);
          logDebug(LogCategory.debug,
              'WebSocket client disconnected (${_clients.length} total)');
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

      // まずはバッファのログのみを返す（シンプルに）
      final response = {
        'logs': _logBuffer,
        'count': _logBuffer.length,
      };

      logDebug(
          LogCategory.debug, 'Returning ${_logBuffer.length} logs from buffer');

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
          ..write(jsonEncode(
              {'error': 'Internal server error', 'message': e.toString()}))
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
    <title>Plough Debug Console</title>
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
        <h1>🔍 Plough Debug Console</h1>
        <p>リアルタイムログ監視とデバッグ情報</p>
    </div>
    
    <div class="controls">
        <button onclick="clearLogs()">ログクリア</button>
        <button onclick="exportLogs()">ログエクスポート</button>
        <span id="status">接続中...</span>
    </div>
    
    <div class="filter-controls">
        <select id="categoryFilter">
            <option value="">全カテゴリ</option>
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
            <option value="">全レベル</option>
            <option value="DEBUG">Debug</option>
            <option value="INFO">Info</option>
            <option value="WARNING">Warning</option>
            <option value="ERROR">Error</option>
        </select>
        
        <input type="text" id="searchFilter" placeholder="メッセージ検索...">
    </div>
    
    <div class="log-container" id="logContainer"></div>
    
    <script>
        const ws = new WebSocket('ws://localhost:$_port/ws');
        const logContainer = document.getElementById('logContainer');
        const statusElement = document.getElementById('status');
        let logs = [];
        
        ws.onopen = () => {
            statusElement.textContent = '接続済み';
            statusElement.style.color = '#4fc1ff';
        };
        
        ws.onclose = () => {
            statusElement.textContent = '切断';
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
        
        // フィルター変更時の処理
        document.getElementById('categoryFilter').addEventListener('change', updateLogDisplay);
        document.getElementById('levelFilter').addEventListener('change', updateLogDisplay);
        document.getElementById('searchFilter').addEventListener('input', updateLogDisplay);
    </script>
</body>
</html>
''';
  }
}
