// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphViewData {
  /// The graph data model to be visualized
  Graph get graph;

  /// View interaction and rendering behaviors
  GraphViewBehavior get behavior;

  /// Strategy for positioning nodes, null disables automatic layout
  GraphLayoutStrategy? get layoutStrategy;

  /// Whether nodes and links can be selected
  bool get allowSelection;

  /// Whether multiple nodes and links can be selected simultaneously
  bool get allowMultiSelection;

  /// Whether position changes should be animated
  bool get animationEnabled;

  /// Starting position for node animations, null uses current position
  Offset? get nodeAnimationStartPosition;

  /// Duration of node movement animations
  Duration get nodeAnimationDuration;

  /// Animation curve for node movements
  Curve get nodeAnimationCurve;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphViewDataCopyWith<GraphViewData> get copyWith =>
      _$GraphViewDataCopyWithImpl<GraphViewData>(
          this as GraphViewData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphViewData &&
            (identical(other.graph, graph) || other.graph == graph) &&
            (identical(other.behavior, behavior) ||
                other.behavior == behavior) &&
            (identical(other.layoutStrategy, layoutStrategy) ||
                other.layoutStrategy == layoutStrategy) &&
            (identical(other.allowSelection, allowSelection) ||
                other.allowSelection == allowSelection) &&
            (identical(other.allowMultiSelection, allowMultiSelection) ||
                other.allowMultiSelection == allowMultiSelection) &&
            (identical(other.animationEnabled, animationEnabled) ||
                other.animationEnabled == animationEnabled) &&
            (identical(other.nodeAnimationStartPosition,
                    nodeAnimationStartPosition) ||
                other.nodeAnimationStartPosition ==
                    nodeAnimationStartPosition) &&
            (identical(other.nodeAnimationDuration, nodeAnimationDuration) ||
                other.nodeAnimationDuration == nodeAnimationDuration) &&
            (identical(other.nodeAnimationCurve, nodeAnimationCurve) ||
                other.nodeAnimationCurve == nodeAnimationCurve));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      graph,
      behavior,
      layoutStrategy,
      allowSelection,
      allowMultiSelection,
      animationEnabled,
      nodeAnimationStartPosition,
      nodeAnimationDuration,
      nodeAnimationCurve);

  @override
  String toString() {
    return 'GraphViewData(graph: $graph, behavior: $behavior, layoutStrategy: $layoutStrategy, allowSelection: $allowSelection, allowMultiSelection: $allowMultiSelection, animationEnabled: $animationEnabled, nodeAnimationStartPosition: $nodeAnimationStartPosition, nodeAnimationDuration: $nodeAnimationDuration, nodeAnimationCurve: $nodeAnimationCurve)';
  }
}

/// @nodoc
abstract mixin class $GraphViewDataCopyWith<$Res> {
  factory $GraphViewDataCopyWith(
          GraphViewData value, $Res Function(GraphViewData) _then) =
      _$GraphViewDataCopyWithImpl;
  @useResult
  $Res call(
      {Graph graph,
      GraphViewBehavior behavior,
      GraphLayoutStrategy? layoutStrategy,
      bool allowSelection,
      bool allowMultiSelection,
      bool animationEnabled,
      Offset? nodeAnimationStartPosition,
      Duration nodeAnimationDuration,
      Curve nodeAnimationCurve});
}

/// @nodoc
class _$GraphViewDataCopyWithImpl<$Res>
    implements $GraphViewDataCopyWith<$Res> {
  _$GraphViewDataCopyWithImpl(this._self, this._then);

  final GraphViewData _self;
  final $Res Function(GraphViewData) _then;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? graph = null,
    Object? behavior = null,
    Object? layoutStrategy = freezed,
    Object? allowSelection = null,
    Object? allowMultiSelection = null,
    Object? animationEnabled = null,
    Object? nodeAnimationStartPosition = freezed,
    Object? nodeAnimationDuration = null,
    Object? nodeAnimationCurve = null,
  }) {
    return _then(_self.copyWith(
      graph: null == graph
          ? _self.graph
          : graph // ignore: cast_nullable_to_non_nullable
              as Graph,
      behavior: null == behavior
          ? _self.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as GraphViewBehavior,
      layoutStrategy: freezed == layoutStrategy
          ? _self.layoutStrategy
          : layoutStrategy // ignore: cast_nullable_to_non_nullable
              as GraphLayoutStrategy?,
      allowSelection: null == allowSelection
          ? _self.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _self.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      animationEnabled: null == animationEnabled
          ? _self.animationEnabled
          : animationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      nodeAnimationStartPosition: freezed == nodeAnimationStartPosition
          ? _self.nodeAnimationStartPosition
          : nodeAnimationStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      nodeAnimationDuration: null == nodeAnimationDuration
          ? _self.nodeAnimationDuration
          : nodeAnimationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      nodeAnimationCurve: null == nodeAnimationCurve
          ? _self.nodeAnimationCurve
          : nodeAnimationCurve // ignore: cast_nullable_to_non_nullable
              as Curve,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphViewData].
extension GraphViewDataPatterns on GraphViewData {
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
    TResult Function(_GraphViewData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphViewData() when $default != null:
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
    TResult Function(_GraphViewData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewData():
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
    TResult? Function(_GraphViewData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewData() when $default != null:
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
            Graph graph,
            GraphViewBehavior behavior,
            GraphLayoutStrategy? layoutStrategy,
            bool allowSelection,
            bool allowMultiSelection,
            bool animationEnabled,
            Offset? nodeAnimationStartPosition,
            Duration nodeAnimationDuration,
            Curve nodeAnimationCurve)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphViewData() when $default != null:
        return $default(
            _that.graph,
            _that.behavior,
            _that.layoutStrategy,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.animationEnabled,
            _that.nodeAnimationStartPosition,
            _that.nodeAnimationDuration,
            _that.nodeAnimationCurve);
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
            Graph graph,
            GraphViewBehavior behavior,
            GraphLayoutStrategy? layoutStrategy,
            bool allowSelection,
            bool allowMultiSelection,
            bool animationEnabled,
            Offset? nodeAnimationStartPosition,
            Duration nodeAnimationDuration,
            Curve nodeAnimationCurve)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewData():
        return $default(
            _that.graph,
            _that.behavior,
            _that.layoutStrategy,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.animationEnabled,
            _that.nodeAnimationStartPosition,
            _that.nodeAnimationDuration,
            _that.nodeAnimationCurve);
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
            Graph graph,
            GraphViewBehavior behavior,
            GraphLayoutStrategy? layoutStrategy,
            bool allowSelection,
            bool allowMultiSelection,
            bool animationEnabled,
            Offset? nodeAnimationStartPosition,
            Duration nodeAnimationDuration,
            Curve nodeAnimationCurve)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewData() when $default != null:
        return $default(
            _that.graph,
            _that.behavior,
            _that.layoutStrategy,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.animationEnabled,
            _that.nodeAnimationStartPosition,
            _that.nodeAnimationDuration,
            _that.nodeAnimationCurve);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphViewData implements GraphViewData {
  const _GraphViewData(
      {required this.graph,
      required this.behavior,
      required this.layoutStrategy,
      required this.allowSelection,
      required this.allowMultiSelection,
      required this.animationEnabled,
      required this.nodeAnimationStartPosition,
      required this.nodeAnimationDuration,
      required this.nodeAnimationCurve});

  /// The graph data model to be visualized
  @override
  final Graph graph;

  /// View interaction and rendering behaviors
  @override
  final GraphViewBehavior behavior;

  /// Strategy for positioning nodes, null disables automatic layout
  @override
  final GraphLayoutStrategy? layoutStrategy;

  /// Whether nodes and links can be selected
  @override
  final bool allowSelection;

  /// Whether multiple nodes and links can be selected simultaneously
  @override
  final bool allowMultiSelection;

  /// Whether position changes should be animated
  @override
  final bool animationEnabled;

  /// Starting position for node animations, null uses current position
  @override
  final Offset? nodeAnimationStartPosition;

  /// Duration of node movement animations
  @override
  final Duration nodeAnimationDuration;

  /// Animation curve for node movements
  @override
  final Curve nodeAnimationCurve;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphViewDataCopyWith<_GraphViewData> get copyWith =>
      __$GraphViewDataCopyWithImpl<_GraphViewData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphViewData &&
            (identical(other.graph, graph) || other.graph == graph) &&
            (identical(other.behavior, behavior) ||
                other.behavior == behavior) &&
            (identical(other.layoutStrategy, layoutStrategy) ||
                other.layoutStrategy == layoutStrategy) &&
            (identical(other.allowSelection, allowSelection) ||
                other.allowSelection == allowSelection) &&
            (identical(other.allowMultiSelection, allowMultiSelection) ||
                other.allowMultiSelection == allowMultiSelection) &&
            (identical(other.animationEnabled, animationEnabled) ||
                other.animationEnabled == animationEnabled) &&
            (identical(other.nodeAnimationStartPosition,
                    nodeAnimationStartPosition) ||
                other.nodeAnimationStartPosition ==
                    nodeAnimationStartPosition) &&
            (identical(other.nodeAnimationDuration, nodeAnimationDuration) ||
                other.nodeAnimationDuration == nodeAnimationDuration) &&
            (identical(other.nodeAnimationCurve, nodeAnimationCurve) ||
                other.nodeAnimationCurve == nodeAnimationCurve));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      graph,
      behavior,
      layoutStrategy,
      allowSelection,
      allowMultiSelection,
      animationEnabled,
      nodeAnimationStartPosition,
      nodeAnimationDuration,
      nodeAnimationCurve);

  @override
  String toString() {
    return 'GraphViewData(graph: $graph, behavior: $behavior, layoutStrategy: $layoutStrategy, allowSelection: $allowSelection, allowMultiSelection: $allowMultiSelection, animationEnabled: $animationEnabled, nodeAnimationStartPosition: $nodeAnimationStartPosition, nodeAnimationDuration: $nodeAnimationDuration, nodeAnimationCurve: $nodeAnimationCurve)';
  }
}

/// @nodoc
abstract mixin class _$GraphViewDataCopyWith<$Res>
    implements $GraphViewDataCopyWith<$Res> {
  factory _$GraphViewDataCopyWith(
          _GraphViewData value, $Res Function(_GraphViewData) _then) =
      __$GraphViewDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Graph graph,
      GraphViewBehavior behavior,
      GraphLayoutStrategy? layoutStrategy,
      bool allowSelection,
      bool allowMultiSelection,
      bool animationEnabled,
      Offset? nodeAnimationStartPosition,
      Duration nodeAnimationDuration,
      Curve nodeAnimationCurve});
}

/// @nodoc
class __$GraphViewDataCopyWithImpl<$Res>
    implements _$GraphViewDataCopyWith<$Res> {
  __$GraphViewDataCopyWithImpl(this._self, this._then);

  final _GraphViewData _self;
  final $Res Function(_GraphViewData) _then;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? graph = null,
    Object? behavior = null,
    Object? layoutStrategy = freezed,
    Object? allowSelection = null,
    Object? allowMultiSelection = null,
    Object? animationEnabled = null,
    Object? nodeAnimationStartPosition = freezed,
    Object? nodeAnimationDuration = null,
    Object? nodeAnimationCurve = null,
  }) {
    return _then(_GraphViewData(
      graph: null == graph
          ? _self.graph
          : graph // ignore: cast_nullable_to_non_nullable
              as Graph,
      behavior: null == behavior
          ? _self.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as GraphViewBehavior,
      layoutStrategy: freezed == layoutStrategy
          ? _self.layoutStrategy
          : layoutStrategy // ignore: cast_nullable_to_non_nullable
              as GraphLayoutStrategy?,
      allowSelection: null == allowSelection
          ? _self.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _self.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      animationEnabled: null == animationEnabled
          ? _self.animationEnabled
          : animationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      nodeAnimationStartPosition: freezed == nodeAnimationStartPosition
          ? _self.nodeAnimationStartPosition
          : nodeAnimationStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      nodeAnimationDuration: null == nodeAnimationDuration
          ? _self.nodeAnimationDuration
          : nodeAnimationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      nodeAnimationCurve: null == nodeAnimationCurve
          ? _self.nodeAnimationCurve
          : nodeAnimationCurve // ignore: cast_nullable_to_non_nullable
              as Curve,
    ));
  }
}

// dart format on
