import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/layout_strategy/base.dart';

/// Callback for selecting the root node of the tree layout.
///
/// Takes a collection of all nodes and returns the ID of the node to use as root.
typedef GraphTreeLayoutRootNodeSelector = GraphId Function(
  Iterable<GraphNode> nodes,
);

/// Callback for determining the order of sibling nodes in the tree.
///
/// Returns:
/// * Negative value - a should be placed before b
/// * Positive value - a should be placed after b
/// * Zero - order is arbitrary
typedef GraphTreeLayoutSiblingNodeComparator = int Function(
  GraphNode a,
  GraphNode b,
);

/// Specifies the direction in which the tree should expand.
enum GraphTreeLayoutDirection {
  /// Root at top, expanding downward
  topToBottom,

  /// Root at bottom, expanding upward
  bottomToTop,

  /// Root at left, expanding rightward
  leftToRight,

  /// Root at right, expanding leftward
  rightToLeft,
}

/// A layout strategy that arranges nodes in a hierarchical tree structure.
///
/// Key features:
///
/// - Configurable [direction] for tree expansion
/// - Root node selection via [rootNodeId] or [rootNodeSelector]
/// - Customizable sibling ordering with [siblingNodeComparator]
///
/// Example:
/// ```dart
/// // Arrange nodes top-to-bottom with root at the top
/// final layout = GraphTreeLayoutStrategy(
///   direction: GraphTreeLayoutDirection.topToBottom,
///   rootNodeId: rootNode.id,
///   siblingNodeComparator: (a, b) {
///     // Order siblings by their labels
///     return a['label'].compareTo(b['label']);
///   },
/// );
///
/// return GraphView(
///   graph: graph,
///   layoutStrategy: layout,
/// );
/// ```
base class GraphTreeLayoutStrategy extends GraphLayoutStrategy {
  /// Creates a tree layout strategy with required direction and optional configuration.
  GraphTreeLayoutStrategy({
    required this.direction,
    super.seed,
    super.padding,
    super.nodePositions,
    this.rootNodeId,
    this.rootNodeSelector,
    this.siblingNodeComparator,
  });

  /// ツリーの展開方向
  final GraphTreeLayoutDirection direction;

  /// ルートノードのID
  final GraphId? rootNodeId;

  /// Callback for selecting the root node.
  ///
  /// Used only if [rootNodeId] is not provided. If neither is specified,
  /// the node with the fewest incoming edges is selected as root.
  final GraphTreeLayoutRootNodeSelector? rootNodeSelector;

  /// Callback for determining the order of sibling nodes at each level.
  ///
  /// When null, siblings maintain their original order in the graph.
  final GraphTreeLayoutSiblingNodeComparator? siblingNodeComparator;

  /// Whether the layout expands horizontally (left-to-right or right-to-left).
  ///
  /// Used internally to determine axis-specific layout calculations.
  bool get isHorizontal =>
      direction == GraphTreeLayoutDirection.leftToRight ||
      direction == GraphTreeLayoutDirection.rightToLeft;

  @override
  bool shouldRelayout(covariant GraphTreeLayoutStrategy oldStrategy) {
    return direction != oldStrategy.direction ||
        rootNodeId != oldStrategy.rootNodeId ||
        padding != oldStrategy.padding ||
        !const IterableEquality<GraphNodeLayoutPosition>()
            .equals(nodePositions, oldStrategy.nodePositions);
  }

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    if (graph.nodes.isEmpty) return;

    final rootNode = _determineRootNode(graph);
    if (rootNode == null) return;

    final treeStructure = _buildTreeStructure(graph, rootNode);
    _applyTreeLayout(graph, treeStructure, size);
  }

  GraphNode? _determineRootNode(Graph graph) {
    if (rootNodeId != null) {
      return graph.getNode(rootNodeId!);
    }

    if (rootNodeSelector != null) {
      final selectedId = rootNodeSelector!(graph.nodes);
      return graph.getNode(selectedId);
    }

    return graph.nodes.reduce((a, b) {
      final aInDegree = graph.getIncomingLinks(a.id).length;
      final bInDegree = graph.getIncomingLinks(b.id).length;
      return aInDegree <= bInDegree ? a : b;
    });
  }

  Map<int, List<_TreeNode>> _buildTreeStructure(Graph graph, GraphNode root) {
    final visited = <GraphId>{};
    final levelMap = <int, List<_TreeNode>>{};

    void traverse(_TreeNode parent) {
      if (visited.contains(parent.node.id)) return;
      visited.add(parent.node.id);

      levelMap.putIfAbsent(parent.level, () => []).add(parent);

      final children = graph
          .getOutgoingLinks(parent.node.id)
          .map((link) => link.target)
          .where((node) => !visited.contains(node.id))
          .map((node) => _TreeNode(node, parent.level + 1))
          .toList();

      if (siblingNodeComparator != null) {
        children.sort((a, b) => siblingNodeComparator!(a.node, b.node));
      }

      parent.children.addAll(children);
      for (final child in children) {
        traverse(child);
      }
    }

    traverse(_TreeNode(root, 0));
    return levelMap;
  }

  void _applyTreeLayout(
    Graph graph,
    Map<int, List<_TreeNode>> levelMap,
    Size size,
  ) {
    if (levelMap.isEmpty) return;

    final maxLevel = levelMap.keys.reduce(math.max);
    // TODO: 指定可能にする
    const levelSpacing = 100.0;
    const minNodeSpacing = 60.0;

    // 各レベルのノード位置を計算
    final xPositions = <GraphId, double>{};

    // ルートノードの配置
    final rootLevel = levelMap[0] ?? [];
    if (rootLevel.isNotEmpty) {
      xPositions[rootLevel[0].node.id] = 0;
    }

    // 各レベルのノードを配置
    for (var level = 0; level <= maxLevel; level++) {
      final nodes = levelMap[level] ?? [];
      double currentX = 0;

      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i].node;
        final nodeSize = getNodeSize(node) ?? const Size(50, 50);

        if (i == 0) {
          if (level == 0) {
            currentX = 0;
          } else {
            final parents = graph
                .getIncomingLinks(node.id)
                .map((link) => link.source)
                .where((parent) => xPositions.containsKey(parent.id));

            if (parents.isNotEmpty) {
              currentX = parents.map((p) => xPositions[p.id]!).reduce(math.min);
            }
          }
        }

        xPositions[node.id] = currentX;
        currentX += nodeSize.width + minNodeSpacing;
      }
    }

    // X座標の中央寄せ
    final minX = xPositions.values.reduce(math.min);
    final maxX = xPositions.values.reduce(math.max);
    final totalWidth = maxX - minX;
    final centerOffset = (size.width - totalWidth) / 2 - minX;

    // 最終的なノード位置を設定
    for (var level = 0; level <= maxLevel; level++) {
      final nodes = levelMap[level] ?? [];
      final y = level * levelSpacing + padding.top;

      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i].node;
        final x = xPositions[node.id]! + centerOffset;
        positionNode(node, Offset(x, y));
      }
    }
  }
}

/// Internal representation of a node in the tree structure.
///
/// Stores the node's level in the hierarchy and its child nodes.
class _TreeNode {
  _TreeNode(this.node, this.level);

  final GraphNode node;
  final int level;
  final List<_TreeNode> children = [];
}
