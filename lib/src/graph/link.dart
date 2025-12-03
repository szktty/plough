import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_data.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/geometry.dart';

/// Manages connections between graph nodes with support for directionality, routing,
/// and visual styling. Extends [GraphEntity] with link-specific functionality.
///
/// See also:
///
/// * [Graph], which manages collections of links and their nodes
/// * [GraphEntity], which provides the base functionality
/// * [GraphLinkViewBehavior], which controls the link's view interactions
/// * [GraphNode], which represents the endpoints of links
abstract class GraphLink implements GraphEntity {
  /// Creates a new link between [source] and [target] nodes.
  ///
  /// The [direction] specifies the link's directionality.
  /// If [id] is not provided, generates a unique link ID.
  factory GraphLink({
    required GraphNode source,
    required GraphNode target,
    required GraphLinkDirection direction,
    GraphId? id,
    Map<String, Object>? properties,
  }) {
    return GraphLinkImpl(
      GraphLinkData(
        id: id ?? GraphId.unique(GraphIdType.link),
        source: source,
        target: target,
        direction: direction,
      ),
      properties: properties,
    );
  }

  /// The source node where this link begins.
  GraphNode get source;

  /// Sets the source node of this link.
  set source(covariant GraphNode source);

  /// The target node where this link ends.
  GraphNode get target;

  /// Sets the target node of this link.
  set target(covariant GraphNode target);

  /// The directionality of this link.
  ///
  /// Controls whether the link is directed and in which direction.
  GraphLinkDirection get direction;

  /// Sets the directionality of this link.
  set direction(GraphLinkDirection direction);

  /// The geometric information for this link's view representation.
  ///
  /// Contains data needed for rendering and connection routing.
  GraphLinkViewGeometry? get geometry;
}

@internal
class GraphLinkImpl extends GraphEntityImpl<GraphLinkData>
    with Diagnosticable
    implements GraphLink {
  GraphLinkImpl(super.val, {Map<String, Object>? properties}) {
    this.properties = properties ?? const {};
  }

  final ValueNotifier<GraphLinkViewGeometry?> _geometry = ValueNotifier(null);
  final ValueNotifier<bool> _isSelected = ValueNotifier(false);

  /// 状態を更新し、変更を通知する
  ///
  /// UIに反映したい変更に使用します。
  void updateWith() {
    // No properties need batch notification
    // keeping method for consistency with base pattern
  }

  @override
  GraphNodeImpl get source => state.value.source! as GraphNodeImpl;

  @override
  set source(GraphNodeImpl source) {
    setState(state.value.copyWith(source: source));
  }

  @override
  GraphNodeImpl get target => state.value.target! as GraphNodeImpl;

  @override
  set target(GraphNodeImpl target) {
    setState(state.value.copyWith(target: target));
  }

  GraphNodeImpl get sourceImpl => state.value.source! as GraphNodeImpl;

  GraphNodeImpl get targetImpl => state.value.target! as GraphNodeImpl;

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
  GraphLinkDirection get direction => state.value.direction;

  @override
  set direction(GraphLinkDirection direction) {
    setState(state.value.copyWith(direction: direction));
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
    setState(state.value.copyWith(canSelect: canSelect));
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

  @override
  GraphLinkViewGeometry? get geometry => _geometry.value;

  set geometry(GraphLinkViewGeometry? geometry) {
    _geometry.value = geometry;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GraphId>('id', id))
      ..add(DiagnosticsProperty<GraphNode>('source', source))
      ..add(DiagnosticsProperty<GraphNode>('target', target))
      ..add(DiagnosticsProperty<Offset>('position', logicalPosition))
      ..add(EnumProperty<GraphLinkDirection>('direction', direction))
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
}
