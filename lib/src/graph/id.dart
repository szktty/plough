import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/v7.dart';

part 'id.freezed.dart';

part 'id.g.dart';

/// Identifies the type of graph element an ID belongs to.
enum GraphIdType {
  /// Identifies a complete graph structure
  graph,

  /// Identifies a node within a graph
  node,

  /// Identifies a link between nodes
  link,
}

/// A unique identifier for graph elements.
///
/// Each [GraphId] consists of a type indicator and a unique value using UUIDv7 format,
/// ensuring uniqueness across the graph structure. The type indicator helps distinguish
/// between different graph elements while maintaining efficient storage.
///
/// Example:
/// ```dart
/// final graphId = GraphId.unique(GraphIdType.graph);
/// final nodeId = GraphId.unique(GraphIdType.node);
/// ```
///
/// The string representation uses a shortened format for readability:
/// * Graph IDs appear as `<G:xxxxxx>`
/// * Node IDs appear as `<N:xxxxxx>`
/// * Link IDs appear as `<L:xxxxxx>`
@Freezed(toStringOverride: false)
class GraphId with _$GraphId {
  /// Creates an identifier with the specified type and value.
  const factory GraphId({
    /// The category of graph element this ID represents (graph, node, or link).
    required GraphIdType type,

    /// The unique identifier string in UUIDv7 format.
    required String value,
  }) = _GraphId;

  const GraphId._();

  /// Creates an identifier with a new UUIDv7 value for the given type.
  factory GraphId.unique(GraphIdType type) => GraphId(
        type: type,
        value: const UuidV7().generate(),
      );

  /// Creates an identifier from its JSON representation.
  factory GraphId.fromJson(Map<String, Object?> json) =>
      _$GraphIdFromJson(json);

  @override
  String toString() {
    late String symbol;
    switch (type) {
      case GraphIdType.graph:
        symbol = 'G';
      case GraphIdType.node:
        symbol = 'N';
      case GraphIdType.link:
        symbol = 'L';
    }
    final shorten = value.substring(value.length - 6);
    return '<$symbol:$shorten>';
  }
}
