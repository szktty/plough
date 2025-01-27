import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_data.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/utils/signals.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

/// A core data structure that provides the foundation for graph visualization through [GraphView].
///
/// The Graph maintains a consistent data model for [GraphView] by automatically handling link cleanup
/// when nodes are removed, managing selection states, and controlling display order of elements. While
/// [GraphView] handles the visualization aspects, this class focuses on maintaining the underlying
/// data structure independently.
///
/// Graph elements can be dynamically added or removed, with automatic relationship maintenance and
/// change notifications to keep the visualization synchronized. The structure supports custom
/// properties for both nodes and links, enabling flexible data visualization through [GraphView]'s
/// rendering system.
///
/// See also:
///
/// * [GraphNode], for representing nodes with custom properties and selection states.
/// * [GraphLink], for defining directed relationships between nodes.
/// * [GraphEntity], the base interface for all graph elements.
/// * [GraphOrderManager], for controlling element display ordering.
/// * [GraphView], for rendering and interacting with the graph structure.
abstract class Graph implements Listenable {
  factory Graph() => GraphImpl();

  /// The unique identifier of this graph.
  GraphId get id;

  /// All nodes currently in the graph.
  ///
  /// The order of nodes is not guaranteed to remain consistent between calls.
  /// Returns a read-only view of the nodes collection.
  Iterable<GraphNode> get nodes;

  /// All links currently in the graph.
  ///
  /// The order of links is not guaranteed to remain consistent between calls.
  /// Returns a read-only view of the links collection.
  Iterable<GraphLink> get links;

  /// Adds a node to the graph.
  ///
  /// Throws [StateError] if the node has already been added to another graph.
  void addNode(covariant GraphNode node);

  /// Adds multiple nodes to the graph.
  ///
  /// Equivalent to calling [addNode] for each node in the list.
  /// Throws [StateError] if any node has already been added to another graph.
  void addNodes(List<GraphNode> nodes);

  /// Returns the node with the given [id], or `null` if no such node exists.
  GraphNode? getNode(GraphId id);

  /// Returns `true` if a node with the given [id] exists in the graph.
  bool hasNode(GraphId id);

  /// Removes the node with the given [id] and all its associated links.
  ///
  /// Throws [ArgumentError] if no node with [id] exists.
  /// Automatically removes any links connected to this node.
  void removeNode(GraphId id);

  /// Adds a link to the graph.
  ///
  /// The link's source and target nodes must both exist in the graph.
  /// Throws [StateError] if the link has already been added to another graph.
  void addLink(covariant GraphLink link);

  /// Adds multiple links to the graph.
  ///
  /// Equivalent to calling [addLink] for each link in the list.
  /// Each link must have a unique ID and both its source and target nodes
  /// must exist in the graph.
  void addLinks(List<GraphLink> links);

  /// Returns the link with the given [id], or `null` if no such link exists.
  GraphLink? getLink(GraphId id);

  /// Returns all links that have the specified node as their target.
  ///
  /// Useful for traversing the graph in reverse or analyzing incoming connections.
  /// Throws [ArgumentError] if no node with [nodeId] exists.
  List<GraphLink> getIncomingLinks(GraphId nodeId);

  /// Returns all links that have the specified node as their source.
  ///
  /// Useful for traversing the graph or analyzing outgoing connections.
  /// Throws [ArgumentError] if no node with [nodeId] exists.
  List<GraphLink> getOutgoingLinks(GraphId nodeId);

  /// Removes the link with the given [id].
  ///
  /// Throws [ArgumentError] if no link with [id] exists.
  void removeLink(GraphId id);

  /// Reverses the direction of the link with the given [id].
  ///
  /// Swaps the source and target nodes of the link while maintaining all other properties.
  /// Throws [ArgumentError] if no link with [id] exists.
  void reverseLink(GraphId id);

  /// Returns a list of all currently selected nodes and links.
  List<GraphEntity> get selectedEntities;

  /// Returns a list of IDs for all currently selected nodes and links.
  List<GraphId> get selectedEntityIds;

  /// Returns a list of all currently selected nodes.
  List<GraphNode> get selectedNodes;

  /// Returns a list of IDs for all currently selected nodes.
  List<GraphId> get selectedNodeIds;

  /// Returns a list of all currently selected links.
  List<GraphLink> get selectedLinks;

  /// Returns a list of IDs for all currently selected links.
  List<GraphId> get selectedLinkIds;

  /// Returns `true` if the entity with the given [id] is currently selected.
  bool isSelected(GraphId id);

  /// Selects the node with the given [id].
  ///
  /// Throws [ArgumentError] if no node with [id] exists.
  void selectNode(GraphId id);

  /// Deselects the node with the given [id].
  ///
  /// Throws [ArgumentError] if no node with [id] exists.
  void deselectNode(GraphId id);

  /// Toggles the selection state of the node with the given [id].
  ///
  /// If the node is selected, deselects it. If it's not selected, selects it.
  /// Throws [ArgumentError] if no node with [id] exists.
  void toggleSelectNode(GraphId id);

  /// Selects the link with the given [id].
  ///
  /// If multi-selection is disabled, deselects all other links.
  /// Throws [ArgumentError] if no link with [id] exists.
  void selectLink(GraphId id);

  /// Deselects the link with the given [id].
  ///
  /// Throws [ArgumentError] if no link with [id] exists.
  void deselectLink(GraphId id);

  /// Toggles the selection state of the link with the given [id].
  ///
  /// If the link is selected, deselects it. If it's not selected, selects it.
  /// Throws [ArgumentError] if no link with [id] exists.
  void toggleSelectLink(GraphId id);

  /// Marks the graph as needing a layout recalculation.
  ///
  /// This triggers [GraphView] to recalculate node positions during its next update cycle.
  void markNeedsLayout();

  /// Brings the node with the given [id] to the front of the display stack.
  ///
  /// Throws [ArgumentError] if no node with [id] exists.
  void bringToFront(GraphId id);

  /// The current geometry of the graph visualization.
  ///
  /// Used by [GraphView] to maintain layout information and coordinate transformations.
  /// May be null if no layout has been calculated yet.
  GraphViewGeometry? get geometry;

  /// Returns a [GraphOrderManager] for controlling the z-order of entities.
  ///
  /// If [ids] is provided, only manages the specified entities.
  /// If [ids] is omitted, manages all entities in the graph.
  /// Throws [ArgumentError] if any of the provided IDs don't exist.
  GraphOrderManager getOrderManager([List<GraphId>? ids]);

  /// Returns a [GraphOrderManager] for controlling the z-order of entities with immediate updates.
  ///
  /// Similar to [getOrderManager] but changes take effect immediately without waiting for the next frame.
  /// If [ids] is provided, only manages the specified entities.
  /// If [ids] is omitted, manages all entities in the graph.
  /// Throws [ArgumentError] if any of the provided IDs don't exist.
  GraphOrderManager getOrderManagerSync([List<GraphId>? ids]);
}

class GraphImpl
    with Diagnosticable, ListenableSignalStateMixin<GraphData>
    implements Graph {
  GraphImpl() {
    state = signal(GraphData(id: GraphId.unique(GraphIdType.graph)));
  }

  @internal
  static GraphImpl of(BuildContext context) =>
      Provider.of(context, listen: false);

  @override
  late final Signal<GraphData> state;

  final Map<GraphId, List<GraphLinkData>> _nodeDependencies = {};

  void _checkEntityExists(GraphId id) {
    if (!state.value.nodes.containsKey(id) &&
        !state.value.links.containsKey(id)) {
      throw ArgumentError('entity not found: $id');
    }
  }

  @override
  GraphId get id => state.value.id;

  @override
  Iterable<GraphNode> get nodes => state.value.nodes.values;

  @override
  Iterable<GraphLink> get links => state.value.links.values;

  @override
  void addNode(GraphNodeImpl node) {
    node.onAdded(this);
    setState(state.value.copyWith(nodes: state.value.nodes.add(node.id, node)));
  }

  @override
  void addNodes(List<GraphNode> nodes) {
    for (final node in nodes.cast<GraphNodeImpl>()) {
      addNode(node);
    }
  }

  @override
  GraphNodeImpl? getNode(GraphId id) {
    return state.value.nodes[id] as GraphNodeImpl?;
  }

  GraphNode getNodeOrThrow(GraphId id) {
    final node = getNode(id);
    if (node != null) {
      return node;
    } else {
      throw ArgumentError('node not found: $id');
    }
  }

  @override
  bool hasNode(GraphId id) {
    return state.value.nodes.containsKey(id);
  }

  @override
  void removeNode(GraphId id) {
    if (!state.value.nodes.containsKey(id)) {
      throw ArgumentError('node not found: $id');
    }
    _nodeDependencies.remove(id);
    state.value = state.value.copyWith(nodes: state.value.nodes.remove(id));
  }

  @override
  void addLink(GraphLinkImpl link) {
    state.value =
        state.value.copyWith(links: state.value.links.add(link.id, link));
  }

  @override
  void addLinks(List<GraphLink> links) {
    for (final link in links.cast<GraphLinkImpl>()) {
      addLink(link);
    }
  }

  @override
  GraphLink? getLink(GraphId id) {
    return state.value.links[id];
  }

  GraphLink getLinkOrThrow(GraphId id) {
    final link = getLink(id);
    if (link != null) {
      return link;
    } else {
      throw ArgumentError('link not found: $id');
    }
  }

  @override
  List<GraphLink> getIncomingLinks(GraphId id) {
    return state.value.links.values
        .where((link) => link.target.id == id)
        .toList();
  }

  @override
  List<GraphLink> getOutgoingLinks(GraphId id) {
    return state.value.links.values
        .where((link) => link.source.id == id)
        .toList();
  }

  @override
  void removeLink(GraphId id) {
    if (!state.value.links.containsKey(id)) {
      throw ArgumentError('link not found: $id');
    }
    _nodeDependencies
        .removeWhere((key, value) => state.value.links.containsKey(key));
    state.value = state.value.copyWith(links: state.value.links.remove(id));
  }

  @override
  void reverseLink(GraphId id) {
    final link = getLinkOrThrow(id) as GraphLinkImpl;
    final source = link.source;
    final target = link.target;
    link
      ..target = source
      ..source = target;
  }

  @override
  List<GraphEntity> get selectedEntities {
    return selectedNodes.cast<GraphEntity>() +
        selectedLinks.cast<GraphEntity>();
  }

  @override
  List<GraphId> get selectedEntityIds => selectedNodeIds + selectedLinkIds;

  @override
  List<GraphNode> get selectedNodes =>
      state.value.selectedNodeIds.map(getNodeOrThrow).toList();

  @override
  List<GraphId> get selectedNodeIds => state.value.selectedNodeIds.toList();

  @override
  List<GraphLink> get selectedLinks =>
      state.value.selectedLinkIds.map(getLinkOrThrow).toList();

  @override
  List<GraphId> get selectedLinkIds => state.value.selectedLinkIds.toList();

  @override
  bool isSelected(GraphId id) {
    return state.value.selectedNodeIds.contains(id) ||
        state.value.selectedLinkIds.contains(id);
  }

  @override
  void selectNode(GraphId id) {
    final node = getNodeOrThrow(id) as GraphNodeImpl;
    if (!node.canSelect) {
      return;
    }

    node.isSelected = true;
    bringToFront(id);

    if (!state.value.allowMultiSelection) {
      state.value = state.value.copyWith(selectedNodeIds: IList([node.id]));
      for (final otherNode in nodes.cast<GraphNodeImpl>()) {
        if (otherNode.id != node.id) {
          otherNode.isSelected = false;
        }
      }
    } else {
      state.value = state.value
          .copyWith(selectedNodeIds: state.value.selectedNodeIds.add(node.id));
    }
  }

  @override
  void deselectNode(GraphId id) {
    final node = getNodeOrThrow(id) as GraphNodeImpl;
    node.isSelected = false;
    if (!state.value.allowMultiSelection) {
      state.value = state.value.copyWith(selectedNodeIds: const IListConst([]));
    } else {
      state.value = state.value.copyWith(
        selectedNodeIds: state.value.selectedNodeIds.remove(node.id),
      );
    }
  }

  @override
  void toggleSelectNode(GraphId id) {
    final node = getNodeOrThrow(id) as GraphNodeImpl;
    if (node.isSelected) {
      deselectNode(id);
    } else {
      selectNode(id);
    }
  }

  @override
  void selectLink(GraphId id) {
    final link = getLinkOrThrow(id) as GraphLinkImpl;
    if (!state.value.allowMultiSelection) {
      state.value = state.value.copyWith(selectedLinkIds: IList([link.id]));
    } else {
      state.value = state.value
          .copyWith(selectedLinkIds: state.value.selectedLinkIds.add(link.id));
    }
  }

  @override
  void deselectLink(GraphId id) {
    final link = getLinkOrThrow(id) as GraphLinkImpl;
    if (!state.value.allowMultiSelection) {
      state.value = state.value.copyWith(selectedLinkIds: const IListConst([]));
    } else {
      state.value = state.value.copyWith(
        selectedLinkIds: state.value.selectedLinkIds.remove(link.id),
      );
    }
  }

  @override
  void toggleSelectLink(GraphId id) {
    final link = getLinkOrThrow(id) as GraphLinkImpl;
    if (link.isSelected) {
      deselectLink(id);
    } else {
      selectLink(id);
    }
  }

  @override
  void markNeedsLayout() {
    state.value = state.value.copyWith(needsLayout: true);
  }

  @override
  void bringToFront(GraphId id) {
    final node = getNodeOrThrow(id) as GraphNodeImpl;
    final maxStackOrder = nodes
        .map((node) => node.stackOrder)
        .fold<int>(-1, (prev, current) => prev > current ? prev : current);
    node.stackOrder = maxStackOrder + 1;
  }

  @override
  GraphViewGeometry? get geometry => state.value.geometry;

  set geometry(GraphViewGeometry? geometry) {
    state.value = state.value.copyWith(geometry: geometry);
  }

  @override
  GraphOrderManager getOrderManager([List<GraphId>? ids]) {
    if (ids != null) {
      for (final id in ids) {
        _checkEntityExists(id);
      }
      return GraphOrderManager(this, ids);
    } else {
      return GraphOrderManager(
        this,
        [...state.value.nodes.keys, ...state.value.links.keys],
      );
    }
  }

  @override
  GraphOrderManager getOrderManagerSync([List<GraphId>? ids]) {
    if (ids != null) {
      for (final id in ids) {
        _checkEntityExists(id);
      }
      return GraphOrderManager(this, ids, sync: true);
    } else {
      return GraphOrderManager(
        this,
        [...state.value.nodes.keys, ...state.value.links.keys],
        sync: true,
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('id', id.toString()))
      ..add(IntProperty('nodes', nodes.length))
      ..add(IntProperty('links', links.length))
      ..add(
        DiagnosticsProperty<IList<GraphId>>(
          'selectedNodeIds',
          state.value.selectedNodeIds,
        ),
      )
      ..add(
        DiagnosticsProperty<IList<GraphId>>(
          'selectedLinkIds',
          state.value.selectedLinkIds,
        ),
      )
      ..add(
        FlagProperty(
          'allowSelection',
          value: state.value.allowSelection,
          ifTrue: 'allow',
          ifFalse: 'deny',
        ),
      )
      ..add(
        FlagProperty(
          'allowMultiSelection',
          value: state.value.allowMultiSelection,
          ifTrue: 'allow',
          ifFalse: 'deny',
        ),
      );
  }
}

extension GraphInternal on GraphImpl {
  bool get needsLayout => state.value.needsLayout;

  void onLayoutFinished() {
    state.overrideWith(state.value.copyWith(needsLayout: false));
    //state.value = state.value.copyWith(needsLayout: false);

    for (final node in nodes.cast<GraphNodeImpl>()) {
      node.isArranged = true;
    }
  }
}
