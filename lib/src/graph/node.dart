import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_data.dart';

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

  /// Listenable for state changes that affect rendering but not layout.
  ///
  /// Used to trigger UI updates when visual properties like selection state
  /// change.
  Listenable get renderStateListenable;
}

@internal
final class GraphNodeImpl extends GraphEntityImpl<GraphNodeData>
    with Diagnosticable
    implements GraphNode {
  GraphNodeImpl(super.val, {Map<String, Object>? properties}) {
    this.properties = properties ?? const {};
  }

  final ValueNotifier<GraphNodeViewGeometry?> _geometry = ValueNotifier(null);
  final Map<GraphId, ValueNotifier<GraphConnectionGeometry?>>
      _connectionGeometries = {};
  final ValueNotifier<GraphShape?> _shape = ValueNotifier(null);
  final ValueNotifier<Offset> _animatedPosition = ValueNotifier(Offset.zero);
  final ValueNotifier<bool> _isSelected = ValueNotifier(false);
  final ValueNotifier<bool> _isAnimating = ValueNotifier(false);
  final ValueNotifier<bool> _isAnimationCompleted = ValueNotifier(false);
  final ValueNotifier<Offset> _animationStartPosition =
      ValueNotifier(Offset.zero);
  final ValueNotifier<Offset> _logicalPosition = ValueNotifier(Offset.zero);
  final ValueNotifier<int> _stackOrder = ValueNotifier(-1);

  /// Listenable that combines position and state ValueNotifiers
  /// Note: _animatedPosition is excluded to avoid circular dependency during
  /// animation
  late final Listenable positionListenable = Listenable.merge([
    _logicalPosition,
    state, // for isArranged and other state changes
  ]);

  /// Listenable for state changes that affect rendering but not layout
  late final Listenable _renderStateListenable = Listenable.merge([
    _isSelected, // for selection state changes
  ]);

  /// Public accessor for render state listenable
  @override
  Listenable get renderStateListenable => _renderStateListenable;

  /// 状態を更新し、変更を通知する
  ///
  /// UIに反映したい変更に使用します。
  void updateWith({
    double? weight,
    Offset? logicalPosition,
    bool? isEnabled,
    bool? visible,
    bool? canSelect,
    bool? canDrag,
    bool? isArranged,
  }) {
    setState(
      state.value.copyWith(
        weight: weight ?? state.value.weight,
        logicalPosition: logicalPosition ?? state.value.logicalPosition,
        isEnabled: isEnabled ?? state.value.isEnabled,
        visible: visible ?? state.value.visible,
        canSelect: canSelect ?? state.value.canSelect,
        canDrag: canDrag ?? state.value.canDrag,
        isArranged: isArranged ?? state.value.isArranged,
      ),
    );
  }

  @override
  set weight(double weight) {
    setState(state.value.copyWith(weight: weight));
  }

  @override
  int get stackOrder => _stackOrder.value;

  @override
  set stackOrder(int stackOrder) {
    _stackOrder.value = stackOrder;
  }

  @override
  Offset get logicalPosition => _logicalPosition.value;

  @override
  set logicalPosition(Offset position) {
    if (_logicalPosition.value != position) {
      debugPrint(
          '📍 Node ${id.value.substring(0, 4)} position changed: ${_logicalPosition.value} -> $position');
    }
    _logicalPosition.value = position;
  }

  @override
  Offset get animationStartPosition => _animationStartPosition.value;

  set animationStartPosition(Offset position) {
    _animationStartPosition.value = position;
  }

  ValueNotifier<Offset> get animatedPositionState => _animatedPosition;

  @override
  Offset get animatedPosition => _animatedPosition.value;

  set animatedPosition(Offset position) {
    _animatedPosition.value = position;
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
      ),
    );
    // If canSelect is disabled, also deselect the node
    if (!canSelect && isSelected) {
      _isSelected.value = false;
    }
  }

  @override
  set canDrag(bool canDrag) {
    setState(state.value.copyWith(canDrag: canDrag));
  }

  ValueNotifier<bool> get isSelectedState => _isSelected;

  @override
  bool get isSelected => _isSelected.value;

  set isSelected(bool isSelected) {
    _isSelected.value = isSelected;
  }

  bool get isArranged => state.value.isArranged;

  set isArranged(bool isArranged) {
    setState(state.value.copyWith(isArranged: isArranged));
  }

  bool get isAnimating => _isAnimating.value;

  set isAnimating(bool isAnimating) {
    _isAnimating.value = isAnimating;
  }

  bool get isAnimationCompleted => _isAnimationCompleted.value;

  set isAnimationCompleted(bool isAnimationCompleted) {
    _isAnimationCompleted.value = isAnimationCompleted;
  }

  bool get isAnimationReady => !isAnimating && !isAnimationCompleted;

  /// Reset animation state for a new layout
  void resetAnimationState() {
    _isAnimating.value = false;
    _isAnimationCompleted.value = false;
  }

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

  ValueNotifier<GraphNodeViewGeometry?> get geometryState => _geometry;

  @override
  GraphNodeViewGeometry? get geometry => _geometry.value;

  //set geometry(GraphNodeViewGeometry? geometry) => _geometry.value = geometry;
  set geometry(GraphNodeViewGeometry? geometry) {
    _geometry.value = geometry;
  }

  ValueNotifier<GraphConnectionGeometry?> getConnectionGeometryState(
    GraphNode target,
  ) =>
      _connectionGeometries[target.id] ??= ValueNotifier(null);

  GraphConnectionGeometry? getConnectionGeometry(GraphNode target) =>
      _connectionGeometries[target.id]?.value;

  ValueNotifier<GraphConnectionGeometry?> setConnectionGeometry(
    GraphNode target,
    GraphConnectionGeometry? geometry,
  ) =>
      (_connectionGeometries[target.id] ??= ValueNotifier(geometry))
        ..value = geometry;

  ValueNotifier<GraphShape?> get shapeState => _shape;

  @override
  GraphShape? get shape => _shape.value;

  set shape(GraphShape? shape) => _shape.value = shape;
}
