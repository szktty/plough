import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph_view/inherited_data.dart';

part 'data.freezed.dart';

/// Configuration and state container for [GraphView].
///
/// Manages the visual representation and interaction settings of a graph through:
///
/// * Layout - Controls node positioning via [layoutStrategy]
/// * Behavior - Defines interactions through [behavior]
/// * Selection - Configures node/link selection via [allowSelection] and [allowMultiSelection]
/// * Animation - Controls node movement animations with [animationEnabled] and related properties
///
/// The state is immutable and changes are managed through the provider pattern.
@internal
@freezed
class GraphViewData with _$GraphViewData {
  /// Creates an immutable view configuration.
  ///
  /// All parameters are required to ensure view consistency.
  const factory GraphViewData({
    /// The graph data model to be visualized
    required Graph graph,

    /// View interaction and rendering behaviors
    required GraphViewBehavior behavior,

    /// Strategy for positioning nodes, null disables automatic layout
    required GraphLayoutStrategy? layoutStrategy,

    /// Whether nodes and links can be selected
    required bool allowSelection,

    /// Whether multiple nodes and links can be selected simultaneously
    required bool allowMultiSelection,

    /// Whether position changes should be animated
    required bool animationEnabled,

    /// Starting position for node animations, null uses current position
    required Offset? nodeAnimationStartPosition,

    /// Duration of node movement animations
    required Duration nodeAnimationDuration,

    /// Animation curve for node movements
    required Curve nodeAnimationCurve,
  }) = _GraphViewData;

  /// Access the view configuration from the widget tree.
  ///
  /// Returns the immutable configuration instance without subscribing to changes.
  @internal
  static GraphViewData of(BuildContext context) {
    return GraphInheritedData.read(context).data;
  }
}
