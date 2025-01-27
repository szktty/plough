import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_data.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals.dart';

/// Core component of graph visualization that manages visual properties, animation states,
/// and interaction behaviors. Extends [GraphEntity] with node-specific functionality.
///
/// See also:
///
/// * [Graph], which manages collections of nodes and their relationships
/// * [GraphEntity], which provides the base functionality
/// * [GraphShape], which defines the node's visual representation
/// * [GraphNodeViewBehavior], which controls the node's view interactions and appearance
abstract interface class GraphNode implements GraphEntity {
  /// Creates a node with optional [id] and [properties].
  ///
  /// If [id] is not provided, generates a unique identifier.
  factory GraphNode({GraphId? id, Map<String, Object>? properties}) {
    return GraphNodeImpl(
      GraphNodeData(
        id: id ?? GraphId.unique(GraphIdType.node),
      ),
      properties: properties,
    );
  }

  /// The position where animation begins for this node.
  ///
  /// Used to smoothly transition the node between positions.
  Offset get animationStartPosition;

  /// The current animated position of this node.
  ///
  /// This position updates during animation transitions.
  Offset get animatedPosition;

  /// The geometric information for this node's view representation.
  ///
  /// Contains data needed for rendering and hit testing.
  GraphNodeViewGeometry? get geometry;

  /// The shape configuration for this node.
  ///
  /// Defines how the node is visually rendered.
  GraphShape? get shape;
}

final class GraphNodeImpl extends GraphEntityImpl<GraphNodeData>
    with Diagnosticable
    implements GraphNode {
  GraphNodeImpl(super.val, {Map<String, Object>? properties}) {
    this.properties = properties ?? const {};
  }

  static GraphNodeImpl of(BuildContext context) =>
      Provider.of(context, listen: false);

  final Signal<GraphNodeViewGeometry?> _geometry = Signal(null);
  final Map<GraphId, Signal<GraphConnectionGeometry?>> _connectionGeometries =
      {};
  final Signal<GraphShape?> _shape = Signal(null);

  @override
  set weight(double weight) {
    setState(state.value.copyWith(weight: weight));
  }

  @override
  set stackOrder(int stackOrder) {
    setState(state.value.copyWith(stackOrder: stackOrder));
  }

  @override
  set logicalPosition(Offset position) {
    setState(state.value.copyWith(logicalPosition: position));
  }

  @override
  Offset get animationStartPosition => state.value.animationStartPosition;

  set animationStartPosition(Offset position) {
    setState(state.value.copyWith(animationStartPosition: position));
  }

  @override
  Offset get animatedPosition => state.value.animatedPosition;

  set animatedPosition(Offset position) {
    setState(state.value.copyWith(animatedPosition: position));
  }

  @override
  set isEnabled(bool isEnabled) {
    setState(state.value.copyWith(isEnabled: isEnabled));
  }

  @override
  set visible(bool visible) {
    setState(state.value.copyWith(visible: visible));
  }

  @override
  set canSelect(bool canSelect) {
    setState(
      state.value.copyWith(
        canSelect: canSelect,
        isSelected: canSelect && isSelected,
      ),
    );
  }

  set isSelected(bool isSelected) {
    setState(state.value.copyWith(isSelected: isSelected));
  }

  bool get isArranged => state.value.isArranged;

  set isArranged(bool isArranged) {
    setState(state.value.copyWith(isArranged: isArranged));
  }

  bool get isAnimating => state.value.isAnimating;

  set isAnimating(bool isAnimating) {
    setState(state.value.copyWith(isAnimating: isAnimating));
  }

  bool get isAnimationCompleted => state.value.isAnimationCompleted;

  set isAnimationCompleted(bool isAnimationCompleted) {
    setState(state.value.copyWith(isAnimationCompleted: isAnimationCompleted));
  }

  bool get isAnimationReady => !isAnimating && !isAnimationCompleted;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GraphId>('id', id))
      ..add(DiagnosticsProperty<Offset>('position', logicalPosition))
      ..add(StringProperty('geometry', geometry.toString()))
      ..add(
        FlagProperty(
          'isEnabled',
          value: isEnabled,
          ifTrue: 'enabled',
          ifFalse: 'disabled',
        ),
      )
      ..add(
        FlagProperty(
          'visible',
          value: visible,
          ifTrue: 'visible',
          ifFalse: 'invisible',
        ),
      )
      ..add(
        FlagProperty(
          'canSelect',
          value: canSelect,
          ifTrue: 'selectable',
          ifFalse: 'not selectable',
        ),
      )
      ..add(
        FlagProperty(
          'isSelected',
          value: isSelected,
          ifTrue: 'selected',
          ifFalse: 'not selected',
        ),
      )
      ..add(DiagnosticsProperty('properties', this.properties));
  }

  Signal<GraphNodeViewGeometry?> get geometryState => _geometry;

  @override
  GraphNodeViewGeometry? get geometry => _geometry.value;

  //set geometry(GraphNodeViewGeometry? geometry) => _geometry.value = geometry;
  set geometry(GraphNodeViewGeometry? geometry) {
    _geometry.value = geometry;
  }

  Signal<GraphConnectionGeometry?> getConnectionGeometryState(
    GraphNode target,
  ) =>
      _connectionGeometries[target.id] ??= Signal(null);

  GraphConnectionGeometry? getConnectionGeometry(GraphNode target) =>
      _connectionGeometries[target.id]?.value;

  Signal<GraphConnectionGeometry?> setConnectionGeometry(
    GraphNode target,
    GraphConnectionGeometry? geometry,
  ) =>
      (_connectionGeometries[target.id] ??= Signal(geometry))..value = geometry;

  Signal<GraphShape?> get shapeState => _shape;

  @override
  GraphShape? get shape => _shape.value;

  set shape(GraphShape? shape) => _shape.value = shape;
}
