import 'package:collection/collection.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/widget/graph.dart';

/// A utility class for managing the ordering of graph entities.
///
/// [GraphOrderManager] provides operations to modify the display order of entities without
/// affecting the underlying graph structure. While receiving order updates through graph
/// synchronization, changes made via this manager remain isolated from the graph's entity
/// sequence.
///
/// This separation allows for flexible ordering strategies:
/// - View-specific entity arrangements
/// - Z-index management for rendering
/// - Temporary order adjustments for visual effects
///
/// The manager works independently of the graph's internal ordering, making it suitable for
/// implementing specialized display behaviors or creating multiple views with different
/// entity orderings from the same graph data.
///
/// See also:
///
/// * [Graph], which provides the entity data for ordering.
/// * [GraphView], which uses these orderings for visualization.
/// * [GraphEntity], whose display order is managed.
class GraphOrderManager {
  GraphOrderManager(
    this.graph,
    Iterable<GraphId> entityIds, {
    this.sync = false,
  }) {
    _entityIds.addAll(entityIds);
    _removeUnavailableEntities();

    if (sync) {
      graph.addListener(_onGraphChanged);
    }
  }

  /// The graph whose entities are being managed.
  final Graph graph;

  /// Whether to automatically synchronize with graph changes.
  final bool sync;

  final _entityIds = <GraphId>[];

  /// The IDs of the managed entities in their current order.
  List<GraphId> get entityIds => _entityIds;

  /// Updates entity list when graph changes occur.
  void _onGraphChanged() {
    _removeUnavailableEntities();
  }

  /// Releases resources and removes graph change listeners if [sync] is true.
  void dispose() {
    if (sync) {
      graph.removeListener(_onGraphChanged);
    }
  }

  /// Creates a copy of this manager with optional new [entityIds].
  GraphOrderManager copyWith({
    Iterable<GraphId>? entityIds,
  }) {
    return GraphOrderManager(graph, entityIds ?? _entityIds);
  }

  /// Returns true if no entities are being managed.
  bool get isEmpty => _entityIds.isEmpty;

  void _removeUnavailableEntities() {
    _entityIds.removeWhere((id) => _getEntity(id) == null);
  }

  /// The managed entities in their current order.
  ///
  /// Updates when entities are reordered or synchronized with the graph.
  List<GraphEntity> get entities =>
      _entityIds.map(_getEntity).whereType<GraphEntity>().toList();

  GraphEntity? _getEntity(GraphId entityId) =>
      _getNode(entityId) ?? _getLink(entityId);

  GraphNode? _getNode(GraphId entityId) => graph.getNode(entityId);

  GraphLink? _getLink(GraphId entityId) => graph.getLink(entityId);

  /// The IDs of all nodes being managed.
  List<GraphId> get nodeIds =>
      _entityIds.where((id) => _getNode(id) != null).toList();

  /// The IDs of all links being managed.
  List<GraphId> get linkIds =>
      _entityIds.where((id) => _getLink(id) != null).toList();

  /// All nodes being managed, in their current order.
  List<GraphNode> get nodes =>
      nodeIds.map(_getNode).whereType<GraphNode>().toList();

  /// All links being managed, in their current order.
  List<GraphLink> get links =>
      linkIds.map(_getLink).whereType<GraphLink>().toList();

  /// Removes all entities from management.
  void clear() {
    _entityIds.clear();
  }

  /// Adds the entity with [entityId] to be managed.
  void add(GraphId entityId) {
    _entityIds.add(entityId);
  }

  /// Adds multiple entities to be managed.
  void addAll(List<GraphId> entityIds) {
    _entityIds.addAll(entityIds);
  }

  /// Removes the entity with [entityId] from management.
  void remove(GraphId entityId) {
    _entityIds.remove(entityId);
  }

  /// Removes entities that don't satisfy the [predicate].
  void filter(bool Function(GraphId entityId) predicate) {
    _entityIds.removeWhere((entityId) => !predicate(entityId));
  }

  /// Returns a new manager containing only entities that satisfy the [predicate].
  GraphOrderManager filteredBy(bool Function(GraphEntity) predicate) {
    return copyWith()
      ..filter((entityId) {
        final entity = _getEntity(entityId);
        return entity != null && predicate(entity);
      });
  }

  void filterByNode() {
    _entityIds.removeWhere((id) => _getNode(id) != null);
  }

  GraphOrderManager filteredByNode() {
    return copyWith()..filterByNode();
  }

  void filterByLink() {
    _entityIds.removeWhere((id) => _getLink(id) != null);
  }

  List<GraphId> filteredByLink() {
    return (copyWith()..filterByLink()).entityIds;
  }

  /// Sorts entities using the provided [comparator] function.
  void sortBy(int Function(GraphEntity entity) comparator) {
    _entityIds.sort((a, b) {
      final entityA = _getEntity(a);
      final entityB = _getEntity(b);
      if (entityA == null || entityB == null) return 0;
      return comparator(entityA).compareTo(comparator(entityB));
    });
  }

  List<GraphId> sortedBy(int Function(GraphEntity entity) comparator) {
    return (copyWith()..sortBy(comparator)).entityIds;
  }

  /// Sorts entities by their stack order, from lowest to highest.
  void sortByStackOrder() {
    sortBy((entity) => entity.stackOrder);
  }

  /// Returns a new list of entity IDs sorted by stack order.
  List<GraphId> sortedByStackOrder() {
    return sortedBy((entity) => entity.stackOrder);
  }

  /// Returns the node with the highest stack order, or null if no nodes exist.
  GraphNode? get frontmostNode {
    final nodes = this.nodes;
    if (nodes.isEmpty) {
      return null;
    } else {
      return nodes.fold<GraphNode>(
        nodes.first,
        (prev, node) => node.stackOrder > prev.stackOrder ? node : prev,
      );
    }
  }

  /// Returns the node with the lowest stack order, or null if no nodes exist.
  GraphNode? get backmostNode {
    final nodes = this.nodes;
    if (nodes.isEmpty) {
      return null;
    } else {
      return nodes.fold<GraphNode>(
        nodes.first,
        (prev, node) => node.stackOrder < prev.stackOrder ? node : prev,
      );
    }
  }

  /// Returns the frontmost entity that satisfies the [predicate], or null if none exist.
  GraphEntity? frontmostWhereOrNull(
    bool Function(GraphEntity entity) predicate,
  ) {
    final id = _entityIds.firstWhereOrNull((id) {
      final entity = _getEntity(id);
      return entity != null && predicate(entity);
    });
    return id != null ? _getEntity(id) : null;
  }

  /// Returns the highest stack order among all managed entities.
  int get maxStackOrder => entities
      .map((entity) => entity.stackOrder)
      .fold<int>(-1, (prev, current) => prev > current ? prev : current);
}
