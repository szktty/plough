// Debug event types
enum EventType {
  callback,
  rebuild,
  notification,
  gesture,
  layout,
}

// ジェスチャーテストの種類
enum GestureTestType {
  tap('タップ', 'ノードを1回タップして選択状態を切り替える'),
  doubleTap('ダブルタップ', '短時間に2回タップする'),
  drag('ドラッグ', 'ノードを押してドラッグで移動させる'),
  hover('ホバー', 'マウスをノード上に置いてホバー状態にする'),
  longPress('長押し', '長時間押し続ける'),
  tapAndHold('タップ&ホールド', 'タップ後に少し保持する');

  const GestureTestType(this.displayName, this.description);
  final String displayName;
  final String description;
}

// ジェスチャー検証結果
class GestureValidationResult {
  final DateTime timestamp;
  final GestureTestType testType;
  final String phase; // 'down', 'move', 'up', 'completed'
  final String nodeId;
  final List<GestureValidationCheck> checks;
  final bool isSuccess;

  GestureValidationResult({
    required this.timestamp,
    required this.testType,
    required this.phase,
    required this.nodeId,
    required this.checks,
  }) : isSuccess = checks.every((check) => check.passed);
}

// 個別の検証項目
class GestureValidationCheck {
  final String name;
  final String description;
  final bool passed;
  final String? expectedValue;
  final String? actualValue;
  final String? failureReason;

  GestureValidationCheck({
    required this.name,
    required this.description,
    required this.passed,
    this.expectedValue,
    this.actualValue,
    this.failureReason,
  });
}

// Debug event model
class DebugEvent {
  final EventType type;
  final String source;
  final String message;
  final DateTime timestamp;
  final String? details;
  final Map<String, dynamic>? jsonData;

  DebugEvent({
    required this.type,
    required this.source,
    required this.message,
    required this.timestamp,
    this.details,
    this.jsonData,
  });
}