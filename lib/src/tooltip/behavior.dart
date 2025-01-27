// activate

import 'package:flutter/material.dart';
import 'package:plough/src/graph/entity.dart';

/// A builder for creating tooltip widgets for graph entities.
///
/// The builder provides [context] for widget building and [entity] representing
/// the node or link that triggered the tooltip.
///
/// Example usage:
/// ```dart
/// GraphTooltipBehavior(
///   position: GraphTooltipPosition.right,
///   triggerMode: GraphTooltipTriggerMode.hover,
///   builder: (context, entity) => Container(
///     padding: const EdgeInsets.all(8),
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(4),
///       boxShadow: [
///         BoxShadow(
///           color: Colors.black.withOpacity(0.1),
///           blurRadius: 4,
///         ),
///       ],
///     ),
///     child: Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         Text(entity['label'] as String),
///         const SizedBox(height: 4),
///         Text(
///           entity['description'] as String,
///           style: Theme.of(context).textTheme.bodySmall,
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
typedef GraphTooltipWidgetBuilder = Widget Function(
  BuildContext context,
  GraphEntity entity,
);

/// Defines when tooltips should be displayed in response to user interactions.
///
/// This enum determines the trigger behavior for showing and hiding tooltips
/// in the graph visualization. Each mode provides different interaction patterns
/// to suit various use cases.
///
/// See also:
///
///  * [GraphTooltipBehavior], which uses this enum to configure tooltip triggers
///  * [GraphTooltipPosition], which controls where tooltips appear relative to entities
enum GraphTooltipTriggerMode {
  /// Shows the tooltip when the entity is tapped
  tap,

  /// Shows the tooltip when the entity is double-tapped
  doubleTap,

  /// Shows the tooltip when the entity is long-pressed
  longPress,

  /// Shows the tooltip while the pointer is hovering over the entity
  hover,

  /// Shows the tooltip when hovered and keeps it visible after the pointer leaves
  hoverStay,
}

/// Specifies where tooltips appear relative to their target entities.
///
/// The position affects the tooltip's placement in relation to the node or link
/// that triggered it. Choose the position that best fits your layout and prevents
/// tooltips from being clipped or obscured.
///
/// See also:
///
///  * [GraphTooltipBehavior], which uses this enum to configure tooltip placement
///  * [GraphTooltipTriggerMode], which determines when tooltips are shown
enum GraphTooltipPosition {
  /// Places the tooltip above the target entity
  top,

  /// Places the tooltip below the target entity
  bottom,

  /// Places the tooltip to the left of the target entity
  left,

  /// Places the tooltip to the right of the target entity
  right,
}

/// Controls the display and behavior of tooltips for graph entities.
///
/// This class manages when and how tooltips appear in response to user
/// interactions with nodes and links in the graph. It provides customization
/// for timing, positioning, and content of tooltips through a builder pattern.
///
/// ## Interaction modes
///
/// Tooltips can be triggered in several ways through [triggerMode]:
/// - Immediate response to taps or hovers
/// - Delayed showing with [showDelay]
/// - Persistent display using [GraphTooltipTriggerMode.hoverStay]
///
/// ## Customization
///
/// The tooltip's appearance is fully customizable through the [builder] function,
/// allowing for rich content display including multiple widgets, custom styling,
/// and dynamic data presentation.
///
/// Example usage:
/// ```dart
/// GraphViewBehavior.defaultBehavior(
///   tooltipPosition: GraphTooltipPosition.right,
///   tooltipTriggerMode: GraphTooltipTriggerMode.hover,
///   tooltipBuilder: (context, node) {
///     return Padding(
///       padding: const EdgeInsets.all(8),
///       child: Column(
///         mainAxisSize: MainAxisSize.min,
///         children: [
///           Text(
///             node['label'] as String,
///             style: const TextStyle(fontWeight: FontWeight.bold),
///           ),
///           const SizedBox(height: 4),
///           Text(node['description'] as String),
///         ],
///       ),
///     );
///   },
/// )
/// ```
///
/// See also:
///
///  * [GraphTooltipTriggerMode], which defines when tooltips appear
///  * [GraphTooltipPosition], which controls tooltip placement
///  * [GraphTooltipWidgetBuilder], which builds the tooltip content
class GraphTooltipBehavior {
  /// Creates a tooltip behavior configuration.
  ///
  /// The [triggerMode], [position], and [builder] must not be null.
  /// Delays default to [Duration.zero] if not specified.
  const GraphTooltipBehavior({
    required this.triggerMode,
    required this.position,
    required this.builder,
    this.showDelay = Duration.zero,
    this.hideDelay = Duration.zero,
    this.onShow,
    this.onHide,
    this.shouldShow,
  });

  /// Determines when the tooltip should be shown or hidden.
  final GraphTooltipTriggerMode triggerMode;

  /// Controls where the tooltip appears relative to the target entity.
  final GraphTooltipPosition position;

  /// The duration to wait before showing the tooltip.
  final Duration showDelay;

  /// The duration to wait before hiding the tooltip.
  final Duration hideDelay;

  /// Called when the tooltip is about to be shown.
  final void Function()? onShow;

  /// Called when the tooltip is about to be hidden.
  final void Function()? onHide;

  /// Optional callback to determine if the tooltip should be shown.
  ///
  /// If provided, the tooltip will only be shown if this returns true.
  final bool Function(GraphEntity entity)? shouldShow;

  /// Builds the widget tree for the tooltip content.
  final GraphTooltipWidgetBuilder builder;
}
