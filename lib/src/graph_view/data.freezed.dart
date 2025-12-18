// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphViewData {
  /// The graph data model to be visualized
  Graph get graph => throw _privateConstructorUsedError;

  /// View interaction and rendering behaviors
  GraphViewBehavior get behavior => throw _privateConstructorUsedError;

  /// Strategy for positioning nodes, null disables automatic layout
  GraphLayoutStrategy? get layoutStrategy => throw _privateConstructorUsedError;

  /// Whether nodes and links can be selected
  bool get allowSelection => throw _privateConstructorUsedError;

  /// Whether multiple nodes and links can be selected simultaneously
  bool get allowMultiSelection => throw _privateConstructorUsedError;

  /// Whether position changes should be animated
  bool get animationEnabled => throw _privateConstructorUsedError;

  /// Starting position for node animations, null uses current position
  Offset? get nodeAnimationStartPosition => throw _privateConstructorUsedError;

  /// Duration of node movement animations
  Duration get nodeAnimationDuration => throw _privateConstructorUsedError;

  /// Animation curve for node movements
  Curve get nodeAnimationCurve => throw _privateConstructorUsedError;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphViewDataCopyWith<GraphViewData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphViewDataCopyWith<$Res> {
  factory $GraphViewDataCopyWith(
          GraphViewData value, $Res Function(GraphViewData) then) =
      _$GraphViewDataCopyWithImpl<$Res, GraphViewData>;
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
class _$GraphViewDataCopyWithImpl<$Res, $Val extends GraphViewData>
    implements $GraphViewDataCopyWith<$Res> {
  _$GraphViewDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      graph: null == graph
          ? _value.graph
          : graph // ignore: cast_nullable_to_non_nullable
              as Graph,
      behavior: null == behavior
          ? _value.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as GraphViewBehavior,
      layoutStrategy: freezed == layoutStrategy
          ? _value.layoutStrategy
          : layoutStrategy // ignore: cast_nullable_to_non_nullable
              as GraphLayoutStrategy?,
      allowSelection: null == allowSelection
          ? _value.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _value.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      animationEnabled: null == animationEnabled
          ? _value.animationEnabled
          : animationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      nodeAnimationStartPosition: freezed == nodeAnimationStartPosition
          ? _value.nodeAnimationStartPosition
          : nodeAnimationStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      nodeAnimationDuration: null == nodeAnimationDuration
          ? _value.nodeAnimationDuration
          : nodeAnimationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      nodeAnimationCurve: null == nodeAnimationCurve
          ? _value.nodeAnimationCurve
          : nodeAnimationCurve // ignore: cast_nullable_to_non_nullable
              as Curve,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphViewDataImplCopyWith<$Res>
    implements $GraphViewDataCopyWith<$Res> {
  factory _$$GraphViewDataImplCopyWith(
          _$GraphViewDataImpl value, $Res Function(_$GraphViewDataImpl) then) =
      __$$GraphViewDataImplCopyWithImpl<$Res>;
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
class __$$GraphViewDataImplCopyWithImpl<$Res>
    extends _$GraphViewDataCopyWithImpl<$Res, _$GraphViewDataImpl>
    implements _$$GraphViewDataImplCopyWith<$Res> {
  __$$GraphViewDataImplCopyWithImpl(
      _$GraphViewDataImpl _value, $Res Function(_$GraphViewDataImpl) _then)
      : super(_value, _then);

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
    return _then(_$GraphViewDataImpl(
      graph: null == graph
          ? _value.graph
          : graph // ignore: cast_nullable_to_non_nullable
              as Graph,
      behavior: null == behavior
          ? _value.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as GraphViewBehavior,
      layoutStrategy: freezed == layoutStrategy
          ? _value.layoutStrategy
          : layoutStrategy // ignore: cast_nullable_to_non_nullable
              as GraphLayoutStrategy?,
      allowSelection: null == allowSelection
          ? _value.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _value.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      animationEnabled: null == animationEnabled
          ? _value.animationEnabled
          : animationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      nodeAnimationStartPosition: freezed == nodeAnimationStartPosition
          ? _value.nodeAnimationStartPosition
          : nodeAnimationStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      nodeAnimationDuration: null == nodeAnimationDuration
          ? _value.nodeAnimationDuration
          : nodeAnimationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      nodeAnimationCurve: null == nodeAnimationCurve
          ? _value.nodeAnimationCurve
          : nodeAnimationCurve // ignore: cast_nullable_to_non_nullable
              as Curve,
    ));
  }
}

/// @nodoc

class _$GraphViewDataImpl implements _GraphViewData {
  const _$GraphViewDataImpl(
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

  @override
  String toString() {
    return 'GraphViewData(graph: $graph, behavior: $behavior, layoutStrategy: $layoutStrategy, allowSelection: $allowSelection, allowMultiSelection: $allowMultiSelection, animationEnabled: $animationEnabled, nodeAnimationStartPosition: $nodeAnimationStartPosition, nodeAnimationDuration: $nodeAnimationDuration, nodeAnimationCurve: $nodeAnimationCurve)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphViewDataImpl &&
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

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphViewDataImplCopyWith<_$GraphViewDataImpl> get copyWith =>
      __$$GraphViewDataImplCopyWithImpl<_$GraphViewDataImpl>(this, _$identity);
}

abstract class _GraphViewData implements GraphViewData {
  const factory _GraphViewData(
      {required final Graph graph,
      required final GraphViewBehavior behavior,
      required final GraphLayoutStrategy? layoutStrategy,
      required final bool allowSelection,
      required final bool allowMultiSelection,
      required final bool animationEnabled,
      required final Offset? nodeAnimationStartPosition,
      required final Duration nodeAnimationDuration,
      required final Curve nodeAnimationCurve}) = _$GraphViewDataImpl;

  /// The graph data model to be visualized
  @override
  Graph get graph;

  /// View interaction and rendering behaviors
  @override
  GraphViewBehavior get behavior;

  /// Strategy for positioning nodes, null disables automatic layout
  @override
  GraphLayoutStrategy? get layoutStrategy;

  /// Whether nodes and links can be selected
  @override
  bool get allowSelection;

  /// Whether multiple nodes and links can be selected simultaneously
  @override
  bool get allowMultiSelection;

  /// Whether position changes should be animated
  @override
  bool get animationEnabled;

  /// Starting position for node animations, null uses current position
  @override
  Offset? get nodeAnimationStartPosition;

  /// Duration of node movement animations
  @override
  Duration get nodeAnimationDuration;

  /// Animation curve for node movements
  @override
  Curve get nodeAnimationCurve;

  /// Create a copy of GraphViewData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphViewDataImplCopyWith<_$GraphViewDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
