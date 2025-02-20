import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/graph.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/shape.dart';
import 'package:plough/src/renderer/style/node.dart';
import 'package:plough/src/renderer/widget/link.dart';
import 'package:plough/src/renderer/widget/node.dart';
import 'package:plough/src/tooltip/behavior.dart';
import 'package:plough/src/tooltip/widget/tooltip.dart';
import 'package:provider/provider.dart';

/// A function type for building node widgets.
///
/// The builder receives the node's context, graph, data, and optional child widget
/// and returns a customized widget for the node.
typedef GraphNodeWidgetBuilder = Widget Function(
  BuildContext context,
  Graph graph,
  GraphNode node,
  Widget? child,
);

/// Controls how nodes are rendered and how they interact with user input.
///
/// This class manages node visualization and interaction through a combination of
/// a custom widget builder, tooltip behavior, and an optional child widget.
/// It provides control over the visual representation of nodes and their
/// response to user interactions.
///
/// Use [GraphNodeViewBehavior.defaultBehavior] for standard node rendering
/// with configurable tooltip options and node styles. For custom node rendering,
/// provide your own [builder] function.
///
/// See also:
///
/// * [GraphTooltipBehavior], which defines tooltip display behavior
/// * [GraphDefaultNodeRenderer], which provides default node rendering
class GraphNodeViewBehavior {
  /// Creates a node view behavior with the specified configuration.
  const GraphNodeViewBehavior({
    required this.builder,
    this.tooltipBehavior,
    this.child,
  });

  /// Creates a default node view behavior with standard configuration.
  factory GraphNodeViewBehavior.defaultBehavior({
    GraphTooltipPosition tooltipPosition = GraphTooltipPosition.right,
    GraphTooltipTriggerMode tooltipTriggerMode = GraphTooltipTriggerMode.hover,
    GraphTooltipWidgetBuilder? tooltipBuilder,
    GraphDefaultNodeRendererWidgetBuilder? nodeRendererBuilder,
    GraphDefaultNodeRendererStyle nodeRendererStyle =
        const GraphDefaultNodeRendererStyle(),
    Widget? child,
  }) {
    return GraphNodeViewBehavior(
      tooltipBehavior: GraphTooltipBehavior(
        position: tooltipPosition,
        builder: tooltipBuilder ??
            (context, node) => GraphTooltip(node: node as GraphNode),
        triggerMode: tooltipTriggerMode,
      ),
      builder: nodeRendererBuilder ??
          (context, graph, node, child) {
            final s = node['label']?.toString() ??
                node.id.value.substring(node.id.value.length - 4);
            return GraphDefaultNodeRenderer(
              node: node,
              style: nodeRendererStyle,
              child: Center(
                child: Text(s),
              ),
            );
          },
      child: child,
    );
  }

  final Widget? child;
  final GraphNodeWidgetBuilder builder;
  final GraphTooltipBehavior? tooltipBehavior;
}

/// A function type for building link widgets.
///
/// The builder receives source and target node widgets, routing style,
/// connection geometry, and other parameters to create a customized link widget.
typedef GraphLinkWidgetBuilder = Widget Function(
  BuildContext context,
  Graph graph,
  GraphLink link,
  Widget sourceView,
  Widget targetView,
  GraphLinkRouting routing,
  GraphConnectionGeometry geometry,
  Widget? child,
);

/// A function type for dynamically calculating link thickness.
///
/// Use this to adjust link thickness based on properties or state of the link,
/// source node, or target node.
typedef GraphLinkWidgetThicknessGetter = double Function(
  BuildContext context,
  Graph graph,
  GraphLink link,
  Widget sourceView,
  Widget targetView,
);

/// Specifies how links connect between nodes.
///
/// * [straight] - Direct straight line connection
/// * [orthogonal] - Connection using horizontal and vertical line segments
enum GraphLinkRouting {
  straight,
  orthogonal,
}

/// Controls the visualization and interaction behavior of graph links.
///
/// This class manages how connections between nodes are rendered and how they
/// respond to user interaction. It provides control over link appearance
/// through customizable thickness, routing style, and tooltip behavior.
///
/// The link visualization can be customized through:
/// - Custom widget building with [builder]
/// - Link thickness control
/// - Routing style selection (straight or orthogonal)
/// - Optional tooltip display
///
/// See also:
///
/// * [GraphLinkRouting], which defines available routing styles
/// * [GraphDefaultLinkRenderer], which provides default link rendering
class GraphLinkViewBehavior {
  /// Creates a link view behavior with the specified configuration.
  const GraphLinkViewBehavior({
    required this.builder,
    this.thickness = 30,
    this.thicknessGetter,
    this.routing = GraphLinkRouting.straight,
    this.tooltipBehavior,
    this.child,
  });

  /// A function that builds the custom widget for rendering links.
  final GraphLinkWidgetBuilder builder;

  /// The default thickness of links in logical pixels.
  ///
  /// This value is used when [thicknessGetter] is not provided. A larger value
  /// makes the link easier to interact with but may take up more space visually.
  final double thickness;

  /// A function that dynamically calculates link thickness.
  ///
  /// When provided, this function is called to determine the thickness of each
  /// link individually. This allows for dynamic thickness based on link properties
  /// or state.
  final GraphLinkWidgetThicknessGetter? thicknessGetter;

  /// The routing style used to draw links between nodes.
  final GraphLinkRouting routing;

  /// Optional tooltip behavior configuration for links.
  ///
  /// When provided, enables tooltips for links with the specified behavior
  /// settings. This allows for additional information display on link interaction.
  final GraphTooltipBehavior? tooltipBehavior;

  /// An optional child widget to be used in link rendering.
  final Widget? child;
}

/// Coordinates the visual representation and interaction handling of a graph.
///
/// This interface serves as the central coordinator between:
/// - Visual representation through [GraphNodeViewBehavior] and [GraphLinkViewBehavior]
/// - Geometric calculations via [GraphCircle] and [GraphRectangle] models
/// - User interaction handling (selection, drag-drop, hover, tooltips)
///
/// The interface provides two key customization points:
/// - [createNodeViewBehavior] and [createLinkViewBehavior] for visual styling
/// - Event handlers like [onNodeSelect], [onLinkDragMove] for interaction logic
///
/// For most use cases, extend [GraphViewDefaultBehavior] and override specific
/// methods rather than implementing this interface directly.
///
/// See also:
///
/// * [GraphNodeViewBehavior], for node visualization control
/// * [GraphLinkViewBehavior], for link visualization control
/// * [GraphViewDefaultBehavior], for the standard implementation
abstract interface class GraphViewBehavior {
  /// Retrieves the [GraphViewBehavior] from the widget tree.
  @internal
  static GraphViewBehavior of(BuildContext context) =>
      Provider.of(context, listen: false);

  /// Creates the behavior configuration for node rendering.
  ///
  /// Override this method to customize how nodes are displayed and interact
  /// with user input.
  GraphNodeViewBehavior createNodeViewBehavior();

  /// Creates the behavior configuration for link rendering.
  ///
  /// Override this method to customize how links between nodes are displayed
  /// and interact with user input.
  GraphLinkViewBehavior createLinkViewBehavior();

  /// Calculates connection points between two nodes.
  ///
  /// Returns intersection points where links should connect to the nodes'
  /// shapes, based on their current geometry.
  GraphConnectionPoints? getConnectionPoints(
    GraphNode source,
    GraphNode target,
    Widget sourceWidget,
    Widget targetWidget,
  );

  /// Tests if a node contains the given position.
  ///
  /// Used for hit testing in mouse interactions and event handling.
  bool hitTestNode(covariant GraphNode node, Offset position);

  /// Tests if a link contains the given position.
  ///
  /// Used for hit testing in mouse interactions and event handling.
  bool hitTestLink(covariant GraphLink link, Offset position);

  /// Called when nodes are selected or deselected.
  void onNodeSelect(List<GraphNode> nodes, {required bool isSelected});

  /// Called when nodes are tapped.
  void onNodeTap(List<GraphNode> nodes);

  /// Called when nodes are double-tapped.
  void onNodeDoubleTap(List<GraphNode> nodes);

  /// Called when a drag operation starts on nodes.
  void onNodeDragStart(List<GraphNode> nodes);

  /// Called during a drag operation on nodes.
  void onNodeDragUpdate(List<GraphNode> nodes);

  /// Called when a drag operation on nodes completes.
  void onNodeDragEnd(List<GraphNode> nodes);

  /// Called while nodes are being dragged.
  void onNodeDragMove(List<GraphNode> nodes);

  /// Called when the mouse enters a node's area.
  void onNodeMouseEnter(GraphNode node);

  /// Called when the mouse exits a node's area.
  void onNodeMouseExit(GraphNode node);

  /// Called while the mouse is hovering over a node.
  void onNodeMouseHover(GraphNode node);

  /// Called when mouse hover over a node ends.
  void onNodeHoverEnd(GraphNode node);

  /// Called when a node's tooltip is about to be shown.
  void onNodeTooltipShow(GraphNode node);

  /// Called when a node's tooltip is about to be hidden.
  void onNodeTooltipHide(GraphNode node);

  /// Called when links are selected or deselected.
  void onLinkSelect(List<GraphLink> links, {required bool isSelected});

  /// Called when links are tapped.
  void onLinkTap(List<GraphLink> links);

  /// Called when links are double-tapped.
  void onLinkDoubleTap(List<GraphLink> links);

  /// Called when a drag operation starts on links.
  void onLinkDragStart(List<GraphLink> links);

  /// Called during a drag operation on links.
  void onLinkDragUpdate(List<GraphLink> links);

  /// Called when a drag operation on links completes.
  void onLinkDragEnd(List<GraphLink> links);

  /// Called while links are being dragged.
  void onLinkDragMove(List<GraphLink> links);

  /// Called when the mouse enters a link's area.
  void onLinkMouseEnter(GraphLink link);

  /// Called when the mouse exits a link's area.
  void onLinkMouseExit(GraphLink link);

  /// Called while the mouse is hovering over a link.
  void onLinkMouseHover(GraphLink link);

  /// Called when mouse hover over a link ends.
  void onLinkHoverEnd(GraphLink link);

  /// Called when a link's tooltip is about to be shown.
  void onLinkTooltipShow(GraphLink link);

  /// Called when a link's tooltip is about to be hidden.
  void onLinkTooltipHide(GraphLink link);
}

/// A default implementation of graph view behavior with standard visualization features.
///
/// This implementation provides a complete set of basic graph visualization features
/// including node rendering, link visualization, and user interaction handling.
/// It serves both as a ready-to-use behavior and as a base class for custom behaviors.
///
/// The default behavior includes:
/// - Standard node rendering with labels and tooltips
/// - Link visualization with arrow indicators
/// - Basic interaction handling like selection and drag operations
/// - Mouse hover effects
///
/// To customize specific aspects, extend this class and override only the
/// methods that need different behavior. The default implementation provides
/// a solid foundation for most graph visualization needs.
///
/// See also:
///
/// * [GraphViewBehavior], which defines the interface implemented by this class
/// * [GraphNodeViewBehavior], for node-specific behavior
/// * [GraphLinkViewBehavior], for link-specific behavior
class GraphViewDefaultBehavior implements GraphViewBehavior {
  /// Creates a default view behavior with optional [linkRouting] configuration.
  const GraphViewDefaultBehavior({
    this.linkRouting = GraphLinkRouting.straight,
  });

  /// The routing style to use for links in this behavior.
  ///
  /// Determines how links are drawn between nodes, either as straight lines
  /// or using orthogonal routing.
  final GraphLinkRouting linkRouting;

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    return GraphNodeViewBehavior.defaultBehavior();
  }

  @override
  GraphLinkViewBehavior createLinkViewBehavior() {
    const thickness = 30.0;
    return GraphLinkViewBehavior(
      builder: (
        context,
        graph,
        link,
        sourceView,
        targetView,
        routing,
        geometry,
        _,
      ) =>
          GraphDefaultLinkRenderer(
        link: link,
        sourceView: sourceView,
        targetView: targetView,
        routing: routing,
        geometry: geometry,
        thickness: thickness,
      ),
      routing: linkRouting,
    );
  }

  @override
  GraphConnectionPoints? getConnectionPoints(
    GraphNode source,
    GraphNode target,
    Widget sourceWidget,
    Widget targetWidget,
  ) {
    final outgoing = _getLineIntersections(source, target);
    final incoming = _getLineIntersections(target, source);

    if (outgoing == null || incoming == null) {
      return null;
    }
    return GraphConnectionPoints(outgoing: outgoing, incoming: incoming);
  }

  /// Calculates intersection points between a line and a node's shape.
  ///
  /// Returns the first intersection point found, or null if no intersections exist.
  Offset? _getLineIntersections(GraphNode source, GraphNode target) {
    final line = GraphLine(
      source.geometry!.bounds.center,
      target.geometry!.bounds.center,
    );
    final intersections =
        source.shape!.getLineIntersections(source.geometry!.bounds, line);
    if (intersections.isEmpty) {
      return null;
    }
    return intersections.first;
  }

  @override
  bool hitTestNode(GraphNodeImpl node, Offset position) {
    final geometry = node.geometry;
    if (geometry == null || !node.visible || node.isAnimating) return false;
    return geometry.bounds.contains(position);
  }

  @override
  bool hitTestLink(GraphLinkImpl link, Offset position) {
    final geometry = link.geometry;
    if (geometry == null || !link.visible) return false;
    return geometry.containsPoint(position);
  }

  @override
  void onNodeSelect(List<GraphNode> nodes, {required bool isSelected}) {}

  @override
  void onNodeTap(List<GraphNode> nodes) {}

  @override
  void onNodeDoubleTap(List<GraphNode> nodes) {}

  @override
  void onNodeDragEnd(List<GraphNode> nodes) {}

  @override
  void onNodeDragStart(List<GraphNode> nodes) {}

  @override
  void onNodeDragUpdate(List<GraphNode> nodes) {}

  @override
  void onNodeDragMove(List<GraphNode> nodes) {}

  @override
  void onNodeMouseEnter(GraphNode node) {}

  @override
  void onNodeMouseExit(GraphNode node) {}

  @override
  void onNodeMouseHover(GraphNode node) {}

  @override
  void onNodeHoverEnd(GraphNode node) {}

  @override
  void onNodeTooltipShow(GraphNode node) {}

  @override
  void onNodeTooltipHide(GraphNode node) {}

  @override
  void onLinkSelect(List<GraphLink> links, {required bool isSelected}) {}

  @override
  void onLinkTap(List<GraphLink> links) {}

  @override
  void onLinkDoubleTap(List<GraphLink> links) {}

  @override
  void onLinkDragEnd(List<GraphLink> links) {}

  @override
  void onLinkDragStart(List<GraphLink> links) {}

  @override
  void onLinkDragUpdate(List<GraphLink> links) {}

  @override
  void onLinkDragMove(List<GraphLink> links) {}

  @override
  void onLinkMouseEnter(GraphLink link) {}

  @override
  void onLinkMouseExit(GraphLink link) {}

  @override
  void onLinkMouseHover(GraphLink link) {}

  @override
  void onLinkHoverEnd(GraphLink link) {}

  @override
  void onLinkTooltipShow(GraphLink link) {}

  @override
  void onLinkTooltipHide(GraphLink link) {}
}
