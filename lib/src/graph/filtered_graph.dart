import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph_view/geometry.dart';

/// A read-through view of a [Graph] that omits hidden entities.
///
/// Layout strategies see only what is drawn: they receive this instead of the
/// real graph, so a filtered graph closes up around its remaining nodes rather
/// than arranging them around gaps left by nodes nobody can see. Everything
/// else — selection, ordering, mutation — passes straight through to the
/// wrapped graph, which remains the single source of truth.
///
/// Traversal is filtered consistently: [nodes], [links], [getNode], [getLink]
/// and the incoming/outgoing link queries all behave as though the hidden
/// entities were absent, so a strategy walking the graph cannot reach one by a
/// side path and place it.
///
/// This is internal to [GraphView]; applications hide entities through
/// `GraphView.hiddenNodeIds` or [GraphEntity.visible].
@internal
class FilteredGraph implements Graph {
  /// Wraps [inner], exposing only entities [isNodeVisible]/[isLinkVisible] accept.
  FilteredGraph(
    this.inner, {
    required this.isNodeVisible,
    required this.isLinkVisible,
  });

  /// The graph being filtered. Mutations and selection go here unchanged.
  final Graph inner;

  /// Whether a node is part of this view.
  final bool Function(GraphNode node) isNodeVisible;

  /// Whether a link is part of this view.
  final bool Function(GraphLink link) isLinkVisible;

  @override
  Iterable<GraphNode> get nodes => inner.nodes.where(isNodeVisible);

  @override
  Iterable<GraphLink> get links => inner.links.where(isLinkVisible);

  @override
  GraphNode? getNode(GraphId id) {
    final node = inner.getNode(id);
    return node != null && isNodeVisible(node) ? node : null;
  }

  @override
  bool hasNode(GraphId id) => getNode(id) != null;

  @override
  GraphLink? getLink(GraphId id) {
    final link = inner.getLink(id);
    return link != null && isLinkVisible(link) ? link : null;
  }

  @override
  List<GraphLink> getIncomingLinks(GraphId nodeId) =>
      inner.getIncomingLinks(nodeId).where(isLinkVisible).toList();

  @override
  List<GraphLink> getOutgoingLinks(GraphId nodeId) =>
      inner.getOutgoingLinks(nodeId).where(isLinkVisible).toList();

  // Selection is reported filtered as well, so a strategy or caller reading it
  // through this view never learns about an entity the view is hiding.

  @override
  List<GraphEntity> get selectedEntities =>
      [...selectedNodes, ...selectedLinks];

  @override
  List<GraphId> get selectedEntityIds =>
      selectedEntities.map((e) => e.id).toList();

  @override
  List<GraphNode> get selectedNodes =>
      inner.selectedNodes.where(isNodeVisible).toList();

  @override
  List<GraphId> get selectedNodeIds => selectedNodes.map((n) => n.id).toList();

  @override
  List<GraphLink> get selectedLinks =>
      inner.selectedLinks.where(isLinkVisible).toList();

  @override
  List<GraphId> get selectedLinkIds => selectedLinks.map((l) => l.id).toList();

  @override
  bool isSelected(GraphId id) =>
      (getNode(id) != null || getLink(id) != null) && inner.isSelected(id);

  // Everything below is pass-through: this is a view, not a copy, so mutation
  // and identity belong to the wrapped graph.

  @override
  GraphId get id => inner.id;

  @override
  GraphViewGeometry? get geometry => inner.geometry;

  @override
  void addNode(GraphNode node) => inner.addNode(node);

  @override
  void addNodes(List<GraphNode> nodes) => inner.addNodes(nodes);

  @override
  void removeNode(GraphId id) => inner.removeNode(id);

  @override
  void addLink(GraphLink link) => inner.addLink(link);

  @override
  void addLinks(List<GraphLink> links) => inner.addLinks(links);

  @override
  void removeLink(GraphId id) => inner.removeLink(id);

  @override
  void reverseLink(GraphId id) => inner.reverseLink(id);

  @override
  void selectNode(GraphId id) => inner.selectNode(id);

  @override
  void deselectNode(GraphId id) => inner.deselectNode(id);

  @override
  void toggleSelectNode(GraphId id) => inner.toggleSelectNode(id);

  @override
  void selectLink(GraphId id) => inner.selectLink(id);

  @override
  void deselectLink(GraphId id) => inner.deselectLink(id);

  @override
  void toggleSelectLink(GraphId id) => inner.toggleSelectLink(id);

  @override
  void clearSelection() => inner.clearSelection();

  @override
  void markNeedsLayout({bool shouldAnimate = false}) =>
      inner.markNeedsLayout(shouldAnimate: shouldAnimate);

  @override
  void bringToFront(GraphId id) => inner.bringToFront(id);

  @override
  GraphOrderManager getOrderManager([List<GraphId>? ids]) =>
      inner.getOrderManager(ids);

  @override
  GraphOrderManager getOrderManagerSync([List<GraphId>? ids]) =>
      inner.getOrderManagerSync(ids);

  @override
  Map<GraphId, Offset> nodePositionSnapshot({bool includeUnarranged = false}) =>
      inner.nodePositionSnapshot(includeUnarranged: includeUnarranged);

  @override
  void addListener(VoidCallback listener) => inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => inner.removeListener(listener);
}
