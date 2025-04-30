import 'dart:ui';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/geometry.dart';

part 'graph_data.freezed.dart';

/// Interface defining the core state shared by all graph entities.
///
/// Provides the essential properties needed for identification, positioning,
/// and state management of graph elements.
@internal
abstract interface class GraphEntityData {
  /// Unique identifier for this entity.
  GraphId get id;

  /// The logical position of this entity in the graph's coordinate space.
  Offset get logicalPosition;

  /// A value influencing the entity's behavior in layout algorithms.
  double get weight;

  int get stackOrder;

  bool get isEnabled;

  bool get visible;

  bool get canSelect;

  bool get isSelected;

  bool get canDrag;
}

/// The direction of a link between nodes.
///
/// - [none]: No directional indicator
/// - [incoming]: Arrow pointing to target
/// - [outgoing]: Arrow pointing from source
/// - [bidirectional]: Arrows on both ends
enum GraphLinkDirection {
  @JsonValue('none')
  none,
  @JsonValue('incoming')
  incoming,
  @JsonValue('outgoing')
  outgoing,
  @JsonValue('bidirectional')
  bidirectional,
}

/// Immutable data structure representing a node's state.
///
/// Contains the complete state needed to render and interact with a node,
/// including position, animation, and selection state.
@internal
@freezed
class GraphNodeData with _$GraphNodeData implements GraphEntityData {
  /// Creates node data with an id and optional state properties.
  const factory GraphNodeData({
    required GraphId id,
    @Default(Offset.zero) Offset logicalPosition,

    /// The current animated position during transitions.
    ///
    /// Used to smoothly animate the node between positions when layout changes.
    @Default(Offset.zero) Offset animatedPosition,

    /// The position from which the current animation started.
    @Default(Offset.zero) Offset animationStartPosition,
    @Default(1.0) double weight,
    @Default(-1) int stackOrder,
    @Default(true) bool isEnabled,
    @Default(true) bool visible,
    @Default(true) bool canSelect,
    @Default(true) bool canDrag,
    @Default(false) bool isSelected,
    @Default(false) bool isArranged,
    @Default(false) bool isAnimating,
    @Default(false) bool isAnimationCompleted,
  }) = _GraphNodeData;
}

/// Immutable data structure representing a link's state.
///
/// Contains the complete state needed to render and interact with a link,
/// including its endpoints, direction, and visual properties.
@internal
@freezed
class GraphLinkData with _$GraphLinkData implements GraphEntityData {
  /// Creates link data with an id and optional properties.
  const factory GraphLinkData({
    required GraphId id,
    GraphNode? source,
    GraphNode? target,
    @Default(GraphLinkDirection.none) GraphLinkDirection direction,
    @Default(Offset.zero) Offset logicalPosition,
    @Default(1.0) double weight,
    @Default(-1) int stackOrder,
    @Default(true) bool isEnabled,
    @Default(true) bool visible,
    @Default(true) bool canSelect,
    @Default(true) bool canDrag,
    @Default(false) bool isSelected,
    @Default(false) bool isArranged,
    @Default(false) bool isAnimating,
    @Default(false) bool isAnimationCompleted,
  }) = _GraphLinkData;
}

/// Immutable data structure representing the complete state of a graph.
///
/// Maintains collections of nodes and links, selection states, and layout information
/// using immutable collections for consistent state management.
@internal
@freezed
class GraphData with _$GraphData {
  /// Creates graph data with an id and optional collections and states.
  const factory GraphData({
    /// Unique identifier for this graph instance.
    required GraphId id,

    /// Map of node IDs to their corresponding [GraphNode] instances.
    @Default(IMapConst({})) IMap<GraphId, GraphNode> nodes,

    /// Map of link IDs to their corresponding [GraphLink] instances.
    @Default(IMapConst({})) IMap<GraphId, GraphLink> links,

    /// List of IDs for currently selected nodes.
    @Default(IListConst([])) IList<GraphId> selectedNodeIds,

    /// List of IDs for currently selected links.
    @Default(IListConst([])) IList<GraphId> selectedLinkIds,

    /// Whether selection of graph elements is enabled.
    @Default(true) bool allowSelection,

    /// Whether multiple elements can be selected simultaneously.
    @Default(false) bool allowMultiSelection,
    @Default(true) bool needsLayout,
    GraphViewGeometry? geometry,
  }) = _GraphData;
}
