import 'dart:ui';

import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';

/// Specifies how GraphView should handle gestures.
enum GraphGestureMode {
  /// Default behavior: consume all gestures within GraphView bounds
  exclusive,

  /// Only consume gestures that hit nodes or edges, pass through background
  /// gestures
  nodeEdgeOnly,

  /// Pass all gestures through to parent widgets
  transparent,

  /// Use custom logic to determine gesture consumption
  custom,
}

/// Detailed information about what was hit during a gesture.
///
/// Used to determine whether GraphView should consume a gesture or pass it
/// through to parent widgets.
class GraphHitTestResult {
  /// Creates a hit test result.
  const GraphHitTestResult({
    required this.localPosition,
    this.node,
    this.link,
  });

  /// The local position where the hit test occurred.
  final Offset localPosition;

  /// The node that was hit, if any.
  final GraphNode? node;

  /// The link that was hit, if any.
  final GraphLink? link;

  /// Whether a node was hit.
  bool get hasNode => node != null;

  /// Whether a link was hit.
  bool get hasLink => link != null;

  /// Whether any graph entity was hit.
  bool get hasEntity => hasNode || hasLink;

  /// Whether this is a background hit (no entities).
  bool get isBackground => !hasEntity;

  /// The entity that was hit, if any.
  GraphEntity? get entity => node ?? link;

  /// The ID of the entity that was hit, if any.
  GraphId? get entityId => entity?.id;

  @override
  String toString() {
    return 'GraphHitTestResult('
        'localPosition: $localPosition, '
        'node: ${node?.id.value.substring(0, 4)}, '
        'link: ${link?.id.value.substring(0, 4)}, '
        'isBackground: $isBackground)';
  }
}

/// Callback for determining whether GraphView should consume a gesture.
///
/// Returns `true` if GraphView should handle the gesture, `false` if it should
/// pass through to parent widgets.
typedef GraphGestureConsumptionCallback = bool Function(
  Offset localPosition,
  GraphHitTestResult hitTestResult,
);

/// Callback for handling background gestures that are not consumed by GraphView.
typedef GraphBackgroundGestureCallback = void Function(
  Offset localPosition,
);

/// Callback for handling background pan gestures.
typedef GraphBackgroundPanCallback = void Function(
  Offset localPosition,
  Offset delta,
);
