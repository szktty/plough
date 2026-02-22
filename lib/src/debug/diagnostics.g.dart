// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GraphDiagnostics _$GraphDiagnosticsFromJson(Map<String, dynamic> json) =>
    _GraphDiagnostics(
      snapshot:
          GraphSnapshot.fromJson(json['snapshot'] as Map<String, dynamic>),
      gestureHistory: (json['gestureHistory'] as List<dynamic>)
          .map((e) => GestureEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      renderHistory: (json['renderHistory'] as List<dynamic>)
          .map((e) => RenderEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      stateChanges: (json['stateChanges'] as List<dynamic>)
          .map((e) => StateChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      performance: PerformanceMetrics.fromJson(
          json['performance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GraphDiagnosticsToJson(_GraphDiagnostics instance) =>
    <String, dynamic>{
      'snapshot': instance.snapshot,
      'gestureHistory': instance.gestureHistory,
      'renderHistory': instance.renderHistory,
      'stateChanges': instance.stateChanges,
      'performance': instance.performance,
    };

_GraphSnapshot _$GraphSnapshotFromJson(Map<String, dynamic> json) =>
    _GraphSnapshot(
      timestamp: DateTime.parse(json['timestamp'] as String),
      nodeCount: (json['nodeCount'] as num).toInt(),
      linkCount: (json['linkCount'] as num).toInt(),
      nodePositions: (json['nodePositions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, NodePosition.fromJson(e as Map<String, dynamic>)),
      ),
      layoutMetrics:
          LayoutMetrics.fromJson(json['layoutMetrics'] as Map<String, dynamic>),
      currentGesture:
          GestureState.fromJson(json['currentGesture'] as Map<String, dynamic>),
      selectedNodeId: json['selectedNodeId'] as String?,
      draggedNodeIds: (json['draggedNodeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GraphSnapshotToJson(_GraphSnapshot instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'nodeCount': instance.nodeCount,
      'linkCount': instance.linkCount,
      'nodePositions': instance.nodePositions,
      'layoutMetrics': instance.layoutMetrics,
      'currentGesture': instance.currentGesture,
      'selectedNodeId': instance.selectedNodeId,
      'draggedNodeIds': instance.draggedNodeIds,
    };

_NodePosition _$NodePositionFromJson(Map<String, dynamic> json) =>
    _NodePosition(
      nodeId: json['nodeId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      isFixed: json['isFixed'] as bool,
      isAnimating: json['isAnimating'] as bool?,
    );

Map<String, dynamic> _$NodePositionToJson(_NodePosition instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'x': instance.x,
      'y': instance.y,
      'isFixed': instance.isFixed,
      'isAnimating': instance.isAnimating,
    };

_LayoutMetrics _$LayoutMetricsFromJson(Map<String, dynamic> json) =>
    _LayoutMetrics(
      strategy: json['strategy'] as String,
      lastCalculationTime:
          Duration(microseconds: (json['lastCalculationTime'] as num).toInt()),
      iterationCount: (json['iterationCount'] as num).toInt(),
      totalEnergy: (json['totalEnergy'] as num).toDouble(),
      graphBounds: sizeFromJson(json['graphBounds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LayoutMetricsToJson(_LayoutMetrics instance) =>
    <String, dynamic>{
      'strategy': instance.strategy,
      'lastCalculationTime': instance.lastCalculationTime.inMicroseconds,
      'iterationCount': instance.iterationCount,
      'totalEnergy': instance.totalEnergy,
      'graphBounds': sizeToJson(instance.graphBounds),
    };

_GestureState _$GestureStateFromJson(Map<String, dynamic> json) =>
    _GestureState(
      isPanning: json['isPanning'] as bool,
      isDragging: json['isDragging'] as bool,
      isSelecting: json['isSelecting'] as bool,
      currentPosition: nullableOffsetFromJson(
          json['currentPosition'] as Map<String, dynamic>?),
      hoveredNodeId: json['hoveredNodeId'] as String?,
    );

Map<String, dynamic> _$GestureStateToJson(_GestureState instance) =>
    <String, dynamic>{
      'isPanning': instance.isPanning,
      'isDragging': instance.isDragging,
      'isSelecting': instance.isSelecting,
      'currentPosition': nullableOffsetToJson(instance.currentPosition),
      'hoveredNodeId': instance.hoveredNodeId,
    };

_GestureEvent _$GestureEventFromJson(Map<String, dynamic> json) =>
    _GestureEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$GestureEventTypeEnumMap, json['type']),
      position: offsetFromJson(json['position'] as Map<String, dynamic>),
      wasConsumed: json['wasConsumed'] as bool,
      callbackInvoked: json['callbackInvoked'] as String,
      targetNodeId: json['targetNodeId'] as String?,
      targetLinkId: json['targetLinkId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GestureEventToJson(_GestureEvent instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$GestureEventTypeEnumMap[instance.type]!,
      'position': offsetToJson(instance.position),
      'wasConsumed': instance.wasConsumed,
      'callbackInvoked': instance.callbackInvoked,
      'targetNodeId': instance.targetNodeId,
      'targetLinkId': instance.targetLinkId,
      'metadata': instance.metadata,
    };

const _$GestureEventTypeEnumMap = {
  GestureEventType.pointerDown: 'pointerDown',
  GestureEventType.pointerUp: 'pointerUp',
  GestureEventType.pointerMove: 'pointerMove',
  GestureEventType.tap: 'tap',
  GestureEventType.doubleTap: 'doubleTap',
  GestureEventType.longPress: 'longPress',
  GestureEventType.panStart: 'panStart',
  GestureEventType.panUpdate: 'panUpdate',
  GestureEventType.panEnd: 'panEnd',
  GestureEventType.scale: 'scale',
};

_RenderEvent _$RenderEventFromJson(Map<String, dynamic> json) => _RenderEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      phase: $enumDecode(_$RenderPhaseEnumMap, json['phase']),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      affectedNodes: (json['affectedNodes'] as num).toInt(),
      trigger: json['trigger'] as String,
      stackTrace: json['stackTrace'] as String?,
    );

Map<String, dynamic> _$RenderEventToJson(_RenderEvent instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'phase': _$RenderPhaseEnumMap[instance.phase]!,
      'duration': instance.duration.inMicroseconds,
      'affectedNodes': instance.affectedNodes,
      'trigger': instance.trigger,
      'stackTrace': instance.stackTrace,
    };

const _$RenderPhaseEnumMap = {
  RenderPhase.layout: 'layout',
  RenderPhase.paint: 'paint',
  RenderPhase.composite: 'composite',
  RenderPhase.build: 'build',
  RenderPhase.postFrameCallback: 'postFrameCallback',
};

_StateChange _$StateChangeFromJson(Map<String, dynamic> json) => _StateChange(
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$StateChangeTypeEnumMap, json['type']),
      target: json['target'] as String,
      source: json['source'] as String,
      oldValue: json['oldValue'] as Map<String, dynamic>?,
      newValue: json['newValue'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] as String?,
    );

Map<String, dynamic> _$StateChangeToJson(_StateChange instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$StateChangeTypeEnumMap[instance.type]!,
      'target': instance.target,
      'source': instance.source,
      'oldValue': instance.oldValue,
      'newValue': instance.newValue,
      'stackTrace': instance.stackTrace,
    };

const _$StateChangeTypeEnumMap = {
  StateChangeType.valueNotifier: 'valueNotifier',
  StateChangeType.setState: 'setState',
  StateChangeType.inheritedWidget: 'inheritedWidget',
  StateChangeType.nodePosition: 'nodePosition',
  StateChangeType.nodeSelection: 'nodeSelection',
  StateChangeType.graphStructure: 'graphStructure',
  StateChangeType.layoutStrategy: 'layoutStrategy',
  StateChangeType.animation: 'animation',
};

_PerformanceMetrics _$PerformanceMetricsFromJson(Map<String, dynamic> json) =>
    _PerformanceMetrics(
      averageFps: (json['averageFps'] as num).toDouble(),
      currentFps: (json['currentFps'] as num).toDouble(),
      droppedFrames: (json['droppedFrames'] as num).toInt(),
      averageFrameTime:
          Duration(microseconds: (json['averageFrameTime'] as num).toInt()),
      worstFrameTime:
          Duration(microseconds: (json['worstFrameTime'] as num).toInt()),
      memoryUsageMB: (json['memoryUsageMB'] as num).toInt(),
      measurementStart: DateTime.parse(json['measurementStart'] as String),
      measurementEnd: DateTime.parse(json['measurementEnd'] as String),
    );

Map<String, dynamic> _$PerformanceMetricsToJson(_PerformanceMetrics instance) =>
    <String, dynamic>{
      'averageFps': instance.averageFps,
      'currentFps': instance.currentFps,
      'droppedFrames': instance.droppedFrames,
      'averageFrameTime': instance.averageFrameTime.inMicroseconds,
      'worstFrameTime': instance.worstFrameTime.inMicroseconds,
      'memoryUsageMB': instance.memoryUsageMB,
      'measurementStart': instance.measurementStart.toIso8601String(),
      'measurementEnd': instance.measurementEnd.toIso8601String(),
    };
