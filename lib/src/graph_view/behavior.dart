import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/graph.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/inherited_data.dart';
import 'package:plough/src/graph_view/shape.dart';
import 'package:plough/src/interactive/events.dart';
import 'package:plough/src/renderer/style/node.dart';
import 'package:plough/src/renderer/widget/link.dart';
import 'package:plough/src/renderer/widget/node.dart';
import 'package:plough/src/tooltip/behavior.dart';
import 'package:plough/src/tooltip/widget/tooltip.dart';

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
              child: Center(child: Text(s)),
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
enum GraphLinkRouting { straight, orthogonal }

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
/// - User interaction handling via dispatched [GraphEvent]s.
///
/// The interface provides two key customization points:
/// - [createNodeViewBehavior] and [createLinkViewBehavior] for visual styling
/// - Event handlers like [onTap], [onSelectionChange] for interaction logic
///
/// For most use cases, extend [GraphViewDefaultBehavior] and override specific
/// methods rather than implementing this interface directly.
///
/// See also:
///
/// * [GraphNodeViewBehavior], for node visualization control
/// * [GraphLinkViewBehavior], for link visualization control
/// * [GraphViewDefaultBehavior], for the standard implementation
/// * [GraphEvent], for the base class of all interaction events
abstract interface class GraphViewBehavior {
  /// Retrieves the [GraphViewBehavior] from the widget tree.
  @internal
  static GraphViewBehavior of(BuildContext context) =>
      GraphInheritedData.read(context).behavior;

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

  /// Called when entities are tapped (single or double).
  void onTap(GraphTapEvent event);

  /// Called when entities are double-tapped.
  void onDoubleTap(GraphTapEvent event);

  /// Called when the selection changes.
  void onSelectionChange(GraphSelectionChangeEvent event);

  /// Called when a drag operation starts on entities.
  void onDragStart(GraphDragStartEvent event);

  /// Called during a drag operation on entities.
  /// Use [event.delta] for positional changes.
  void onDragUpdate(GraphDragUpdateEvent event);

  /// Called when a drag operation on entities completes.
  void onDragEnd(GraphDragEndEvent event);

  /// Called when the mouse pointer enters an entity's area.
  void onHoverEnter(GraphHoverEvent event);

  /// Called when the mouse pointer moves within an entity's area.
  void onHoverMove(GraphHoverEvent event);

  /// Called when the mouse pointer leaves an entity's area.
  void onHoverEnd(GraphHoverEndEvent event);

  /// Called when an entity's tooltip is shown.
  void onTooltipShow(GraphTooltipShowEvent event);

  /// Called when an entity's tooltip is hidden.
  void onTooltipHide(GraphTooltipHideEvent event);

  /// Compares this behavior with another for content equality.
  ///
  /// This method should return true if the behaviors would produce
  /// the same visual result and interaction handling. It's used to
  /// avoid unnecessary re-initialization during widget updates.
  ///
  /// The default implementation compares runtime types only.
  /// Override this method to provide content-based comparison.
  bool isEquivalentTo(GraphViewBehavior other) {
    return runtimeType == other.runtimeType;
  }
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
/// - Basic interaction handling like selection and drag operations via event callbacks
/// - Mouse hover effects
///
/// To customize specific aspects, extend this class and override only the
/// methods that need different behavior (e.g., override `onTap` to handle taps).
/// The default implementation provides a solid foundation for most graph
/// visualization needs.
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
    const thickness = 30.0; // Consider making this configurable
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
      // Default tooltip behavior for links could be added here if desired
      // tooltipBehavior: GraphTooltipBehavior(...)
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
    final intersections = source.shape!.getLineIntersections(
      source.geometry!.bounds,
      line,
    );
    if (intersections.isEmpty) {
      return null;
    }
    return intersections.first;
  }

  @override
  bool hitTestNode(GraphNodeImpl node, Offset position) {
    final geometry = node.geometry;
    if (geometry == null || !node.visible) return false;

    // Enable hit testing even during animation
    // Use current animation position during animation
    if (node.isAnimating) {
      final animatedPosition = node.animatedPosition;
      final bounds = Rect.fromLTWH(
        animatedPosition.dx,
        animatedPosition.dy,
        geometry.bounds.width,
        geometry.bounds.height,
      );
      return bounds.contains(position);
    }

    return geometry.bounds.contains(position);
  }

  @override
  bool hitTestLink(GraphLinkImpl link, Offset position) {
    final geometry = link.geometry;
    if (geometry == null || !link.visible) return false;
    return geometry.containsPoint(position);
  }

  // Default implementations for the new event handlers are empty.
  // Users extending this class will override the methods they need.

  @override
  void onTap(GraphTapEvent event) {}

  @override
  void onDoubleTap(GraphTapEvent event) {}

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) {}

  @override
  void onDragStart(GraphDragStartEvent event) {}

  @override
  void onDragUpdate(GraphDragUpdateEvent event) {}

  @override
  void onDragEnd(GraphDragEndEvent event) {}

  @override
  void onHoverEnter(GraphHoverEvent event) {}

  @override
  void onHoverMove(GraphHoverEvent event) {}

  @override
  void onHoverEnd(GraphHoverEndEvent event) {}

  @override
  void onTooltipShow(GraphTooltipShowEvent event) {}

  @override
  void onTooltipHide(GraphTooltipHideEvent event) {}

  @override
  bool isEquivalentTo(GraphViewBehavior other) {
    if (other is! GraphViewDefaultBehavior) return false;
    return linkRouting == other.linkRouting;
  }
}
