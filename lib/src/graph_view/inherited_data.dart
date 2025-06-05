import 'package:flutter/material.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/graph_view/data.dart';

/// Inherited widget that provides graph view data down the widget tree.
///
/// This replaces the Provider-based approach with Flutter's standard
/// InheritedWidget. Used to share graph data, behavior, and other view-related
/// information throughout the graph widget tree.
class GraphInheritedData extends InheritedWidget {
  /// Creates an inherited data widget.
  const GraphInheritedData({
    required this.data,
    required this.buildState,
    required this.behavior,
    required this.nodeViewBehavior,
    required this.linkViewBehavior,
    required this.constraints,
    required this.graph,
    required super.child,
    super.key,
  });

  /// The graph view data containing configuration.
  final GraphViewData data;

  /// Current build state of the graph view.
  final GraphViewBuildState buildState;

  /// Graph view behavior configuration.
  final GraphViewBehavior behavior;

  /// Node view behavior configuration.
  final GraphNodeViewBehavior nodeViewBehavior;

  /// Link view behavior configuration.
  final GraphLinkViewBehavior linkViewBehavior;

  /// Layout constraints for the graph view.
  final BoxConstraints constraints;

  /// The graph data model as a listenable.
  final GraphImpl graph;

  /// Retrieves the inherited data from the widget tree.
  ///
  /// Returns the nearest [GraphInheritedData] ancestor.
  /// Throws if no ancestor is found.
  static GraphInheritedData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<GraphInheritedData>();
    if (result == null) {
      throw FlutterError(
        'GraphInheritedData.of() called with a context that does not contain '
        'a GraphInheritedData.\n'
        'No GraphInheritedData ancestor could be found starting from the '
        'given context.',
      );
    }
    return result;
  }

  /// Retrieves the inherited data without listening to changes.
  ///
  /// Use this when you only need to access the data once and don't want
  /// to rebuild when the data changes.
  static GraphInheritedData read(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<GraphInheritedData>();
    if (result == null) {
      throw FlutterError(
        'GraphInheritedData.read() called with a context that does not contain '
        'a GraphInheritedData.\n'
        'No GraphInheritedData ancestor could be found starting from the '
        'given context.',
      );
    }
    return result;
  }

  @override
  bool updateShouldNotify(GraphInheritedData oldWidget) {
    return data != oldWidget.data ||
        buildState != oldWidget.buildState ||
        behavior != oldWidget.behavior ||
        nodeViewBehavior != oldWidget.nodeViewBehavior ||
        linkViewBehavior != oldWidget.linkViewBehavior ||
        constraints != oldWidget.constraints ||
        graph != oldWidget.graph;
  }
}

/// Build state of the graph view.
///
/// Defines the current phase of graph view construction and rendering.
enum GraphViewBuildState {
  /// Initial state, renders transparent for geometry calculation
  initialize,

  /// Executing layout algorithm
  performLayout,

  /// Ready for rendering
  ready;

  /// Retrieves the current build state from the widget context.
  static GraphViewBuildState of(BuildContext context) {
    return GraphInheritedData.of(context).buildState;
  }

  /// Retrieves the current build state without listening to changes.
  static GraphViewBuildState read(BuildContext context) {
    return GraphInheritedData.read(context).buildState;
  }
}
