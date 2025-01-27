import 'package:flutter/cupertino.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_data.dart';
import 'package:plough/src/utils/signals.dart';
import 'package:signals/signals_flutter.dart';

/// The fundamental interface defining a graph entity within the visualization system.
///
/// A graph entity represents a visual element in the graph that can be positioned,
/// interacted with, and customized. Entities serve as the building blocks for both
/// nodes and links, providing a consistent interface for manipulation and state
/// management.
///
/// Each entity maintains its own state including position, selection status, and
/// custom properties, while the parent [Graph] manages the relationships between
/// entities. This separation allows for independent state management while ensuring
/// consistency across the visualization.
///
/// The visualization system uses the entity's state to determine:
/// - Layout positioning through [logicalPosition]
/// - Rendering order via [stackOrder]
/// - Interaction capabilities with [isEnabled] and [canSelect]
/// - Visibility control through [visible]
/// - Selection state via [isSelected]
///
/// Entities can be extended with custom data through the [properties] map,
/// enabling application-specific attributes and behaviors while maintaining
/// compatibility with the core visualization system.
///
/// The [weight] property influences layout algorithms but its specific meaning
/// varies by algorithm - refer to individual [GraphLayoutStrategy] implementations
/// for details.
///
/// See also:
///
/// * [GraphNode], which implements this interface for graph vertices.
/// * [GraphLink], which implements this interface for graph edges.
/// * [Graph], the container and manager for entities.
/// * [GraphView], which provides the visual representation of entities.
abstract class GraphEntity implements Listenable {
  /// The owning [Graph] instance for this entity.
  ///
  /// Set automatically when the entity is added to a graph. Initially null.
  /// An entity can only belong to one graph at a time and cannot be moved
  /// between graphs.
  Graph? get graph;

  /// A unique identifier for this entity.
  ///
  /// Guaranteed to be unique within a graph. Used for entity lookup and cross-references
  /// within the visualization system.
  GraphId get id;

  /// The entity's position in the graph's logical coordinate system.
  ///
  /// Controlled by the [GraphLayoutStrategy] to determine the actual rendering position.
  /// Direct modification is not recommended unless using manual layout, as most
  /// layout algorithms manage positioning automatically.
  Offset get logicalPosition;
  set logicalPosition(Offset position);

  /// A weighting factor used by layout algorithms.
  ///
  /// The interpretation of this value depends on the specific [GraphLayoutStrategy]
  /// implementation. Refer to the documentation of individual layout strategies
  /// for details on how this value affects positioning.
  double get weight;
  set weight(double weight);

  /// The z-order of this entity within the graph visualization.
  ///
  /// Higher values bring the entity closer to the front. For entities with equal
  /// stack orders, the addition order to the graph determines their relative positions.
  int get stackOrder;
  set stackOrder(int stackOrder);

  /// Whether this entity is enabled for interaction.
  ///
  /// When false, the entity does not respond to user interactions, though its
  /// visibility remains independently controlled by the [visible] property.
  bool get isEnabled;
  set isEnabled(bool isEnabled);

  /// Whether this entity is currently visible.
  ///
  /// When false, the entity is hidden from view but still participates in layout
  /// calculations. This allows for smooth transitions when showing/hiding elements.
  bool get visible;
  set visible(bool visible);

  /// Whether this entity can be selected by user interaction.
  ///
  /// When false, prevents selection operations while maintaining other interaction
  /// capabilities controlled by [isEnabled].
  bool get canSelect;
  set canSelect(bool canSelect);

  /// Whether this entity is currently selected.
  ///
  /// Read-only property managed by the [GraphView] interaction system. Selection
  /// state changes should be made through the graph's selection methods.
  bool get isSelected;

  /// Custom properties associated with this entity.
  ///
  /// A map that can store arbitrary application-specific data as [Object] values,
  /// enabling extension of entity functionality without modifying the core interface.
  Map<String, Object> get properties;
  set properties(Map<String, Object> values);

  /// Returns the property value associated with the given key.
  ///
  /// Returns null if no value exists for the specified key.
  Object? operator [](String key);

  /// Sets a property value for the given key.
  ///
  /// Overwrites any existing value associated with the same key.
  void operator []=(String key, Object value);
}

abstract class GraphEntityImpl<T extends GraphEntityData>
    with ListenableSignalStateMixin<T>
    implements GraphEntity {
  @protected
  GraphEntityImpl(T value) {
    state = signal(value);
  }

  @override
  Graph? get graph => _graph;

  Graph? _graph;

  final MapSignal<String, Object> _map = mapSignal({});

  void onAdded(Graph graph) {
    if (_graph != null) {
      throw StateError('Already added to a graph');
    }
    _graph = graph;
  }

  @override
  late final Signal<T> state;

  @override
  GraphId get id => state.value.id;

  @override
  Offset get logicalPosition => state.value.logicalPosition;

  @override
  double get weight => state.value.weight;

  @override
  int get stackOrder => state.value.stackOrder;

  @override
  bool get isEnabled => state.value.isEnabled;

  @override
  bool get visible => state.value.visible;

  @override
  bool get canSelect => state.value.canSelect;

  @override
  bool get isSelected => state.value.isSelected;

  @override
  Map<String, Object> get properties => _map.value;

  @override
  set properties(Map<String, Object> values) {
    _map.value = values;
  }

  @override
  Object? operator [](String key) => _map[key];

  @override
  void operator []=(String key, Object value) {
    _map[key] = value;
  }
}
