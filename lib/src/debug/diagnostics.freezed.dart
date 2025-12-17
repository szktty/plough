// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GraphDiagnostics _$GraphDiagnosticsFromJson(Map<String, dynamic> json) {
  return _GraphDiagnostics.fromJson(json);
}

/// @nodoc
mixin _$GraphDiagnostics {
  GraphSnapshot get snapshot => throw _privateConstructorUsedError;
  List<GestureEvent> get gestureHistory => throw _privateConstructorUsedError;
  List<RenderEvent> get renderHistory => throw _privateConstructorUsedError;
  List<StateChange> get stateChanges => throw _privateConstructorUsedError;
  PerformanceMetrics get performance => throw _privateConstructorUsedError;

  /// Serializes this GraphDiagnostics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphDiagnosticsCopyWith<GraphDiagnostics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphDiagnosticsCopyWith<$Res> {
  factory $GraphDiagnosticsCopyWith(
          GraphDiagnostics value, $Res Function(GraphDiagnostics) then) =
      _$GraphDiagnosticsCopyWithImpl<$Res, GraphDiagnostics>;
  @useResult
  $Res call(
      {GraphSnapshot snapshot,
      List<GestureEvent> gestureHistory,
      List<RenderEvent> renderHistory,
      List<StateChange> stateChanges,
      PerformanceMetrics performance});

  $GraphSnapshotCopyWith<$Res> get snapshot;
  $PerformanceMetricsCopyWith<$Res> get performance;
}

/// @nodoc
class _$GraphDiagnosticsCopyWithImpl<$Res, $Val extends GraphDiagnostics>
    implements $GraphDiagnosticsCopyWith<$Res> {
  _$GraphDiagnosticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapshot = null,
    Object? gestureHistory = null,
    Object? renderHistory = null,
    Object? stateChanges = null,
    Object? performance = null,
  }) {
    return _then(_value.copyWith(
      snapshot: null == snapshot
          ? _value.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as GraphSnapshot,
      gestureHistory: null == gestureHistory
          ? _value.gestureHistory
          : gestureHistory // ignore: cast_nullable_to_non_nullable
              as List<GestureEvent>,
      renderHistory: null == renderHistory
          ? _value.renderHistory
          : renderHistory // ignore: cast_nullable_to_non_nullable
              as List<RenderEvent>,
      stateChanges: null == stateChanges
          ? _value.stateChanges
          : stateChanges // ignore: cast_nullable_to_non_nullable
              as List<StateChange>,
      performance: null == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as PerformanceMetrics,
    ) as $Val);
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphSnapshotCopyWith<$Res> get snapshot {
    return $GraphSnapshotCopyWith<$Res>(_value.snapshot, (value) {
      return _then(_value.copyWith(snapshot: value) as $Val);
    });
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PerformanceMetricsCopyWith<$Res> get performance {
    return $PerformanceMetricsCopyWith<$Res>(_value.performance, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GraphDiagnosticsImplCopyWith<$Res>
    implements $GraphDiagnosticsCopyWith<$Res> {
  factory _$$GraphDiagnosticsImplCopyWith(_$GraphDiagnosticsImpl value,
          $Res Function(_$GraphDiagnosticsImpl) then) =
      __$$GraphDiagnosticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GraphSnapshot snapshot,
      List<GestureEvent> gestureHistory,
      List<RenderEvent> renderHistory,
      List<StateChange> stateChanges,
      PerformanceMetrics performance});

  @override
  $GraphSnapshotCopyWith<$Res> get snapshot;
  @override
  $PerformanceMetricsCopyWith<$Res> get performance;
}

/// @nodoc
class __$$GraphDiagnosticsImplCopyWithImpl<$Res>
    extends _$GraphDiagnosticsCopyWithImpl<$Res, _$GraphDiagnosticsImpl>
    implements _$$GraphDiagnosticsImplCopyWith<$Res> {
  __$$GraphDiagnosticsImplCopyWithImpl(_$GraphDiagnosticsImpl _value,
      $Res Function(_$GraphDiagnosticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapshot = null,
    Object? gestureHistory = null,
    Object? renderHistory = null,
    Object? stateChanges = null,
    Object? performance = null,
  }) {
    return _then(_$GraphDiagnosticsImpl(
      snapshot: null == snapshot
          ? _value.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as GraphSnapshot,
      gestureHistory: null == gestureHistory
          ? _value._gestureHistory
          : gestureHistory // ignore: cast_nullable_to_non_nullable
              as List<GestureEvent>,
      renderHistory: null == renderHistory
          ? _value._renderHistory
          : renderHistory // ignore: cast_nullable_to_non_nullable
              as List<RenderEvent>,
      stateChanges: null == stateChanges
          ? _value._stateChanges
          : stateChanges // ignore: cast_nullable_to_non_nullable
              as List<StateChange>,
      performance: null == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as PerformanceMetrics,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GraphDiagnosticsImpl
    with DiagnosticableTreeMixin
    implements _GraphDiagnostics {
  const _$GraphDiagnosticsImpl(
      {required this.snapshot,
      required final List<GestureEvent> gestureHistory,
      required final List<RenderEvent> renderHistory,
      required final List<StateChange> stateChanges,
      required this.performance})
      : _gestureHistory = gestureHistory,
        _renderHistory = renderHistory,
        _stateChanges = stateChanges;

  factory _$GraphDiagnosticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GraphDiagnosticsImplFromJson(json);

  @override
  final GraphSnapshot snapshot;
  final List<GestureEvent> _gestureHistory;
  @override
  List<GestureEvent> get gestureHistory {
    if (_gestureHistory is EqualUnmodifiableListView) return _gestureHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gestureHistory);
  }

  final List<RenderEvent> _renderHistory;
  @override
  List<RenderEvent> get renderHistory {
    if (_renderHistory is EqualUnmodifiableListView) return _renderHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_renderHistory);
  }

  final List<StateChange> _stateChanges;
  @override
  List<StateChange> get stateChanges {
    if (_stateChanges is EqualUnmodifiableListView) return _stateChanges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stateChanges);
  }

  @override
  final PerformanceMetrics performance;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphDiagnostics(snapshot: $snapshot, gestureHistory: $gestureHistory, renderHistory: $renderHistory, stateChanges: $stateChanges, performance: $performance)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphDiagnostics'))
      ..add(DiagnosticsProperty('snapshot', snapshot))
      ..add(DiagnosticsProperty('gestureHistory', gestureHistory))
      ..add(DiagnosticsProperty('renderHistory', renderHistory))
      ..add(DiagnosticsProperty('stateChanges', stateChanges))
      ..add(DiagnosticsProperty('performance', performance));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphDiagnosticsImpl &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot) &&
            const DeepCollectionEquality()
                .equals(other._gestureHistory, _gestureHistory) &&
            const DeepCollectionEquality()
                .equals(other._renderHistory, _renderHistory) &&
            const DeepCollectionEquality()
                .equals(other._stateChanges, _stateChanges) &&
            (identical(other.performance, performance) ||
                other.performance == performance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      snapshot,
      const DeepCollectionEquality().hash(_gestureHistory),
      const DeepCollectionEquality().hash(_renderHistory),
      const DeepCollectionEquality().hash(_stateChanges),
      performance);

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphDiagnosticsImplCopyWith<_$GraphDiagnosticsImpl> get copyWith =>
      __$$GraphDiagnosticsImplCopyWithImpl<_$GraphDiagnosticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GraphDiagnosticsImplToJson(
      this,
    );
  }
}

abstract class _GraphDiagnostics implements GraphDiagnostics {
  const factory _GraphDiagnostics(
      {required final GraphSnapshot snapshot,
      required final List<GestureEvent> gestureHistory,
      required final List<RenderEvent> renderHistory,
      required final List<StateChange> stateChanges,
      required final PerformanceMetrics performance}) = _$GraphDiagnosticsImpl;

  factory _GraphDiagnostics.fromJson(Map<String, dynamic> json) =
      _$GraphDiagnosticsImpl.fromJson;

  @override
  GraphSnapshot get snapshot;
  @override
  List<GestureEvent> get gestureHistory;
  @override
  List<RenderEvent> get renderHistory;
  @override
  List<StateChange> get stateChanges;
  @override
  PerformanceMetrics get performance;

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphDiagnosticsImplCopyWith<_$GraphDiagnosticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GraphSnapshot _$GraphSnapshotFromJson(Map<String, dynamic> json) {
  return _GraphSnapshot.fromJson(json);
}

/// @nodoc
mixin _$GraphSnapshot {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get nodeCount => throw _privateConstructorUsedError;
  int get linkCount => throw _privateConstructorUsedError;
  Map<String, NodePosition> get nodePositions =>
      throw _privateConstructorUsedError;
  LayoutMetrics get layoutMetrics => throw _privateConstructorUsedError;
  GestureState get currentGesture => throw _privateConstructorUsedError;
  String? get selectedNodeId => throw _privateConstructorUsedError;
  List<String>? get draggedNodeIds => throw _privateConstructorUsedError;

  /// Serializes this GraphSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphSnapshotCopyWith<GraphSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphSnapshotCopyWith<$Res> {
  factory $GraphSnapshotCopyWith(
          GraphSnapshot value, $Res Function(GraphSnapshot) then) =
      _$GraphSnapshotCopyWithImpl<$Res, GraphSnapshot>;
  @useResult
  $Res call(
      {DateTime timestamp,
      int nodeCount,
      int linkCount,
      Map<String, NodePosition> nodePositions,
      LayoutMetrics layoutMetrics,
      GestureState currentGesture,
      String? selectedNodeId,
      List<String>? draggedNodeIds});

  $LayoutMetricsCopyWith<$Res> get layoutMetrics;
  $GestureStateCopyWith<$Res> get currentGesture;
}

/// @nodoc
class _$GraphSnapshotCopyWithImpl<$Res, $Val extends GraphSnapshot>
    implements $GraphSnapshotCopyWith<$Res> {
  _$GraphSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? nodeCount = null,
    Object? linkCount = null,
    Object? nodePositions = null,
    Object? layoutMetrics = null,
    Object? currentGesture = null,
    Object? selectedNodeId = freezed,
    Object? draggedNodeIds = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nodeCount: null == nodeCount
          ? _value.nodeCount
          : nodeCount // ignore: cast_nullable_to_non_nullable
              as int,
      linkCount: null == linkCount
          ? _value.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      nodePositions: null == nodePositions
          ? _value.nodePositions
          : nodePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, NodePosition>,
      layoutMetrics: null == layoutMetrics
          ? _value.layoutMetrics
          : layoutMetrics // ignore: cast_nullable_to_non_nullable
              as LayoutMetrics,
      currentGesture: null == currentGesture
          ? _value.currentGesture
          : currentGesture // ignore: cast_nullable_to_non_nullable
              as GestureState,
      selectedNodeId: freezed == selectedNodeId
          ? _value.selectedNodeId
          : selectedNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedNodeIds: freezed == draggedNodeIds
          ? _value.draggedNodeIds
          : draggedNodeIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutMetricsCopyWith<$Res> get layoutMetrics {
    return $LayoutMetricsCopyWith<$Res>(_value.layoutMetrics, (value) {
      return _then(_value.copyWith(layoutMetrics: value) as $Val);
    });
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GestureStateCopyWith<$Res> get currentGesture {
    return $GestureStateCopyWith<$Res>(_value.currentGesture, (value) {
      return _then(_value.copyWith(currentGesture: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GraphSnapshotImplCopyWith<$Res>
    implements $GraphSnapshotCopyWith<$Res> {
  factory _$$GraphSnapshotImplCopyWith(
          _$GraphSnapshotImpl value, $Res Function(_$GraphSnapshotImpl) then) =
      __$$GraphSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      int nodeCount,
      int linkCount,
      Map<String, NodePosition> nodePositions,
      LayoutMetrics layoutMetrics,
      GestureState currentGesture,
      String? selectedNodeId,
      List<String>? draggedNodeIds});

  @override
  $LayoutMetricsCopyWith<$Res> get layoutMetrics;
  @override
  $GestureStateCopyWith<$Res> get currentGesture;
}

/// @nodoc
class __$$GraphSnapshotImplCopyWithImpl<$Res>
    extends _$GraphSnapshotCopyWithImpl<$Res, _$GraphSnapshotImpl>
    implements _$$GraphSnapshotImplCopyWith<$Res> {
  __$$GraphSnapshotImplCopyWithImpl(
      _$GraphSnapshotImpl _value, $Res Function(_$GraphSnapshotImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? nodeCount = null,
    Object? linkCount = null,
    Object? nodePositions = null,
    Object? layoutMetrics = null,
    Object? currentGesture = null,
    Object? selectedNodeId = freezed,
    Object? draggedNodeIds = freezed,
  }) {
    return _then(_$GraphSnapshotImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nodeCount: null == nodeCount
          ? _value.nodeCount
          : nodeCount // ignore: cast_nullable_to_non_nullable
              as int,
      linkCount: null == linkCount
          ? _value.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      nodePositions: null == nodePositions
          ? _value._nodePositions
          : nodePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, NodePosition>,
      layoutMetrics: null == layoutMetrics
          ? _value.layoutMetrics
          : layoutMetrics // ignore: cast_nullable_to_non_nullable
              as LayoutMetrics,
      currentGesture: null == currentGesture
          ? _value.currentGesture
          : currentGesture // ignore: cast_nullable_to_non_nullable
              as GestureState,
      selectedNodeId: freezed == selectedNodeId
          ? _value.selectedNodeId
          : selectedNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedNodeIds: freezed == draggedNodeIds
          ? _value._draggedNodeIds
          : draggedNodeIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GraphSnapshotImpl
    with DiagnosticableTreeMixin
    implements _GraphSnapshot {
  const _$GraphSnapshotImpl(
      {required this.timestamp,
      required this.nodeCount,
      required this.linkCount,
      required final Map<String, NodePosition> nodePositions,
      required this.layoutMetrics,
      required this.currentGesture,
      this.selectedNodeId,
      final List<String>? draggedNodeIds})
      : _nodePositions = nodePositions,
        _draggedNodeIds = draggedNodeIds;

  factory _$GraphSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$GraphSnapshotImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int nodeCount;
  @override
  final int linkCount;
  final Map<String, NodePosition> _nodePositions;
  @override
  Map<String, NodePosition> get nodePositions {
    if (_nodePositions is EqualUnmodifiableMapView) return _nodePositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nodePositions);
  }

  @override
  final LayoutMetrics layoutMetrics;
  @override
  final GestureState currentGesture;
  @override
  final String? selectedNodeId;
  final List<String>? _draggedNodeIds;
  @override
  List<String>? get draggedNodeIds {
    final value = _draggedNodeIds;
    if (value == null) return null;
    if (_draggedNodeIds is EqualUnmodifiableListView) return _draggedNodeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphSnapshot(timestamp: $timestamp, nodeCount: $nodeCount, linkCount: $linkCount, nodePositions: $nodePositions, layoutMetrics: $layoutMetrics, currentGesture: $currentGesture, selectedNodeId: $selectedNodeId, draggedNodeIds: $draggedNodeIds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphSnapshot'))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('nodeCount', nodeCount))
      ..add(DiagnosticsProperty('linkCount', linkCount))
      ..add(DiagnosticsProperty('nodePositions', nodePositions))
      ..add(DiagnosticsProperty('layoutMetrics', layoutMetrics))
      ..add(DiagnosticsProperty('currentGesture', currentGesture))
      ..add(DiagnosticsProperty('selectedNodeId', selectedNodeId))
      ..add(DiagnosticsProperty('draggedNodeIds', draggedNodeIds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphSnapshotImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.nodeCount, nodeCount) ||
                other.nodeCount == nodeCount) &&
            (identical(other.linkCount, linkCount) ||
                other.linkCount == linkCount) &&
            const DeepCollectionEquality()
                .equals(other._nodePositions, _nodePositions) &&
            (identical(other.layoutMetrics, layoutMetrics) ||
                other.layoutMetrics == layoutMetrics) &&
            (identical(other.currentGesture, currentGesture) ||
                other.currentGesture == currentGesture) &&
            (identical(other.selectedNodeId, selectedNodeId) ||
                other.selectedNodeId == selectedNodeId) &&
            const DeepCollectionEquality()
                .equals(other._draggedNodeIds, _draggedNodeIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      nodeCount,
      linkCount,
      const DeepCollectionEquality().hash(_nodePositions),
      layoutMetrics,
      currentGesture,
      selectedNodeId,
      const DeepCollectionEquality().hash(_draggedNodeIds));

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphSnapshotImplCopyWith<_$GraphSnapshotImpl> get copyWith =>
      __$$GraphSnapshotImplCopyWithImpl<_$GraphSnapshotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GraphSnapshotImplToJson(
      this,
    );
  }
}

abstract class _GraphSnapshot implements GraphSnapshot {
  const factory _GraphSnapshot(
      {required final DateTime timestamp,
      required final int nodeCount,
      required final int linkCount,
      required final Map<String, NodePosition> nodePositions,
      required final LayoutMetrics layoutMetrics,
      required final GestureState currentGesture,
      final String? selectedNodeId,
      final List<String>? draggedNodeIds}) = _$GraphSnapshotImpl;

  factory _GraphSnapshot.fromJson(Map<String, dynamic> json) =
      _$GraphSnapshotImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get nodeCount;
  @override
  int get linkCount;
  @override
  Map<String, NodePosition> get nodePositions;
  @override
  LayoutMetrics get layoutMetrics;
  @override
  GestureState get currentGesture;
  @override
  String? get selectedNodeId;
  @override
  List<String>? get draggedNodeIds;

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphSnapshotImplCopyWith<_$GraphSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NodePosition _$NodePositionFromJson(Map<String, dynamic> json) {
  return _NodePosition.fromJson(json);
}

/// @nodoc
mixin _$NodePosition {
  String get nodeId => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  bool get isFixed => throw _privateConstructorUsedError;
  bool? get isAnimating => throw _privateConstructorUsedError;

  /// Serializes this NodePosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NodePositionCopyWith<NodePosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NodePositionCopyWith<$Res> {
  factory $NodePositionCopyWith(
          NodePosition value, $Res Function(NodePosition) then) =
      _$NodePositionCopyWithImpl<$Res, NodePosition>;
  @useResult
  $Res call(
      {String nodeId, double x, double y, bool isFixed, bool? isAnimating});
}

/// @nodoc
class _$NodePositionCopyWithImpl<$Res, $Val extends NodePosition>
    implements $NodePositionCopyWith<$Res> {
  _$NodePositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nodeId = null,
    Object? x = null,
    Object? y = null,
    Object? isFixed = null,
    Object? isAnimating = freezed,
  }) {
    return _then(_value.copyWith(
      nodeId: null == nodeId
          ? _value.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      isFixed: null == isFixed
          ? _value.isFixed
          : isFixed // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnimating: freezed == isAnimating
          ? _value.isAnimating
          : isAnimating // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NodePositionImplCopyWith<$Res>
    implements $NodePositionCopyWith<$Res> {
  factory _$$NodePositionImplCopyWith(
          _$NodePositionImpl value, $Res Function(_$NodePositionImpl) then) =
      __$$NodePositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nodeId, double x, double y, bool isFixed, bool? isAnimating});
}

/// @nodoc
class __$$NodePositionImplCopyWithImpl<$Res>
    extends _$NodePositionCopyWithImpl<$Res, _$NodePositionImpl>
    implements _$$NodePositionImplCopyWith<$Res> {
  __$$NodePositionImplCopyWithImpl(
      _$NodePositionImpl _value, $Res Function(_$NodePositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nodeId = null,
    Object? x = null,
    Object? y = null,
    Object? isFixed = null,
    Object? isAnimating = freezed,
  }) {
    return _then(_$NodePositionImpl(
      nodeId: null == nodeId
          ? _value.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      isFixed: null == isFixed
          ? _value.isFixed
          : isFixed // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnimating: freezed == isAnimating
          ? _value.isAnimating
          : isAnimating // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NodePositionImpl with DiagnosticableTreeMixin implements _NodePosition {
  const _$NodePositionImpl(
      {required this.nodeId,
      required this.x,
      required this.y,
      required this.isFixed,
      this.isAnimating});

  factory _$NodePositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NodePositionImplFromJson(json);

  @override
  final String nodeId;
  @override
  final double x;
  @override
  final double y;
  @override
  final bool isFixed;
  @override
  final bool? isAnimating;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NodePosition(nodeId: $nodeId, x: $x, y: $y, isFixed: $isFixed, isAnimating: $isAnimating)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NodePosition'))
      ..add(DiagnosticsProperty('nodeId', nodeId))
      ..add(DiagnosticsProperty('x', x))
      ..add(DiagnosticsProperty('y', y))
      ..add(DiagnosticsProperty('isFixed', isFixed))
      ..add(DiagnosticsProperty('isAnimating', isAnimating));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NodePositionImpl &&
            (identical(other.nodeId, nodeId) || other.nodeId == nodeId) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.isFixed, isFixed) || other.isFixed == isFixed) &&
            (identical(other.isAnimating, isAnimating) ||
                other.isAnimating == isAnimating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, nodeId, x, y, isFixed, isAnimating);

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NodePositionImplCopyWith<_$NodePositionImpl> get copyWith =>
      __$$NodePositionImplCopyWithImpl<_$NodePositionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NodePositionImplToJson(
      this,
    );
  }
}

abstract class _NodePosition implements NodePosition {
  const factory _NodePosition(
      {required final String nodeId,
      required final double x,
      required final double y,
      required final bool isFixed,
      final bool? isAnimating}) = _$NodePositionImpl;

  factory _NodePosition.fromJson(Map<String, dynamic> json) =
      _$NodePositionImpl.fromJson;

  @override
  String get nodeId;
  @override
  double get x;
  @override
  double get y;
  @override
  bool get isFixed;
  @override
  bool? get isAnimating;

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NodePositionImplCopyWith<_$NodePositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LayoutMetrics _$LayoutMetricsFromJson(Map<String, dynamic> json) {
  return _LayoutMetrics.fromJson(json);
}

/// @nodoc
mixin _$LayoutMetrics {
  String get strategy => throw _privateConstructorUsedError;
  Duration get lastCalculationTime => throw _privateConstructorUsedError;
  int get iterationCount => throw _privateConstructorUsedError;
  double get totalEnergy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
  Size get graphBounds => throw _privateConstructorUsedError;

  /// Serializes this LayoutMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayoutMetricsCopyWith<LayoutMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayoutMetricsCopyWith<$Res> {
  factory $LayoutMetricsCopyWith(
          LayoutMetrics value, $Res Function(LayoutMetrics) then) =
      _$LayoutMetricsCopyWithImpl<$Res, LayoutMetrics>;
  @useResult
  $Res call(
      {String strategy,
      Duration lastCalculationTime,
      int iterationCount,
      double totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson) Size graphBounds});
}

/// @nodoc
class _$LayoutMetricsCopyWithImpl<$Res, $Val extends LayoutMetrics>
    implements $LayoutMetricsCopyWith<$Res> {
  _$LayoutMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strategy = null,
    Object? lastCalculationTime = null,
    Object? iterationCount = null,
    Object? totalEnergy = null,
    Object? graphBounds = null,
  }) {
    return _then(_value.copyWith(
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as String,
      lastCalculationTime: null == lastCalculationTime
          ? _value.lastCalculationTime
          : lastCalculationTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      iterationCount: null == iterationCount
          ? _value.iterationCount
          : iterationCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnergy: null == totalEnergy
          ? _value.totalEnergy
          : totalEnergy // ignore: cast_nullable_to_non_nullable
              as double,
      graphBounds: null == graphBounds
          ? _value.graphBounds
          : graphBounds // ignore: cast_nullable_to_non_nullable
              as Size,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LayoutMetricsImplCopyWith<$Res>
    implements $LayoutMetricsCopyWith<$Res> {
  factory _$$LayoutMetricsImplCopyWith(
          _$LayoutMetricsImpl value, $Res Function(_$LayoutMetricsImpl) then) =
      __$$LayoutMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String strategy,
      Duration lastCalculationTime,
      int iterationCount,
      double totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson) Size graphBounds});
}

/// @nodoc
class __$$LayoutMetricsImplCopyWithImpl<$Res>
    extends _$LayoutMetricsCopyWithImpl<$Res, _$LayoutMetricsImpl>
    implements _$$LayoutMetricsImplCopyWith<$Res> {
  __$$LayoutMetricsImplCopyWithImpl(
      _$LayoutMetricsImpl _value, $Res Function(_$LayoutMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strategy = null,
    Object? lastCalculationTime = null,
    Object? iterationCount = null,
    Object? totalEnergy = null,
    Object? graphBounds = null,
  }) {
    return _then(_$LayoutMetricsImpl(
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as String,
      lastCalculationTime: null == lastCalculationTime
          ? _value.lastCalculationTime
          : lastCalculationTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      iterationCount: null == iterationCount
          ? _value.iterationCount
          : iterationCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnergy: null == totalEnergy
          ? _value.totalEnergy
          : totalEnergy // ignore: cast_nullable_to_non_nullable
              as double,
      graphBounds: null == graphBounds
          ? _value.graphBounds
          : graphBounds // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LayoutMetricsImpl
    with DiagnosticableTreeMixin
    implements _LayoutMetrics {
  const _$LayoutMetricsImpl(
      {required this.strategy,
      required this.lastCalculationTime,
      required this.iterationCount,
      required this.totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
      required this.graphBounds});

  factory _$LayoutMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayoutMetricsImplFromJson(json);

  @override
  final String strategy;
  @override
  final Duration lastCalculationTime;
  @override
  final int iterationCount;
  @override
  final double totalEnergy;
  @override
  @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
  final Size graphBounds;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LayoutMetrics(strategy: $strategy, lastCalculationTime: $lastCalculationTime, iterationCount: $iterationCount, totalEnergy: $totalEnergy, graphBounds: $graphBounds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LayoutMetrics'))
      ..add(DiagnosticsProperty('strategy', strategy))
      ..add(DiagnosticsProperty('lastCalculationTime', lastCalculationTime))
      ..add(DiagnosticsProperty('iterationCount', iterationCount))
      ..add(DiagnosticsProperty('totalEnergy', totalEnergy))
      ..add(DiagnosticsProperty('graphBounds', graphBounds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayoutMetricsImpl &&
            (identical(other.strategy, strategy) ||
                other.strategy == strategy) &&
            (identical(other.lastCalculationTime, lastCalculationTime) ||
                other.lastCalculationTime == lastCalculationTime) &&
            (identical(other.iterationCount, iterationCount) ||
                other.iterationCount == iterationCount) &&
            (identical(other.totalEnergy, totalEnergy) ||
                other.totalEnergy == totalEnergy) &&
            (identical(other.graphBounds, graphBounds) ||
                other.graphBounds == graphBounds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, strategy, lastCalculationTime,
      iterationCount, totalEnergy, graphBounds);

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayoutMetricsImplCopyWith<_$LayoutMetricsImpl> get copyWith =>
      __$$LayoutMetricsImplCopyWithImpl<_$LayoutMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LayoutMetricsImplToJson(
      this,
    );
  }
}

abstract class _LayoutMetrics implements LayoutMetrics {
  const factory _LayoutMetrics(
      {required final String strategy,
      required final Duration lastCalculationTime,
      required final int iterationCount,
      required final double totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
      required final Size graphBounds}) = _$LayoutMetricsImpl;

  factory _LayoutMetrics.fromJson(Map<String, dynamic> json) =
      _$LayoutMetricsImpl.fromJson;

  @override
  String get strategy;
  @override
  Duration get lastCalculationTime;
  @override
  int get iterationCount;
  @override
  double get totalEnergy;
  @override
  @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
  Size get graphBounds;

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayoutMetricsImplCopyWith<_$LayoutMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GestureState _$GestureStateFromJson(Map<String, dynamic> json) {
  return _GestureState.fromJson(json);
}

/// @nodoc
mixin _$GestureState {
  bool get isPanning => throw _privateConstructorUsedError;
  bool get isDragging => throw _privateConstructorUsedError;
  bool get isSelecting => throw _privateConstructorUsedError;
  @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
  Offset? get currentPosition => throw _privateConstructorUsedError;
  String? get hoveredNodeId => throw _privateConstructorUsedError;

  /// Serializes this GestureState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GestureStateCopyWith<GestureState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GestureStateCopyWith<$Res> {
  factory $GestureStateCopyWith(
          GestureState value, $Res Function(GestureState) then) =
      _$GestureStateCopyWithImpl<$Res, GestureState>;
  @useResult
  $Res call(
      {bool isPanning,
      bool isDragging,
      bool isSelecting,
      @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
      Offset? currentPosition,
      String? hoveredNodeId});
}

/// @nodoc
class _$GestureStateCopyWithImpl<$Res, $Val extends GestureState>
    implements $GestureStateCopyWith<$Res> {
  _$GestureStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPanning = null,
    Object? isDragging = null,
    Object? isSelecting = null,
    Object? currentPosition = freezed,
    Object? hoveredNodeId = freezed,
  }) {
    return _then(_value.copyWith(
      isPanning: null == isPanning
          ? _value.isPanning
          : isPanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelecting: null == isSelecting
          ? _value.isSelecting
          : isSelecting // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: freezed == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      hoveredNodeId: freezed == hoveredNodeId
          ? _value.hoveredNodeId
          : hoveredNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GestureStateImplCopyWith<$Res>
    implements $GestureStateCopyWith<$Res> {
  factory _$$GestureStateImplCopyWith(
          _$GestureStateImpl value, $Res Function(_$GestureStateImpl) then) =
      __$$GestureStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPanning,
      bool isDragging,
      bool isSelecting,
      @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
      Offset? currentPosition,
      String? hoveredNodeId});
}

/// @nodoc
class __$$GestureStateImplCopyWithImpl<$Res>
    extends _$GestureStateCopyWithImpl<$Res, _$GestureStateImpl>
    implements _$$GestureStateImplCopyWith<$Res> {
  __$$GestureStateImplCopyWithImpl(
      _$GestureStateImpl _value, $Res Function(_$GestureStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPanning = null,
    Object? isDragging = null,
    Object? isSelecting = null,
    Object? currentPosition = freezed,
    Object? hoveredNodeId = freezed,
  }) {
    return _then(_$GestureStateImpl(
      isPanning: null == isPanning
          ? _value.isPanning
          : isPanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelecting: null == isSelecting
          ? _value.isSelecting
          : isSelecting // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: freezed == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      hoveredNodeId: freezed == hoveredNodeId
          ? _value.hoveredNodeId
          : hoveredNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GestureStateImpl with DiagnosticableTreeMixin implements _GestureState {
  const _$GestureStateImpl(
      {required this.isPanning,
      required this.isDragging,
      required this.isSelecting,
      @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
      this.currentPosition,
      this.hoveredNodeId});

  factory _$GestureStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GestureStateImplFromJson(json);

  @override
  final bool isPanning;
  @override
  final bool isDragging;
  @override
  final bool isSelecting;
  @override
  @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
  final Offset? currentPosition;
  @override
  final String? hoveredNodeId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureState(isPanning: $isPanning, isDragging: $isDragging, isSelecting: $isSelecting, currentPosition: $currentPosition, hoveredNodeId: $hoveredNodeId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GestureState'))
      ..add(DiagnosticsProperty('isPanning', isPanning))
      ..add(DiagnosticsProperty('isDragging', isDragging))
      ..add(DiagnosticsProperty('isSelecting', isSelecting))
      ..add(DiagnosticsProperty('currentPosition', currentPosition))
      ..add(DiagnosticsProperty('hoveredNodeId', hoveredNodeId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GestureStateImpl &&
            (identical(other.isPanning, isPanning) ||
                other.isPanning == isPanning) &&
            (identical(other.isDragging, isDragging) ||
                other.isDragging == isDragging) &&
            (identical(other.isSelecting, isSelecting) ||
                other.isSelecting == isSelecting) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.hoveredNodeId, hoveredNodeId) ||
                other.hoveredNodeId == hoveredNodeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isPanning, isDragging,
      isSelecting, currentPosition, hoveredNodeId);

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GestureStateImplCopyWith<_$GestureStateImpl> get copyWith =>
      __$$GestureStateImplCopyWithImpl<_$GestureStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GestureStateImplToJson(
      this,
    );
  }
}

abstract class _GestureState implements GestureState {
  const factory _GestureState(
      {required final bool isPanning,
      required final bool isDragging,
      required final bool isSelecting,
      @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
      final Offset? currentPosition,
      final String? hoveredNodeId}) = _$GestureStateImpl;

  factory _GestureState.fromJson(Map<String, dynamic> json) =
      _$GestureStateImpl.fromJson;

  @override
  bool get isPanning;
  @override
  bool get isDragging;
  @override
  bool get isSelecting;
  @override
  @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
  Offset? get currentPosition;
  @override
  String? get hoveredNodeId;

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GestureStateImplCopyWith<_$GestureStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GestureEvent _$GestureEventFromJson(Map<String, dynamic> json) {
  return _GestureEvent.fromJson(json);
}

/// @nodoc
mixin _$GestureEvent {
  DateTime get timestamp => throw _privateConstructorUsedError;
  GestureEventType get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
  Offset get position => throw _privateConstructorUsedError;
  bool get wasConsumed => throw _privateConstructorUsedError;
  String get callbackInvoked => throw _privateConstructorUsedError;
  String? get targetNodeId => throw _privateConstructorUsedError;
  String? get targetLinkId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this GestureEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GestureEventCopyWith<GestureEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GestureEventCopyWith<$Res> {
  factory $GestureEventCopyWith(
          GestureEvent value, $Res Function(GestureEvent) then) =
      _$GestureEventCopyWithImpl<$Res, GestureEvent>;
  @useResult
  $Res call(
      {DateTime timestamp,
      GestureEventType type,
      @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson) Offset position,
      bool wasConsumed,
      String callbackInvoked,
      String? targetNodeId,
      String? targetLinkId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$GestureEventCopyWithImpl<$Res, $Val extends GestureEvent>
    implements $GestureEventCopyWith<$Res> {
  _$GestureEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? type = null,
    Object? position = null,
    Object? wasConsumed = null,
    Object? callbackInvoked = null,
    Object? targetNodeId = freezed,
    Object? targetLinkId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GestureEventType,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      wasConsumed: null == wasConsumed
          ? _value.wasConsumed
          : wasConsumed // ignore: cast_nullable_to_non_nullable
              as bool,
      callbackInvoked: null == callbackInvoked
          ? _value.callbackInvoked
          : callbackInvoked // ignore: cast_nullable_to_non_nullable
              as String,
      targetNodeId: freezed == targetNodeId
          ? _value.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetLinkId: freezed == targetLinkId
          ? _value.targetLinkId
          : targetLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GestureEventImplCopyWith<$Res>
    implements $GestureEventCopyWith<$Res> {
  factory _$$GestureEventImplCopyWith(
          _$GestureEventImpl value, $Res Function(_$GestureEventImpl) then) =
      __$$GestureEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      GestureEventType type,
      @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson) Offset position,
      bool wasConsumed,
      String callbackInvoked,
      String? targetNodeId,
      String? targetLinkId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$GestureEventImplCopyWithImpl<$Res>
    extends _$GestureEventCopyWithImpl<$Res, _$GestureEventImpl>
    implements _$$GestureEventImplCopyWith<$Res> {
  __$$GestureEventImplCopyWithImpl(
      _$GestureEventImpl _value, $Res Function(_$GestureEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? type = null,
    Object? position = null,
    Object? wasConsumed = null,
    Object? callbackInvoked = null,
    Object? targetNodeId = freezed,
    Object? targetLinkId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$GestureEventImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GestureEventType,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      wasConsumed: null == wasConsumed
          ? _value.wasConsumed
          : wasConsumed // ignore: cast_nullable_to_non_nullable
              as bool,
      callbackInvoked: null == callbackInvoked
          ? _value.callbackInvoked
          : callbackInvoked // ignore: cast_nullable_to_non_nullable
              as String,
      targetNodeId: freezed == targetNodeId
          ? _value.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetLinkId: freezed == targetLinkId
          ? _value.targetLinkId
          : targetLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GestureEventImpl with DiagnosticableTreeMixin implements _GestureEvent {
  const _$GestureEventImpl(
      {required this.timestamp,
      required this.type,
      @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
      required this.position,
      required this.wasConsumed,
      required this.callbackInvoked,
      this.targetNodeId,
      this.targetLinkId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$GestureEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GestureEventImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final GestureEventType type;
  @override
  @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
  final Offset position;
  @override
  final bool wasConsumed;
  @override
  final String callbackInvoked;
  @override
  final String? targetNodeId;
  @override
  final String? targetLinkId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureEvent(timestamp: $timestamp, type: $type, position: $position, wasConsumed: $wasConsumed, callbackInvoked: $callbackInvoked, targetNodeId: $targetNodeId, targetLinkId: $targetLinkId, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GestureEvent'))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('wasConsumed', wasConsumed))
      ..add(DiagnosticsProperty('callbackInvoked', callbackInvoked))
      ..add(DiagnosticsProperty('targetNodeId', targetNodeId))
      ..add(DiagnosticsProperty('targetLinkId', targetLinkId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GestureEventImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.wasConsumed, wasConsumed) ||
                other.wasConsumed == wasConsumed) &&
            (identical(other.callbackInvoked, callbackInvoked) ||
                other.callbackInvoked == callbackInvoked) &&
            (identical(other.targetNodeId, targetNodeId) ||
                other.targetNodeId == targetNodeId) &&
            (identical(other.targetLinkId, targetLinkId) ||
                other.targetLinkId == targetLinkId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      type,
      position,
      wasConsumed,
      callbackInvoked,
      targetNodeId,
      targetLinkId,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GestureEventImplCopyWith<_$GestureEventImpl> get copyWith =>
      __$$GestureEventImplCopyWithImpl<_$GestureEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GestureEventImplToJson(
      this,
    );
  }
}

abstract class _GestureEvent implements GestureEvent {
  const factory _GestureEvent(
      {required final DateTime timestamp,
      required final GestureEventType type,
      @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
      required final Offset position,
      required final bool wasConsumed,
      required final String callbackInvoked}) = _$GestureEventImpl;

  factory _GestureEvent.fromJson(Map<String, dynamic> json) =
      _$GestureEventImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  GestureEventType get type;
  @override
  @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
  Offset get position;
  @override
  bool get wasConsumed;
  @override
  String get callbackInvoked;
  @override
  String? get targetNodeId;
  @override
  String? get targetLinkId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GestureEventImplCopyWith<_$GestureEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RenderEvent _$RenderEventFromJson(Map<String, dynamic> json) {
  return _RenderEvent.fromJson(json);
}

/// @nodoc
mixin _$RenderEvent {
  DateTime get timestamp => throw _privateConstructorUsedError;
  RenderPhase get phase => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  int get affectedNodes => throw _privateConstructorUsedError;
  String get trigger => throw _privateConstructorUsedError;
  String? get stackTrace => throw _privateConstructorUsedError;

  /// Serializes this RenderEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RenderEventCopyWith<RenderEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RenderEventCopyWith<$Res> {
  factory $RenderEventCopyWith(
          RenderEvent value, $Res Function(RenderEvent) then) =
      _$RenderEventCopyWithImpl<$Res, RenderEvent>;
  @useResult
  $Res call(
      {DateTime timestamp,
      RenderPhase phase,
      Duration duration,
      int affectedNodes,
      String trigger,
      String? stackTrace});
}

/// @nodoc
class _$RenderEventCopyWithImpl<$Res, $Val extends RenderEvent>
    implements $RenderEventCopyWith<$Res> {
  _$RenderEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? phase = null,
    Object? duration = null,
    Object? affectedNodes = null,
    Object? trigger = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as RenderPhase,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      affectedNodes: null == affectedNodes
          ? _value.affectedNodes
          : affectedNodes // ignore: cast_nullable_to_non_nullable
              as int,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RenderEventImplCopyWith<$Res>
    implements $RenderEventCopyWith<$Res> {
  factory _$$RenderEventImplCopyWith(
          _$RenderEventImpl value, $Res Function(_$RenderEventImpl) then) =
      __$$RenderEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      RenderPhase phase,
      Duration duration,
      int affectedNodes,
      String trigger,
      String? stackTrace});
}

/// @nodoc
class __$$RenderEventImplCopyWithImpl<$Res>
    extends _$RenderEventCopyWithImpl<$Res, _$RenderEventImpl>
    implements _$$RenderEventImplCopyWith<$Res> {
  __$$RenderEventImplCopyWithImpl(
      _$RenderEventImpl _value, $Res Function(_$RenderEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? phase = null,
    Object? duration = null,
    Object? affectedNodes = null,
    Object? trigger = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_$RenderEventImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as RenderPhase,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      affectedNodes: null == affectedNodes
          ? _value.affectedNodes
          : affectedNodes // ignore: cast_nullable_to_non_nullable
              as int,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RenderEventImpl with DiagnosticableTreeMixin implements _RenderEvent {
  const _$RenderEventImpl(
      {required this.timestamp,
      required this.phase,
      required this.duration,
      required this.affectedNodes,
      required this.trigger,
      this.stackTrace});

  factory _$RenderEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$RenderEventImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final RenderPhase phase;
  @override
  final Duration duration;
  @override
  final int affectedNodes;
  @override
  final String trigger;
  @override
  final String? stackTrace;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RenderEvent(timestamp: $timestamp, phase: $phase, duration: $duration, affectedNodes: $affectedNodes, trigger: $trigger, stackTrace: $stackTrace)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RenderEvent'))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('phase', phase))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('affectedNodes', affectedNodes))
      ..add(DiagnosticsProperty('trigger', trigger))
      ..add(DiagnosticsProperty('stackTrace', stackTrace));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RenderEventImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.affectedNodes, affectedNodes) ||
                other.affectedNodes == affectedNodes) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, phase, duration,
      affectedNodes, trigger, stackTrace);

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RenderEventImplCopyWith<_$RenderEventImpl> get copyWith =>
      __$$RenderEventImplCopyWithImpl<_$RenderEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RenderEventImplToJson(
      this,
    );
  }
}

abstract class _RenderEvent implements RenderEvent {
  const factory _RenderEvent(
      {required final DateTime timestamp,
      required final RenderPhase phase,
      required final Duration duration,
      required final int affectedNodes,
      required final String trigger,
      final String? stackTrace}) = _$RenderEventImpl;

  factory _RenderEvent.fromJson(Map<String, dynamic> json) =
      _$RenderEventImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  RenderPhase get phase;
  @override
  Duration get duration;
  @override
  int get affectedNodes;
  @override
  String get trigger;
  @override
  String? get stackTrace;

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RenderEventImplCopyWith<_$RenderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StateChange _$StateChangeFromJson(Map<String, dynamic> json) {
  return _StateChange.fromJson(json);
}

/// @nodoc
mixin _$StateChange {
  DateTime get timestamp => throw _privateConstructorUsedError;
  StateChangeType get type => throw _privateConstructorUsedError;
  String get target => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  Map<String, dynamic>? get oldValue => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValue => throw _privateConstructorUsedError;
  String? get stackTrace => throw _privateConstructorUsedError;

  /// Serializes this StateChange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StateChangeCopyWith<StateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StateChangeCopyWith<$Res> {
  factory $StateChangeCopyWith(
          StateChange value, $Res Function(StateChange) then) =
      _$StateChangeCopyWithImpl<$Res, StateChange>;
  @useResult
  $Res call(
      {DateTime timestamp,
      StateChangeType type,
      String target,
      String source,
      Map<String, dynamic>? oldValue,
      Map<String, dynamic>? newValue,
      String? stackTrace});
}

/// @nodoc
class _$StateChangeCopyWithImpl<$Res, $Val extends StateChange>
    implements $StateChangeCopyWith<$Res> {
  _$StateChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? type = null,
    Object? target = null,
    Object? source = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StateChangeType,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      oldValue: freezed == oldValue
          ? _value.oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _value.newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StateChangeImplCopyWith<$Res>
    implements $StateChangeCopyWith<$Res> {
  factory _$$StateChangeImplCopyWith(
          _$StateChangeImpl value, $Res Function(_$StateChangeImpl) then) =
      __$$StateChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      StateChangeType type,
      String target,
      String source,
      Map<String, dynamic>? oldValue,
      Map<String, dynamic>? newValue,
      String? stackTrace});
}

/// @nodoc
class __$$StateChangeImplCopyWithImpl<$Res>
    extends _$StateChangeCopyWithImpl<$Res, _$StateChangeImpl>
    implements _$$StateChangeImplCopyWith<$Res> {
  __$$StateChangeImplCopyWithImpl(
      _$StateChangeImpl _value, $Res Function(_$StateChangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? type = null,
    Object? target = null,
    Object? source = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$StateChangeImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StateChangeType,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      oldValue: freezed == oldValue
          ? _value._oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _value._newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StateChangeImpl with DiagnosticableTreeMixin implements _StateChange {
  const _$StateChangeImpl(
      {required this.timestamp,
      required this.type,
      required this.target,
      required this.source,
      final Map<String, dynamic>? oldValue,
      final Map<String, dynamic>? newValue,
      this.stackTrace})
      : _oldValue = oldValue,
        _newValue = newValue;

  factory _$StateChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StateChangeImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final StateChangeType type;
  @override
  final String target;
  @override
  final String source;
  final Map<String, dynamic>? _oldValue;
  @override
  Map<String, dynamic>? get oldValue {
    final value = _oldValue;
    if (value == null) return null;
    if (_oldValue is EqualUnmodifiableMapView) return _oldValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValue;
  @override
  Map<String, dynamic>? get newValue {
    final value = _newValue;
    if (value == null) return null;
    if (_newValue is EqualUnmodifiableMapView) return _newValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? stackTrace;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'StateChange(timestamp: $timestamp, type: $type, target: $target, source: $source, oldValue: $oldValue, newValue: $newValue, stackTrace: $stackTrace)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'StateChange'))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('target', target))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('oldValue', oldValue))
      ..add(DiagnosticsProperty('newValue', newValue))
      ..add(DiagnosticsProperty('stackTrace', stackTrace));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StateChangeImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._oldValue, _oldValue) &&
            const DeepCollectionEquality().equals(other._newValue, _newValue) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      type,
      target,
      source,
      const DeepCollectionEquality().hash(_oldValue),
      const DeepCollectionEquality().hash(_newValue),
      stackTrace);

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StateChangeImplCopyWith<_$StateChangeImpl> get copyWith =>
      __$$StateChangeImplCopyWithImpl<_$StateChangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StateChangeImplToJson(
      this,
    );
  }
}

abstract class _StateChange implements StateChange {
  const factory _StateChange(
      {required final DateTime timestamp,
      required final StateChangeType type,
      required final String target,
      required final String source,
      final Map<String, dynamic>? oldValue,
      final Map<String, dynamic>? newValue,
      final String? stackTrace}) = _$StateChangeImpl;

  factory _StateChange.fromJson(Map<String, dynamic> json) =
      _$StateChangeImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  StateChangeType get type;
  @override
  String get target;
  @override
  String get source;
  @override
  Map<String, dynamic>? get oldValue;
  @override
  Map<String, dynamic>? get newValue;
  @override
  String? get stackTrace;

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StateChangeImplCopyWith<_$StateChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PerformanceMetrics _$PerformanceMetricsFromJson(Map<String, dynamic> json) {
  return _PerformanceMetrics.fromJson(json);
}

/// @nodoc
mixin _$PerformanceMetrics {
  double get averageFps => throw _privateConstructorUsedError;
  double get currentFps => throw _privateConstructorUsedError;
  int get droppedFrames => throw _privateConstructorUsedError;
  Duration get averageFrameTime => throw _privateConstructorUsedError;
  Duration get worstFrameTime => throw _privateConstructorUsedError;
  int get memoryUsageMB => throw _privateConstructorUsedError;
  DateTime get measurementStart => throw _privateConstructorUsedError;
  DateTime get measurementEnd => throw _privateConstructorUsedError;

  /// Serializes this PerformanceMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceMetricsCopyWith<$Res> {
  factory $PerformanceMetricsCopyWith(
          PerformanceMetrics value, $Res Function(PerformanceMetrics) then) =
      _$PerformanceMetricsCopyWithImpl<$Res, PerformanceMetrics>;
  @useResult
  $Res call(
      {double averageFps,
      double currentFps,
      int droppedFrames,
      Duration averageFrameTime,
      Duration worstFrameTime,
      int memoryUsageMB,
      DateTime measurementStart,
      DateTime measurementEnd});
}

/// @nodoc
class _$PerformanceMetricsCopyWithImpl<$Res, $Val extends PerformanceMetrics>
    implements $PerformanceMetricsCopyWith<$Res> {
  _$PerformanceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageFps = null,
    Object? currentFps = null,
    Object? droppedFrames = null,
    Object? averageFrameTime = null,
    Object? worstFrameTime = null,
    Object? memoryUsageMB = null,
    Object? measurementStart = null,
    Object? measurementEnd = null,
  }) {
    return _then(_value.copyWith(
      averageFps: null == averageFps
          ? _value.averageFps
          : averageFps // ignore: cast_nullable_to_non_nullable
              as double,
      currentFps: null == currentFps
          ? _value.currentFps
          : currentFps // ignore: cast_nullable_to_non_nullable
              as double,
      droppedFrames: null == droppedFrames
          ? _value.droppedFrames
          : droppedFrames // ignore: cast_nullable_to_non_nullable
              as int,
      averageFrameTime: null == averageFrameTime
          ? _value.averageFrameTime
          : averageFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      worstFrameTime: null == worstFrameTime
          ? _value.worstFrameTime
          : worstFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsageMB: null == memoryUsageMB
          ? _value.memoryUsageMB
          : memoryUsageMB // ignore: cast_nullable_to_non_nullable
              as int,
      measurementStart: null == measurementStart
          ? _value.measurementStart
          : measurementStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementEnd: null == measurementEnd
          ? _value.measurementEnd
          : measurementEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceMetricsImplCopyWith<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  factory _$$PerformanceMetricsImplCopyWith(_$PerformanceMetricsImpl value,
          $Res Function(_$PerformanceMetricsImpl) then) =
      __$$PerformanceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double averageFps,
      double currentFps,
      int droppedFrames,
      Duration averageFrameTime,
      Duration worstFrameTime,
      int memoryUsageMB,
      DateTime measurementStart,
      DateTime measurementEnd});
}

/// @nodoc
class __$$PerformanceMetricsImplCopyWithImpl<$Res>
    extends _$PerformanceMetricsCopyWithImpl<$Res, _$PerformanceMetricsImpl>
    implements _$$PerformanceMetricsImplCopyWith<$Res> {
  __$$PerformanceMetricsImplCopyWithImpl(_$PerformanceMetricsImpl _value,
      $Res Function(_$PerformanceMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageFps = null,
    Object? currentFps = null,
    Object? droppedFrames = null,
    Object? averageFrameTime = null,
    Object? worstFrameTime = null,
    Object? memoryUsageMB = null,
    Object? measurementStart = null,
    Object? measurementEnd = null,
  }) {
    return _then(_$PerformanceMetricsImpl(
      averageFps: null == averageFps
          ? _value.averageFps
          : averageFps // ignore: cast_nullable_to_non_nullable
              as double,
      currentFps: null == currentFps
          ? _value.currentFps
          : currentFps // ignore: cast_nullable_to_non_nullable
              as double,
      droppedFrames: null == droppedFrames
          ? _value.droppedFrames
          : droppedFrames // ignore: cast_nullable_to_non_nullable
              as int,
      averageFrameTime: null == averageFrameTime
          ? _value.averageFrameTime
          : averageFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      worstFrameTime: null == worstFrameTime
          ? _value.worstFrameTime
          : worstFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsageMB: null == memoryUsageMB
          ? _value.memoryUsageMB
          : memoryUsageMB // ignore: cast_nullable_to_non_nullable
              as int,
      measurementStart: null == measurementStart
          ? _value.measurementStart
          : measurementStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementEnd: null == measurementEnd
          ? _value.measurementEnd
          : measurementEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceMetricsImpl
    with DiagnosticableTreeMixin
    implements _PerformanceMetrics {
  const _$PerformanceMetricsImpl(
      {required this.averageFps,
      required this.currentFps,
      required this.droppedFrames,
      required this.averageFrameTime,
      required this.worstFrameTime,
      required this.memoryUsageMB,
      required this.measurementStart,
      required this.measurementEnd});

  factory _$PerformanceMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceMetricsImplFromJson(json);

  @override
  final double averageFps;
  @override
  final double currentFps;
  @override
  final int droppedFrames;
  @override
  final Duration averageFrameTime;
  @override
  final Duration worstFrameTime;
  @override
  final int memoryUsageMB;
  @override
  final DateTime measurementStart;
  @override
  final DateTime measurementEnd;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PerformanceMetrics(averageFps: $averageFps, currentFps: $currentFps, droppedFrames: $droppedFrames, averageFrameTime: $averageFrameTime, worstFrameTime: $worstFrameTime, memoryUsageMB: $memoryUsageMB, measurementStart: $measurementStart, measurementEnd: $measurementEnd)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PerformanceMetrics'))
      ..add(DiagnosticsProperty('averageFps', averageFps))
      ..add(DiagnosticsProperty('currentFps', currentFps))
      ..add(DiagnosticsProperty('droppedFrames', droppedFrames))
      ..add(DiagnosticsProperty('averageFrameTime', averageFrameTime))
      ..add(DiagnosticsProperty('worstFrameTime', worstFrameTime))
      ..add(DiagnosticsProperty('memoryUsageMB', memoryUsageMB))
      ..add(DiagnosticsProperty('measurementStart', measurementStart))
      ..add(DiagnosticsProperty('measurementEnd', measurementEnd));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceMetricsImpl &&
            (identical(other.averageFps, averageFps) ||
                other.averageFps == averageFps) &&
            (identical(other.currentFps, currentFps) ||
                other.currentFps == currentFps) &&
            (identical(other.droppedFrames, droppedFrames) ||
                other.droppedFrames == droppedFrames) &&
            (identical(other.averageFrameTime, averageFrameTime) ||
                other.averageFrameTime == averageFrameTime) &&
            (identical(other.worstFrameTime, worstFrameTime) ||
                other.worstFrameTime == worstFrameTime) &&
            (identical(other.memoryUsageMB, memoryUsageMB) ||
                other.memoryUsageMB == memoryUsageMB) &&
            (identical(other.measurementStart, measurementStart) ||
                other.measurementStart == measurementStart) &&
            (identical(other.measurementEnd, measurementEnd) ||
                other.measurementEnd == measurementEnd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      averageFps,
      currentFps,
      droppedFrames,
      averageFrameTime,
      worstFrameTime,
      memoryUsageMB,
      measurementStart,
      measurementEnd);

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceMetricsImplCopyWith<_$PerformanceMetricsImpl> get copyWith =>
      __$$PerformanceMetricsImplCopyWithImpl<_$PerformanceMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceMetricsImplToJson(
      this,
    );
  }
}

abstract class _PerformanceMetrics implements PerformanceMetrics {
  const factory _PerformanceMetrics(
      {required final double averageFps,
      required final double currentFps,
      required final int droppedFrames,
      required final Duration averageFrameTime,
      required final Duration worstFrameTime,
      required final int memoryUsageMB,
      required final DateTime measurementStart,
      required final DateTime measurementEnd}) = _$PerformanceMetricsImpl;

  factory _PerformanceMetrics.fromJson(Map<String, dynamic> json) =
      _$PerformanceMetricsImpl.fromJson;

  @override
  double get averageFps;
  @override
  double get currentFps;
  @override
  int get droppedFrames;
  @override
  Duration get averageFrameTime;
  @override
  Duration get worstFrameTime;
  @override
  int get memoryUsageMB;
  @override
  DateTime get measurementStart;
  @override
  DateTime get measurementEnd;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerformanceMetricsImplCopyWith<_$PerformanceMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
