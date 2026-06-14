// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphDiagnostics implements DiagnosticableTreeMixin {
  GraphSnapshot get snapshot;
  List<GestureEvent> get gestureHistory;
  List<RenderEvent> get renderHistory;
  List<StateChange> get stateChanges;
  PerformanceMetrics get performance;

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphDiagnosticsCopyWith<GraphDiagnostics> get copyWith =>
      _$GraphDiagnosticsCopyWithImpl<GraphDiagnostics>(
          this as GraphDiagnostics, _$identity);

  /// Serializes this GraphDiagnostics to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is GraphDiagnostics &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot) &&
            const DeepCollectionEquality()
                .equals(other.gestureHistory, gestureHistory) &&
            const DeepCollectionEquality()
                .equals(other.renderHistory, renderHistory) &&
            const DeepCollectionEquality()
                .equals(other.stateChanges, stateChanges) &&
            (identical(other.performance, performance) ||
                other.performance == performance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      snapshot,
      const DeepCollectionEquality().hash(gestureHistory),
      const DeepCollectionEquality().hash(renderHistory),
      const DeepCollectionEquality().hash(stateChanges),
      performance);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphDiagnostics(snapshot: $snapshot, gestureHistory: $gestureHistory, renderHistory: $renderHistory, stateChanges: $stateChanges, performance: $performance)';
  }
}

/// @nodoc
abstract mixin class $GraphDiagnosticsCopyWith<$Res> {
  factory $GraphDiagnosticsCopyWith(
          GraphDiagnostics value, $Res Function(GraphDiagnostics) _then) =
      _$GraphDiagnosticsCopyWithImpl;
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
class _$GraphDiagnosticsCopyWithImpl<$Res>
    implements $GraphDiagnosticsCopyWith<$Res> {
  _$GraphDiagnosticsCopyWithImpl(this._self, this._then);

  final GraphDiagnostics _self;
  final $Res Function(GraphDiagnostics) _then;

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
    return _then(_self.copyWith(
      snapshot: null == snapshot
          ? _self.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as GraphSnapshot,
      gestureHistory: null == gestureHistory
          ? _self.gestureHistory
          : gestureHistory // ignore: cast_nullable_to_non_nullable
              as List<GestureEvent>,
      renderHistory: null == renderHistory
          ? _self.renderHistory
          : renderHistory // ignore: cast_nullable_to_non_nullable
              as List<RenderEvent>,
      stateChanges: null == stateChanges
          ? _self.stateChanges
          : stateChanges // ignore: cast_nullable_to_non_nullable
              as List<StateChange>,
      performance: null == performance
          ? _self.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as PerformanceMetrics,
    ));
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphSnapshotCopyWith<$Res> get snapshot {
    return $GraphSnapshotCopyWith<$Res>(_self.snapshot, (value) {
      return _then(_self.copyWith(snapshot: value));
    });
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PerformanceMetricsCopyWith<$Res> get performance {
    return $PerformanceMetricsCopyWith<$Res>(_self.performance, (value) {
      return _then(_self.copyWith(performance: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphDiagnostics].
extension GraphDiagnosticsPatterns on GraphDiagnostics {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GraphDiagnostics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GraphDiagnostics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GraphDiagnostics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            GraphSnapshot snapshot,
            List<GestureEvent> gestureHistory,
            List<RenderEvent> renderHistory,
            List<StateChange> stateChanges,
            PerformanceMetrics performance)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics() when $default != null:
        return $default(_that.snapshot, _that.gestureHistory,
            _that.renderHistory, _that.stateChanges, _that.performance);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            GraphSnapshot snapshot,
            List<GestureEvent> gestureHistory,
            List<RenderEvent> renderHistory,
            List<StateChange> stateChanges,
            PerformanceMetrics performance)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics():
        return $default(_that.snapshot, _that.gestureHistory,
            _that.renderHistory, _that.stateChanges, _that.performance);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            GraphSnapshot snapshot,
            List<GestureEvent> gestureHistory,
            List<RenderEvent> renderHistory,
            List<StateChange> stateChanges,
            PerformanceMetrics performance)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDiagnostics() when $default != null:
        return $default(_that.snapshot, _that.gestureHistory,
            _that.renderHistory, _that.stateChanges, _that.performance);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GraphDiagnostics
    with DiagnosticableTreeMixin
    implements GraphDiagnostics {
  const _GraphDiagnostics(
      {required this.snapshot,
      required final List<GestureEvent> gestureHistory,
      required final List<RenderEvent> renderHistory,
      required final List<StateChange> stateChanges,
      required this.performance})
      : _gestureHistory = gestureHistory,
        _renderHistory = renderHistory,
        _stateChanges = stateChanges;
  factory _GraphDiagnostics.fromJson(Map<String, dynamic> json) =>
      _$GraphDiagnosticsFromJson(json);

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

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphDiagnosticsCopyWith<_GraphDiagnostics> get copyWith =>
      __$GraphDiagnosticsCopyWithImpl<_GraphDiagnostics>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GraphDiagnosticsToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _GraphDiagnostics &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphDiagnostics(snapshot: $snapshot, gestureHistory: $gestureHistory, renderHistory: $renderHistory, stateChanges: $stateChanges, performance: $performance)';
  }
}

/// @nodoc
abstract mixin class _$GraphDiagnosticsCopyWith<$Res>
    implements $GraphDiagnosticsCopyWith<$Res> {
  factory _$GraphDiagnosticsCopyWith(
          _GraphDiagnostics value, $Res Function(_GraphDiagnostics) _then) =
      __$GraphDiagnosticsCopyWithImpl;
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
class __$GraphDiagnosticsCopyWithImpl<$Res>
    implements _$GraphDiagnosticsCopyWith<$Res> {
  __$GraphDiagnosticsCopyWithImpl(this._self, this._then);

  final _GraphDiagnostics _self;
  final $Res Function(_GraphDiagnostics) _then;

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? snapshot = null,
    Object? gestureHistory = null,
    Object? renderHistory = null,
    Object? stateChanges = null,
    Object? performance = null,
  }) {
    return _then(_GraphDiagnostics(
      snapshot: null == snapshot
          ? _self.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as GraphSnapshot,
      gestureHistory: null == gestureHistory
          ? _self._gestureHistory
          : gestureHistory // ignore: cast_nullable_to_non_nullable
              as List<GestureEvent>,
      renderHistory: null == renderHistory
          ? _self._renderHistory
          : renderHistory // ignore: cast_nullable_to_non_nullable
              as List<RenderEvent>,
      stateChanges: null == stateChanges
          ? _self._stateChanges
          : stateChanges // ignore: cast_nullable_to_non_nullable
              as List<StateChange>,
      performance: null == performance
          ? _self.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as PerformanceMetrics,
    ));
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphSnapshotCopyWith<$Res> get snapshot {
    return $GraphSnapshotCopyWith<$Res>(_self.snapshot, (value) {
      return _then(_self.copyWith(snapshot: value));
    });
  }

  /// Create a copy of GraphDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PerformanceMetricsCopyWith<$Res> get performance {
    return $PerformanceMetricsCopyWith<$Res>(_self.performance, (value) {
      return _then(_self.copyWith(performance: value));
    });
  }
}

/// @nodoc
mixin _$GraphSnapshot implements DiagnosticableTreeMixin {
  DateTime get timestamp;
  int get nodeCount;
  int get linkCount;
  Map<String, NodePosition> get nodePositions;
  LayoutMetrics get layoutMetrics;
  GestureState get currentGesture;
  String? get selectedNodeId;
  List<String>? get draggedNodeIds;

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphSnapshotCopyWith<GraphSnapshot> get copyWith =>
      _$GraphSnapshotCopyWithImpl<GraphSnapshot>(
          this as GraphSnapshot, _$identity);

  /// Serializes this GraphSnapshot to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is GraphSnapshot &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.nodeCount, nodeCount) ||
                other.nodeCount == nodeCount) &&
            (identical(other.linkCount, linkCount) ||
                other.linkCount == linkCount) &&
            const DeepCollectionEquality()
                .equals(other.nodePositions, nodePositions) &&
            (identical(other.layoutMetrics, layoutMetrics) ||
                other.layoutMetrics == layoutMetrics) &&
            (identical(other.currentGesture, currentGesture) ||
                other.currentGesture == currentGesture) &&
            (identical(other.selectedNodeId, selectedNodeId) ||
                other.selectedNodeId == selectedNodeId) &&
            const DeepCollectionEquality()
                .equals(other.draggedNodeIds, draggedNodeIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      nodeCount,
      linkCount,
      const DeepCollectionEquality().hash(nodePositions),
      layoutMetrics,
      currentGesture,
      selectedNodeId,
      const DeepCollectionEquality().hash(draggedNodeIds));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphSnapshot(timestamp: $timestamp, nodeCount: $nodeCount, linkCount: $linkCount, nodePositions: $nodePositions, layoutMetrics: $layoutMetrics, currentGesture: $currentGesture, selectedNodeId: $selectedNodeId, draggedNodeIds: $draggedNodeIds)';
  }
}

/// @nodoc
abstract mixin class $GraphSnapshotCopyWith<$Res> {
  factory $GraphSnapshotCopyWith(
          GraphSnapshot value, $Res Function(GraphSnapshot) _then) =
      _$GraphSnapshotCopyWithImpl;
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
class _$GraphSnapshotCopyWithImpl<$Res>
    implements $GraphSnapshotCopyWith<$Res> {
  _$GraphSnapshotCopyWithImpl(this._self, this._then);

  final GraphSnapshot _self;
  final $Res Function(GraphSnapshot) _then;

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
    return _then(_self.copyWith(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nodeCount: null == nodeCount
          ? _self.nodeCount
          : nodeCount // ignore: cast_nullable_to_non_nullable
              as int,
      linkCount: null == linkCount
          ? _self.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      nodePositions: null == nodePositions
          ? _self.nodePositions
          : nodePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, NodePosition>,
      layoutMetrics: null == layoutMetrics
          ? _self.layoutMetrics
          : layoutMetrics // ignore: cast_nullable_to_non_nullable
              as LayoutMetrics,
      currentGesture: null == currentGesture
          ? _self.currentGesture
          : currentGesture // ignore: cast_nullable_to_non_nullable
              as GestureState,
      selectedNodeId: freezed == selectedNodeId
          ? _self.selectedNodeId
          : selectedNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedNodeIds: freezed == draggedNodeIds
          ? _self.draggedNodeIds
          : draggedNodeIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutMetricsCopyWith<$Res> get layoutMetrics {
    return $LayoutMetricsCopyWith<$Res>(_self.layoutMetrics, (value) {
      return _then(_self.copyWith(layoutMetrics: value));
    });
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GestureStateCopyWith<$Res> get currentGesture {
    return $GestureStateCopyWith<$Res>(_self.currentGesture, (value) {
      return _then(_self.copyWith(currentGesture: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphSnapshot].
extension GraphSnapshotPatterns on GraphSnapshot {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GraphSnapshot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GraphSnapshot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GraphSnapshot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            int nodeCount,
            int linkCount,
            Map<String, NodePosition> nodePositions,
            LayoutMetrics layoutMetrics,
            GestureState currentGesture,
            String? selectedNodeId,
            List<String>? draggedNodeIds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot() when $default != null:
        return $default(
            _that.timestamp,
            _that.nodeCount,
            _that.linkCount,
            _that.nodePositions,
            _that.layoutMetrics,
            _that.currentGesture,
            _that.selectedNodeId,
            _that.draggedNodeIds);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            int nodeCount,
            int linkCount,
            Map<String, NodePosition> nodePositions,
            LayoutMetrics layoutMetrics,
            GestureState currentGesture,
            String? selectedNodeId,
            List<String>? draggedNodeIds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot():
        return $default(
            _that.timestamp,
            _that.nodeCount,
            _that.linkCount,
            _that.nodePositions,
            _that.layoutMetrics,
            _that.currentGesture,
            _that.selectedNodeId,
            _that.draggedNodeIds);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            DateTime timestamp,
            int nodeCount,
            int linkCount,
            Map<String, NodePosition> nodePositions,
            LayoutMetrics layoutMetrics,
            GestureState currentGesture,
            String? selectedNodeId,
            List<String>? draggedNodeIds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphSnapshot() when $default != null:
        return $default(
            _that.timestamp,
            _that.nodeCount,
            _that.linkCount,
            _that.nodePositions,
            _that.layoutMetrics,
            _that.currentGesture,
            _that.selectedNodeId,
            _that.draggedNodeIds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GraphSnapshot with DiagnosticableTreeMixin implements GraphSnapshot {
  const _GraphSnapshot(
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
  factory _GraphSnapshot.fromJson(Map<String, dynamic> json) =>
      _$GraphSnapshotFromJson(json);

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

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphSnapshotCopyWith<_GraphSnapshot> get copyWith =>
      __$GraphSnapshotCopyWithImpl<_GraphSnapshot>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GraphSnapshotToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _GraphSnapshot &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphSnapshot(timestamp: $timestamp, nodeCount: $nodeCount, linkCount: $linkCount, nodePositions: $nodePositions, layoutMetrics: $layoutMetrics, currentGesture: $currentGesture, selectedNodeId: $selectedNodeId, draggedNodeIds: $draggedNodeIds)';
  }
}

/// @nodoc
abstract mixin class _$GraphSnapshotCopyWith<$Res>
    implements $GraphSnapshotCopyWith<$Res> {
  factory _$GraphSnapshotCopyWith(
          _GraphSnapshot value, $Res Function(_GraphSnapshot) _then) =
      __$GraphSnapshotCopyWithImpl;
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
class __$GraphSnapshotCopyWithImpl<$Res>
    implements _$GraphSnapshotCopyWith<$Res> {
  __$GraphSnapshotCopyWithImpl(this._self, this._then);

  final _GraphSnapshot _self;
  final $Res Function(_GraphSnapshot) _then;

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_GraphSnapshot(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nodeCount: null == nodeCount
          ? _self.nodeCount
          : nodeCount // ignore: cast_nullable_to_non_nullable
              as int,
      linkCount: null == linkCount
          ? _self.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      nodePositions: null == nodePositions
          ? _self._nodePositions
          : nodePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, NodePosition>,
      layoutMetrics: null == layoutMetrics
          ? _self.layoutMetrics
          : layoutMetrics // ignore: cast_nullable_to_non_nullable
              as LayoutMetrics,
      currentGesture: null == currentGesture
          ? _self.currentGesture
          : currentGesture // ignore: cast_nullable_to_non_nullable
              as GestureState,
      selectedNodeId: freezed == selectedNodeId
          ? _self.selectedNodeId
          : selectedNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedNodeIds: freezed == draggedNodeIds
          ? _self._draggedNodeIds
          : draggedNodeIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutMetricsCopyWith<$Res> get layoutMetrics {
    return $LayoutMetricsCopyWith<$Res>(_self.layoutMetrics, (value) {
      return _then(_self.copyWith(layoutMetrics: value));
    });
  }

  /// Create a copy of GraphSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GestureStateCopyWith<$Res> get currentGesture {
    return $GestureStateCopyWith<$Res>(_self.currentGesture, (value) {
      return _then(_self.copyWith(currentGesture: value));
    });
  }
}

/// @nodoc
mixin _$NodePosition implements DiagnosticableTreeMixin {
  String get nodeId;
  double get x;
  double get y;
  bool get isFixed;
  bool? get isAnimating;

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NodePositionCopyWith<NodePosition> get copyWith =>
      _$NodePositionCopyWithImpl<NodePosition>(
          this as NodePosition, _$identity);

  /// Serializes this NodePosition to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is NodePosition &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NodePosition(nodeId: $nodeId, x: $x, y: $y, isFixed: $isFixed, isAnimating: $isAnimating)';
  }
}

/// @nodoc
abstract mixin class $NodePositionCopyWith<$Res> {
  factory $NodePositionCopyWith(
          NodePosition value, $Res Function(NodePosition) _then) =
      _$NodePositionCopyWithImpl;
  @useResult
  $Res call(
      {String nodeId, double x, double y, bool isFixed, bool? isAnimating});
}

/// @nodoc
class _$NodePositionCopyWithImpl<$Res> implements $NodePositionCopyWith<$Res> {
  _$NodePositionCopyWithImpl(this._self, this._then);

  final NodePosition _self;
  final $Res Function(NodePosition) _then;

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
    return _then(_self.copyWith(
      nodeId: null == nodeId
          ? _self.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      isFixed: null == isFixed
          ? _self.isFixed
          : isFixed // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnimating: freezed == isAnimating
          ? _self.isAnimating
          : isAnimating // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NodePosition].
extension NodePositionPatterns on NodePosition {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NodePosition value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NodePosition() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NodePosition value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodePosition():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NodePosition value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodePosition() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String nodeId, double x, double y, bool isFixed, bool? isAnimating)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NodePosition() when $default != null:
        return $default(
            _that.nodeId, _that.x, _that.y, _that.isFixed, _that.isAnimating);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String nodeId, double x, double y, bool isFixed, bool? isAnimating)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodePosition():
        return $default(
            _that.nodeId, _that.x, _that.y, _that.isFixed, _that.isAnimating);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String nodeId, double x, double y, bool isFixed, bool? isAnimating)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodePosition() when $default != null:
        return $default(
            _that.nodeId, _that.x, _that.y, _that.isFixed, _that.isAnimating);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NodePosition with DiagnosticableTreeMixin implements NodePosition {
  const _NodePosition(
      {required this.nodeId,
      required this.x,
      required this.y,
      required this.isFixed,
      this.isAnimating});
  factory _NodePosition.fromJson(Map<String, dynamic> json) =>
      _$NodePositionFromJson(json);

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

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NodePositionCopyWith<_NodePosition> get copyWith =>
      __$NodePositionCopyWithImpl<_NodePosition>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NodePositionToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _NodePosition &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NodePosition(nodeId: $nodeId, x: $x, y: $y, isFixed: $isFixed, isAnimating: $isAnimating)';
  }
}

/// @nodoc
abstract mixin class _$NodePositionCopyWith<$Res>
    implements $NodePositionCopyWith<$Res> {
  factory _$NodePositionCopyWith(
          _NodePosition value, $Res Function(_NodePosition) _then) =
      __$NodePositionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String nodeId, double x, double y, bool isFixed, bool? isAnimating});
}

/// @nodoc
class __$NodePositionCopyWithImpl<$Res>
    implements _$NodePositionCopyWith<$Res> {
  __$NodePositionCopyWithImpl(this._self, this._then);

  final _NodePosition _self;
  final $Res Function(_NodePosition) _then;

  /// Create a copy of NodePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nodeId = null,
    Object? x = null,
    Object? y = null,
    Object? isFixed = null,
    Object? isAnimating = freezed,
  }) {
    return _then(_NodePosition(
      nodeId: null == nodeId
          ? _self.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      isFixed: null == isFixed
          ? _self.isFixed
          : isFixed // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnimating: freezed == isAnimating
          ? _self.isAnimating
          : isAnimating // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
mixin _$LayoutMetrics implements DiagnosticableTreeMixin {
  String get strategy;
  Duration get lastCalculationTime;
  int get iterationCount;
  double get totalEnergy;
  @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
  Size get graphBounds;

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LayoutMetricsCopyWith<LayoutMetrics> get copyWith =>
      _$LayoutMetricsCopyWithImpl<LayoutMetrics>(
          this as LayoutMetrics, _$identity);

  /// Serializes this LayoutMetrics to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is LayoutMetrics &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LayoutMetrics(strategy: $strategy, lastCalculationTime: $lastCalculationTime, iterationCount: $iterationCount, totalEnergy: $totalEnergy, graphBounds: $graphBounds)';
  }
}

/// @nodoc
abstract mixin class $LayoutMetricsCopyWith<$Res> {
  factory $LayoutMetricsCopyWith(
          LayoutMetrics value, $Res Function(LayoutMetrics) _then) =
      _$LayoutMetricsCopyWithImpl;
  @useResult
  $Res call(
      {String strategy,
      Duration lastCalculationTime,
      int iterationCount,
      double totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson) Size graphBounds});
}

/// @nodoc
class _$LayoutMetricsCopyWithImpl<$Res>
    implements $LayoutMetricsCopyWith<$Res> {
  _$LayoutMetricsCopyWithImpl(this._self, this._then);

  final LayoutMetrics _self;
  final $Res Function(LayoutMetrics) _then;

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
    return _then(_self.copyWith(
      strategy: null == strategy
          ? _self.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as String,
      lastCalculationTime: null == lastCalculationTime
          ? _self.lastCalculationTime
          : lastCalculationTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      iterationCount: null == iterationCount
          ? _self.iterationCount
          : iterationCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnergy: null == totalEnergy
          ? _self.totalEnergy
          : totalEnergy // ignore: cast_nullable_to_non_nullable
              as double,
      graphBounds: null == graphBounds
          ? _self.graphBounds
          : graphBounds // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// Adds pattern-matching-related methods to [LayoutMetrics].
extension LayoutMetricsPatterns on LayoutMetrics {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LayoutMetrics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LayoutMetrics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LayoutMetrics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String strategy,
            Duration lastCalculationTime,
            int iterationCount,
            double totalEnergy,
            @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
            Size graphBounds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics() when $default != null:
        return $default(_that.strategy, _that.lastCalculationTime,
            _that.iterationCount, _that.totalEnergy, _that.graphBounds);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String strategy,
            Duration lastCalculationTime,
            int iterationCount,
            double totalEnergy,
            @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
            Size graphBounds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics():
        return $default(_that.strategy, _that.lastCalculationTime,
            _that.iterationCount, _that.totalEnergy, _that.graphBounds);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String strategy,
            Duration lastCalculationTime,
            int iterationCount,
            double totalEnergy,
            @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
            Size graphBounds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutMetrics() when $default != null:
        return $default(_that.strategy, _that.lastCalculationTime,
            _that.iterationCount, _that.totalEnergy, _that.graphBounds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LayoutMetrics with DiagnosticableTreeMixin implements LayoutMetrics {
  const _LayoutMetrics(
      {required this.strategy,
      required this.lastCalculationTime,
      required this.iterationCount,
      required this.totalEnergy,
      @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
      required this.graphBounds});
  factory _LayoutMetrics.fromJson(Map<String, dynamic> json) =>
      _$LayoutMetricsFromJson(json);

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

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LayoutMetricsCopyWith<_LayoutMetrics> get copyWith =>
      __$LayoutMetricsCopyWithImpl<_LayoutMetrics>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LayoutMetricsToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _LayoutMetrics &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LayoutMetrics(strategy: $strategy, lastCalculationTime: $lastCalculationTime, iterationCount: $iterationCount, totalEnergy: $totalEnergy, graphBounds: $graphBounds)';
  }
}

/// @nodoc
abstract mixin class _$LayoutMetricsCopyWith<$Res>
    implements $LayoutMetricsCopyWith<$Res> {
  factory _$LayoutMetricsCopyWith(
          _LayoutMetrics value, $Res Function(_LayoutMetrics) _then) =
      __$LayoutMetricsCopyWithImpl;
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
class __$LayoutMetricsCopyWithImpl<$Res>
    implements _$LayoutMetricsCopyWith<$Res> {
  __$LayoutMetricsCopyWithImpl(this._self, this._then);

  final _LayoutMetrics _self;
  final $Res Function(_LayoutMetrics) _then;

  /// Create a copy of LayoutMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? strategy = null,
    Object? lastCalculationTime = null,
    Object? iterationCount = null,
    Object? totalEnergy = null,
    Object? graphBounds = null,
  }) {
    return _then(_LayoutMetrics(
      strategy: null == strategy
          ? _self.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as String,
      lastCalculationTime: null == lastCalculationTime
          ? _self.lastCalculationTime
          : lastCalculationTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      iterationCount: null == iterationCount
          ? _self.iterationCount
          : iterationCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnergy: null == totalEnergy
          ? _self.totalEnergy
          : totalEnergy // ignore: cast_nullable_to_non_nullable
              as double,
      graphBounds: null == graphBounds
          ? _self.graphBounds
          : graphBounds // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// @nodoc
mixin _$GestureState implements DiagnosticableTreeMixin {
  bool get isPanning;
  bool get isDragging;
  bool get isSelecting;
  @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
  Offset? get currentPosition;
  String? get hoveredNodeId;

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GestureStateCopyWith<GestureState> get copyWith =>
      _$GestureStateCopyWithImpl<GestureState>(
          this as GestureState, _$identity);

  /// Serializes this GestureState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is GestureState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureState(isPanning: $isPanning, isDragging: $isDragging, isSelecting: $isSelecting, currentPosition: $currentPosition, hoveredNodeId: $hoveredNodeId)';
  }
}

/// @nodoc
abstract mixin class $GestureStateCopyWith<$Res> {
  factory $GestureStateCopyWith(
          GestureState value, $Res Function(GestureState) _then) =
      _$GestureStateCopyWithImpl;
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
class _$GestureStateCopyWithImpl<$Res> implements $GestureStateCopyWith<$Res> {
  _$GestureStateCopyWithImpl(this._self, this._then);

  final GestureState _self;
  final $Res Function(GestureState) _then;

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
    return _then(_self.copyWith(
      isPanning: null == isPanning
          ? _self.isPanning
          : isPanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isDragging: null == isDragging
          ? _self.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelecting: null == isSelecting
          ? _self.isSelecting
          : isSelecting // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: freezed == currentPosition
          ? _self.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      hoveredNodeId: freezed == hoveredNodeId
          ? _self.hoveredNodeId
          : hoveredNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GestureState].
extension GestureStatePatterns on GestureState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GestureState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GestureState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GestureState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GestureState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool isPanning,
            bool isDragging,
            bool isSelecting,
            @JsonKey(
                fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
            Offset? currentPosition,
            String? hoveredNodeId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GestureState() when $default != null:
        return $default(_that.isPanning, _that.isDragging, _that.isSelecting,
            _that.currentPosition, _that.hoveredNodeId);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            bool isPanning,
            bool isDragging,
            bool isSelecting,
            @JsonKey(
                fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
            Offset? currentPosition,
            String? hoveredNodeId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureState():
        return $default(_that.isPanning, _that.isDragging, _that.isSelecting,
            _that.currentPosition, _that.hoveredNodeId);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool isPanning,
            bool isDragging,
            bool isSelecting,
            @JsonKey(
                fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
            Offset? currentPosition,
            String? hoveredNodeId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureState() when $default != null:
        return $default(_that.isPanning, _that.isDragging, _that.isSelecting,
            _that.currentPosition, _that.hoveredNodeId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GestureState with DiagnosticableTreeMixin implements GestureState {
  const _GestureState(
      {required this.isPanning,
      required this.isDragging,
      required this.isSelecting,
      @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
      this.currentPosition,
      this.hoveredNodeId});
  factory _GestureState.fromJson(Map<String, dynamic> json) =>
      _$GestureStateFromJson(json);

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

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GestureStateCopyWith<_GestureState> get copyWith =>
      __$GestureStateCopyWithImpl<_GestureState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GestureStateToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _GestureState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureState(isPanning: $isPanning, isDragging: $isDragging, isSelecting: $isSelecting, currentPosition: $currentPosition, hoveredNodeId: $hoveredNodeId)';
  }
}

/// @nodoc
abstract mixin class _$GestureStateCopyWith<$Res>
    implements $GestureStateCopyWith<$Res> {
  factory _$GestureStateCopyWith(
          _GestureState value, $Res Function(_GestureState) _then) =
      __$GestureStateCopyWithImpl;
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
class __$GestureStateCopyWithImpl<$Res>
    implements _$GestureStateCopyWith<$Res> {
  __$GestureStateCopyWithImpl(this._self, this._then);

  final _GestureState _self;
  final $Res Function(_GestureState) _then;

  /// Create a copy of GestureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isPanning = null,
    Object? isDragging = null,
    Object? isSelecting = null,
    Object? currentPosition = freezed,
    Object? hoveredNodeId = freezed,
  }) {
    return _then(_GestureState(
      isPanning: null == isPanning
          ? _self.isPanning
          : isPanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isDragging: null == isDragging
          ? _self.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelecting: null == isSelecting
          ? _self.isSelecting
          : isSelecting // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPosition: freezed == currentPosition
          ? _self.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      hoveredNodeId: freezed == hoveredNodeId
          ? _self.hoveredNodeId
          : hoveredNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$GestureEvent implements DiagnosticableTreeMixin {
  DateTime get timestamp;
  GestureEventType get type;
  @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
  Offset get position;
  bool get wasConsumed;
  String get callbackInvoked;
  String? get targetNodeId;
  String? get targetLinkId;
  Map<String, dynamic>? get metadata;

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GestureEventCopyWith<GestureEvent> get copyWith =>
      _$GestureEventCopyWithImpl<GestureEvent>(
          this as GestureEvent, _$identity);

  /// Serializes this GestureEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is GestureEvent &&
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
            const DeepCollectionEquality().equals(other.metadata, metadata));
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
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureEvent(timestamp: $timestamp, type: $type, position: $position, wasConsumed: $wasConsumed, callbackInvoked: $callbackInvoked, targetNodeId: $targetNodeId, targetLinkId: $targetLinkId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $GestureEventCopyWith<$Res> {
  factory $GestureEventCopyWith(
          GestureEvent value, $Res Function(GestureEvent) _then) =
      _$GestureEventCopyWithImpl;
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
class _$GestureEventCopyWithImpl<$Res> implements $GestureEventCopyWith<$Res> {
  _$GestureEventCopyWithImpl(this._self, this._then);

  final GestureEvent _self;
  final $Res Function(GestureEvent) _then;

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
    return _then(_self.copyWith(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as GestureEventType,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      wasConsumed: null == wasConsumed
          ? _self.wasConsumed
          : wasConsumed // ignore: cast_nullable_to_non_nullable
              as bool,
      callbackInvoked: null == callbackInvoked
          ? _self.callbackInvoked
          : callbackInvoked // ignore: cast_nullable_to_non_nullable
              as String,
      targetNodeId: freezed == targetNodeId
          ? _self.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetLinkId: freezed == targetLinkId
          ? _self.targetLinkId
          : targetLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GestureEvent].
extension GestureEventPatterns on GestureEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GestureEvent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GestureEvent() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GestureEvent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureEvent():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GestureEvent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureEvent() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            GestureEventType type,
            @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
            Offset position,
            bool wasConsumed,
            String callbackInvoked,
            String? targetNodeId,
            String? targetLinkId,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GestureEvent() when $default != null:
        return $default(
            _that.timestamp,
            _that.type,
            _that.position,
            _that.wasConsumed,
            _that.callbackInvoked,
            _that.targetNodeId,
            _that.targetLinkId,
            _that.metadata);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            GestureEventType type,
            @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
            Offset position,
            bool wasConsumed,
            String callbackInvoked,
            String? targetNodeId,
            String? targetLinkId,
            Map<String, dynamic>? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureEvent():
        return $default(
            _that.timestamp,
            _that.type,
            _that.position,
            _that.wasConsumed,
            _that.callbackInvoked,
            _that.targetNodeId,
            _that.targetLinkId,
            _that.metadata);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            DateTime timestamp,
            GestureEventType type,
            @JsonKey(fromJson: offsetFromJson, toJson: offsetToJson)
            Offset position,
            bool wasConsumed,
            String callbackInvoked,
            String? targetNodeId,
            String? targetLinkId,
            Map<String, dynamic>? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GestureEvent() when $default != null:
        return $default(
            _that.timestamp,
            _that.type,
            _that.position,
            _that.wasConsumed,
            _that.callbackInvoked,
            _that.targetNodeId,
            _that.targetLinkId,
            _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GestureEvent with DiagnosticableTreeMixin implements GestureEvent {
  const _GestureEvent(
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
  factory _GestureEvent.fromJson(Map<String, dynamic> json) =>
      _$GestureEventFromJson(json);

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

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GestureEventCopyWith<_GestureEvent> get copyWith =>
      __$GestureEventCopyWithImpl<_GestureEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GestureEventToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _GestureEvent &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GestureEvent(timestamp: $timestamp, type: $type, position: $position, wasConsumed: $wasConsumed, callbackInvoked: $callbackInvoked, targetNodeId: $targetNodeId, targetLinkId: $targetLinkId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$GestureEventCopyWith<$Res>
    implements $GestureEventCopyWith<$Res> {
  factory _$GestureEventCopyWith(
          _GestureEvent value, $Res Function(_GestureEvent) _then) =
      __$GestureEventCopyWithImpl;
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
class __$GestureEventCopyWithImpl<$Res>
    implements _$GestureEventCopyWith<$Res> {
  __$GestureEventCopyWithImpl(this._self, this._then);

  final _GestureEvent _self;
  final $Res Function(_GestureEvent) _then;

  /// Create a copy of GestureEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_GestureEvent(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as GestureEventType,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      wasConsumed: null == wasConsumed
          ? _self.wasConsumed
          : wasConsumed // ignore: cast_nullable_to_non_nullable
              as bool,
      callbackInvoked: null == callbackInvoked
          ? _self.callbackInvoked
          : callbackInvoked // ignore: cast_nullable_to_non_nullable
              as String,
      targetNodeId: freezed == targetNodeId
          ? _self.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetLinkId: freezed == targetLinkId
          ? _self.targetLinkId
          : targetLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$RenderEvent implements DiagnosticableTreeMixin {
  DateTime get timestamp;
  RenderPhase get phase;
  Duration get duration;
  int get affectedNodes;
  String get trigger;
  String? get stackTrace;

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RenderEventCopyWith<RenderEvent> get copyWith =>
      _$RenderEventCopyWithImpl<RenderEvent>(this as RenderEvent, _$identity);

  /// Serializes this RenderEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is RenderEvent &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RenderEvent(timestamp: $timestamp, phase: $phase, duration: $duration, affectedNodes: $affectedNodes, trigger: $trigger, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $RenderEventCopyWith<$Res> {
  factory $RenderEventCopyWith(
          RenderEvent value, $Res Function(RenderEvent) _then) =
      _$RenderEventCopyWithImpl;
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
class _$RenderEventCopyWithImpl<$Res> implements $RenderEventCopyWith<$Res> {
  _$RenderEventCopyWithImpl(this._self, this._then);

  final RenderEvent _self;
  final $Res Function(RenderEvent) _then;

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
    return _then(_self.copyWith(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _self.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as RenderPhase,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      affectedNodes: null == affectedNodes
          ? _self.affectedNodes
          : affectedNodes // ignore: cast_nullable_to_non_nullable
              as int,
      trigger: null == trigger
          ? _self.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RenderEvent].
extension RenderEventPatterns on RenderEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RenderEvent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RenderEvent() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RenderEvent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RenderEvent():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RenderEvent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RenderEvent() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DateTime timestamp, RenderPhase phase, Duration duration,
            int affectedNodes, String trigger, String? stackTrace)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RenderEvent() when $default != null:
        return $default(_that.timestamp, _that.phase, _that.duration,
            _that.affectedNodes, _that.trigger, _that.stackTrace);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(DateTime timestamp, RenderPhase phase, Duration duration,
            int affectedNodes, String trigger, String? stackTrace)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RenderEvent():
        return $default(_that.timestamp, _that.phase, _that.duration,
            _that.affectedNodes, _that.trigger, _that.stackTrace);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DateTime timestamp, RenderPhase phase, Duration duration,
            int affectedNodes, String trigger, String? stackTrace)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RenderEvent() when $default != null:
        return $default(_that.timestamp, _that.phase, _that.duration,
            _that.affectedNodes, _that.trigger, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RenderEvent with DiagnosticableTreeMixin implements RenderEvent {
  const _RenderEvent(
      {required this.timestamp,
      required this.phase,
      required this.duration,
      required this.affectedNodes,
      required this.trigger,
      this.stackTrace});
  factory _RenderEvent.fromJson(Map<String, dynamic> json) =>
      _$RenderEventFromJson(json);

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

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RenderEventCopyWith<_RenderEvent> get copyWith =>
      __$RenderEventCopyWithImpl<_RenderEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RenderEventToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _RenderEvent &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RenderEvent(timestamp: $timestamp, phase: $phase, duration: $duration, affectedNodes: $affectedNodes, trigger: $trigger, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class _$RenderEventCopyWith<$Res>
    implements $RenderEventCopyWith<$Res> {
  factory _$RenderEventCopyWith(
          _RenderEvent value, $Res Function(_RenderEvent) _then) =
      __$RenderEventCopyWithImpl;
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
class __$RenderEventCopyWithImpl<$Res> implements _$RenderEventCopyWith<$Res> {
  __$RenderEventCopyWithImpl(this._self, this._then);

  final _RenderEvent _self;
  final $Res Function(_RenderEvent) _then;

  /// Create a copy of RenderEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? timestamp = null,
    Object? phase = null,
    Object? duration = null,
    Object? affectedNodes = null,
    Object? trigger = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_RenderEvent(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _self.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as RenderPhase,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      affectedNodes: null == affectedNodes
          ? _self.affectedNodes
          : affectedNodes // ignore: cast_nullable_to_non_nullable
              as int,
      trigger: null == trigger
          ? _self.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$StateChange implements DiagnosticableTreeMixin {
  DateTime get timestamp;
  StateChangeType get type;
  String get target;
  String get source;
  Map<String, dynamic>? get oldValue;
  Map<String, dynamic>? get newValue;
  String? get stackTrace;

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StateChangeCopyWith<StateChange> get copyWith =>
      _$StateChangeCopyWithImpl<StateChange>(this as StateChange, _$identity);

  /// Serializes this StateChange to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is StateChange &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other.oldValue, oldValue) &&
            const DeepCollectionEquality().equals(other.newValue, newValue) &&
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
      const DeepCollectionEquality().hash(oldValue),
      const DeepCollectionEquality().hash(newValue),
      stackTrace);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'StateChange(timestamp: $timestamp, type: $type, target: $target, source: $source, oldValue: $oldValue, newValue: $newValue, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $StateChangeCopyWith<$Res> {
  factory $StateChangeCopyWith(
          StateChange value, $Res Function(StateChange) _then) =
      _$StateChangeCopyWithImpl;
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
class _$StateChangeCopyWithImpl<$Res> implements $StateChangeCopyWith<$Res> {
  _$StateChangeCopyWithImpl(this._self, this._then);

  final StateChange _self;
  final $Res Function(StateChange) _then;

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
    return _then(_self.copyWith(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StateChangeType,
      target: null == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      oldValue: freezed == oldValue
          ? _self.oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _self.newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [StateChange].
extension StateChangePatterns on StateChange {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StateChange value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StateChange() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StateChange value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StateChange():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StateChange value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StateChange() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            StateChangeType type,
            String target,
            String source,
            Map<String, dynamic>? oldValue,
            Map<String, dynamic>? newValue,
            String? stackTrace)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StateChange() when $default != null:
        return $default(_that.timestamp, _that.type, _that.target, _that.source,
            _that.oldValue, _that.newValue, _that.stackTrace);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            DateTime timestamp,
            StateChangeType type,
            String target,
            String source,
            Map<String, dynamic>? oldValue,
            Map<String, dynamic>? newValue,
            String? stackTrace)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StateChange():
        return $default(_that.timestamp, _that.type, _that.target, _that.source,
            _that.oldValue, _that.newValue, _that.stackTrace);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            DateTime timestamp,
            StateChangeType type,
            String target,
            String source,
            Map<String, dynamic>? oldValue,
            Map<String, dynamic>? newValue,
            String? stackTrace)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StateChange() when $default != null:
        return $default(_that.timestamp, _that.type, _that.target, _that.source,
            _that.oldValue, _that.newValue, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StateChange with DiagnosticableTreeMixin implements StateChange {
  const _StateChange(
      {required this.timestamp,
      required this.type,
      required this.target,
      required this.source,
      final Map<String, dynamic>? oldValue,
      final Map<String, dynamic>? newValue,
      this.stackTrace})
      : _oldValue = oldValue,
        _newValue = newValue;
  factory _StateChange.fromJson(Map<String, dynamic> json) =>
      _$StateChangeFromJson(json);

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

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StateChangeCopyWith<_StateChange> get copyWith =>
      __$StateChangeCopyWithImpl<_StateChange>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StateChangeToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _StateChange &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'StateChange(timestamp: $timestamp, type: $type, target: $target, source: $source, oldValue: $oldValue, newValue: $newValue, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class _$StateChangeCopyWith<$Res>
    implements $StateChangeCopyWith<$Res> {
  factory _$StateChangeCopyWith(
          _StateChange value, $Res Function(_StateChange) _then) =
      __$StateChangeCopyWithImpl;
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
class __$StateChangeCopyWithImpl<$Res> implements _$StateChangeCopyWith<$Res> {
  __$StateChangeCopyWithImpl(this._self, this._then);

  final _StateChange _self;
  final $Res Function(_StateChange) _then;

  /// Create a copy of StateChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? timestamp = null,
    Object? type = null,
    Object? target = null,
    Object? source = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_StateChange(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StateChangeType,
      target: null == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      oldValue: freezed == oldValue
          ? _self._oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _self._newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$PerformanceMetrics implements DiagnosticableTreeMixin {
  double get averageFps;
  double get currentFps;
  int get droppedFrames;
  Duration get averageFrameTime;
  Duration get worstFrameTime;
  int get memoryUsageMB;
  DateTime get measurementStart;
  DateTime get measurementEnd;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith =>
      _$PerformanceMetricsCopyWithImpl<PerformanceMetrics>(
          this as PerformanceMetrics, _$identity);

  /// Serializes this PerformanceMetrics to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is PerformanceMetrics &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PerformanceMetrics(averageFps: $averageFps, currentFps: $currentFps, droppedFrames: $droppedFrames, averageFrameTime: $averageFrameTime, worstFrameTime: $worstFrameTime, memoryUsageMB: $memoryUsageMB, measurementStart: $measurementStart, measurementEnd: $measurementEnd)';
  }
}

/// @nodoc
abstract mixin class $PerformanceMetricsCopyWith<$Res> {
  factory $PerformanceMetricsCopyWith(
          PerformanceMetrics value, $Res Function(PerformanceMetrics) _then) =
      _$PerformanceMetricsCopyWithImpl;
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
class _$PerformanceMetricsCopyWithImpl<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  _$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final PerformanceMetrics _self;
  final $Res Function(PerformanceMetrics) _then;

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
    return _then(_self.copyWith(
      averageFps: null == averageFps
          ? _self.averageFps
          : averageFps // ignore: cast_nullable_to_non_nullable
              as double,
      currentFps: null == currentFps
          ? _self.currentFps
          : currentFps // ignore: cast_nullable_to_non_nullable
              as double,
      droppedFrames: null == droppedFrames
          ? _self.droppedFrames
          : droppedFrames // ignore: cast_nullable_to_non_nullable
              as int,
      averageFrameTime: null == averageFrameTime
          ? _self.averageFrameTime
          : averageFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      worstFrameTime: null == worstFrameTime
          ? _self.worstFrameTime
          : worstFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsageMB: null == memoryUsageMB
          ? _self.memoryUsageMB
          : memoryUsageMB // ignore: cast_nullable_to_non_nullable
              as int,
      measurementStart: null == measurementStart
          ? _self.measurementStart
          : measurementStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementEnd: null == measurementEnd
          ? _self.measurementEnd
          : measurementEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [PerformanceMetrics].
extension PerformanceMetricsPatterns on PerformanceMetrics {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PerformanceMetrics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PerformanceMetrics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PerformanceMetrics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            double averageFps,
            double currentFps,
            int droppedFrames,
            Duration averageFrameTime,
            Duration worstFrameTime,
            int memoryUsageMB,
            DateTime measurementStart,
            DateTime measurementEnd)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics() when $default != null:
        return $default(
            _that.averageFps,
            _that.currentFps,
            _that.droppedFrames,
            _that.averageFrameTime,
            _that.worstFrameTime,
            _that.memoryUsageMB,
            _that.measurementStart,
            _that.measurementEnd);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            double averageFps,
            double currentFps,
            int droppedFrames,
            Duration averageFrameTime,
            Duration worstFrameTime,
            int memoryUsageMB,
            DateTime measurementStart,
            DateTime measurementEnd)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics():
        return $default(
            _that.averageFps,
            _that.currentFps,
            _that.droppedFrames,
            _that.averageFrameTime,
            _that.worstFrameTime,
            _that.memoryUsageMB,
            _that.measurementStart,
            _that.measurementEnd);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double averageFps,
            double currentFps,
            int droppedFrames,
            Duration averageFrameTime,
            Duration worstFrameTime,
            int memoryUsageMB,
            DateTime measurementStart,
            DateTime measurementEnd)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerformanceMetrics() when $default != null:
        return $default(
            _that.averageFps,
            _that.currentFps,
            _that.droppedFrames,
            _that.averageFrameTime,
            _that.worstFrameTime,
            _that.memoryUsageMB,
            _that.measurementStart,
            _that.measurementEnd);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PerformanceMetrics
    with DiagnosticableTreeMixin
    implements PerformanceMetrics {
  const _PerformanceMetrics(
      {required this.averageFps,
      required this.currentFps,
      required this.droppedFrames,
      required this.averageFrameTime,
      required this.worstFrameTime,
      required this.memoryUsageMB,
      required this.measurementStart,
      required this.measurementEnd});
  factory _PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);

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

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PerformanceMetricsCopyWith<_PerformanceMetrics> get copyWith =>
      __$PerformanceMetricsCopyWithImpl<_PerformanceMetrics>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PerformanceMetricsToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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
            other is _PerformanceMetrics &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PerformanceMetrics(averageFps: $averageFps, currentFps: $currentFps, droppedFrames: $droppedFrames, averageFrameTime: $averageFrameTime, worstFrameTime: $worstFrameTime, memoryUsageMB: $memoryUsageMB, measurementStart: $measurementStart, measurementEnd: $measurementEnd)';
  }
}

/// @nodoc
abstract mixin class _$PerformanceMetricsCopyWith<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  factory _$PerformanceMetricsCopyWith(
          _PerformanceMetrics value, $Res Function(_PerformanceMetrics) _then) =
      __$PerformanceMetricsCopyWithImpl;
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
class __$PerformanceMetricsCopyWithImpl<$Res>
    implements _$PerformanceMetricsCopyWith<$Res> {
  __$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final _PerformanceMetrics _self;
  final $Res Function(_PerformanceMetrics) _then;

  /// Create a copy of PerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_PerformanceMetrics(
      averageFps: null == averageFps
          ? _self.averageFps
          : averageFps // ignore: cast_nullable_to_non_nullable
              as double,
      currentFps: null == currentFps
          ? _self.currentFps
          : currentFps // ignore: cast_nullable_to_non_nullable
              as double,
      droppedFrames: null == droppedFrames
          ? _self.droppedFrames
          : droppedFrames // ignore: cast_nullable_to_non_nullable
              as int,
      averageFrameTime: null == averageFrameTime
          ? _self.averageFrameTime
          : averageFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      worstFrameTime: null == worstFrameTime
          ? _self.worstFrameTime
          : worstFrameTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsageMB: null == memoryUsageMB
          ? _self.memoryUsageMB
          : memoryUsageMB // ignore: cast_nullable_to_non_nullable
              as int,
      measurementStart: null == measurementStart
          ? _self.measurementStart
          : measurementStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementEnd: null == measurementEnd
          ? _self.measurementEnd
          : measurementEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
