import 'package:flutter/widgets.dart';
import 'package:plough/src/viewport/controller.dart';

/// Exposes the active `GraphViewportController` to descendants so that
/// `GraphView` can read the current scale (and screen↔scene transform)
/// without the app having to wire it through manually.
///
/// When a `GraphView` is used without a surrounding `GraphViewport` this scope
/// is absent and callers fall back to an identity transform (scale 1).
class GraphViewportScope extends InheritedWidget {
  const GraphViewportScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final GraphViewportController controller;

  /// Returns the nearest scope's controller, or null if there is none.
  static GraphViewportController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GraphViewportScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(GraphViewportScope oldWidget) =>
      controller != oldWidget.controller;
}
