// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graph_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphNodeData {
  GraphId get id;
  Offset get logicalPosition;
  double get weight;
  int get stackOrder;
  bool get isEnabled;
  bool get visible;
  bool get canSelect;
  bool get canDrag;
  bool get isArranged;

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphNodeDataCopyWith<GraphNodeData> get copyWith =>
      _$GraphNodeDataCopyWithImpl<GraphNodeData>(
          this as GraphNodeData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphNodeData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.logicalPosition, logicalPosition) ||
                other.logicalPosition == logicalPosition) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.stackOrder, stackOrder) ||
                other.stackOrder == stackOrder) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.canSelect, canSelect) ||
                other.canSelect == canSelect) &&
            (identical(other.canDrag, canDrag) || other.canDrag == canDrag) &&
            (identical(other.isArranged, isArranged) ||
                other.isArranged == isArranged));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, logicalPosition, weight,
      stackOrder, isEnabled, visible, canSelect, canDrag, isArranged);

  @override
  String toString() {
    return 'GraphNodeData(id: $id, logicalPosition: $logicalPosition, weight: $weight, stackOrder: $stackOrder, isEnabled: $isEnabled, visible: $visible, canSelect: $canSelect, canDrag: $canDrag, isArranged: $isArranged)';
  }
}

/// @nodoc
abstract mixin class $GraphNodeDataCopyWith<$Res> {
  factory $GraphNodeDataCopyWith(
          GraphNodeData value, $Res Function(GraphNodeData) _then) =
      _$GraphNodeDataCopyWithImpl;
  @useResult
  $Res call(
      {GraphId id,
      Offset logicalPosition,
      double weight,
      int stackOrder,
      bool isEnabled,
      bool visible,
      bool canSelect,
      bool canDrag,
      bool isArranged});

  $GraphIdCopyWith<$Res> get id;
}

/// @nodoc
class _$GraphNodeDataCopyWithImpl<$Res>
    implements $GraphNodeDataCopyWith<$Res> {
  _$GraphNodeDataCopyWithImpl(this._self, this._then);

  final GraphNodeData _self;
  final $Res Function(GraphNodeData) _then;

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? logicalPosition = null,
    Object? weight = null,
    Object? stackOrder = null,
    Object? isEnabled = null,
    Object? visible = null,
    Object? canSelect = null,
    Object? canDrag = null,
    Object? isArranged = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      logicalPosition: null == logicalPosition
          ? _self.logicalPosition
          : logicalPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      stackOrder: null == stackOrder
          ? _self.stackOrder
          : stackOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      canSelect: null == canSelect
          ? _self.canSelect
          : canSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      canDrag: null == canDrag
          ? _self.canDrag
          : canDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      isArranged: null == isArranged
          ? _self.isArranged
          : isArranged // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphNodeData].
extension GraphNodeDataPatterns on GraphNodeData {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GraphNodeData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GraphNodeData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GraphNodeData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            GraphId id,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData() when $default != null:
        return $default(
            _that.id,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            GraphId id,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData():
        return $default(
            _that.id,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            GraphId id,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeData() when $default != null:
        return $default(
            _that.id,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphNodeData implements GraphNodeData {
  const _GraphNodeData(
      {required this.id,
      this.logicalPosition = Offset.zero,
      this.weight = 1.0,
      this.stackOrder = -1,
      this.isEnabled = true,
      this.visible = true,
      this.canSelect = true,
      this.canDrag = true,
      this.isArranged = false});

  @override
  final GraphId id;
  @override
  @JsonKey()
  final Offset logicalPosition;
  @override
  @JsonKey()
  final double weight;
  @override
  @JsonKey()
  final int stackOrder;
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final bool canSelect;
  @override
  @JsonKey()
  final bool canDrag;
  @override
  @JsonKey()
  final bool isArranged;

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphNodeDataCopyWith<_GraphNodeData> get copyWith =>
      __$GraphNodeDataCopyWithImpl<_GraphNodeData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphNodeData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.logicalPosition, logicalPosition) ||
                other.logicalPosition == logicalPosition) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.stackOrder, stackOrder) ||
                other.stackOrder == stackOrder) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.canSelect, canSelect) ||
                other.canSelect == canSelect) &&
            (identical(other.canDrag, canDrag) || other.canDrag == canDrag) &&
            (identical(other.isArranged, isArranged) ||
                other.isArranged == isArranged));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, logicalPosition, weight,
      stackOrder, isEnabled, visible, canSelect, canDrag, isArranged);

  @override
  String toString() {
    return 'GraphNodeData(id: $id, logicalPosition: $logicalPosition, weight: $weight, stackOrder: $stackOrder, isEnabled: $isEnabled, visible: $visible, canSelect: $canSelect, canDrag: $canDrag, isArranged: $isArranged)';
  }
}

/// @nodoc
abstract mixin class _$GraphNodeDataCopyWith<$Res>
    implements $GraphNodeDataCopyWith<$Res> {
  factory _$GraphNodeDataCopyWith(
          _GraphNodeData value, $Res Function(_GraphNodeData) _then) =
      __$GraphNodeDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GraphId id,
      Offset logicalPosition,
      double weight,
      int stackOrder,
      bool isEnabled,
      bool visible,
      bool canSelect,
      bool canDrag,
      bool isArranged});

  @override
  $GraphIdCopyWith<$Res> get id;
}

/// @nodoc
class __$GraphNodeDataCopyWithImpl<$Res>
    implements _$GraphNodeDataCopyWith<$Res> {
  __$GraphNodeDataCopyWithImpl(this._self, this._then);

  final _GraphNodeData _self;
  final $Res Function(_GraphNodeData) _then;

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? logicalPosition = null,
    Object? weight = null,
    Object? stackOrder = null,
    Object? isEnabled = null,
    Object? visible = null,
    Object? canSelect = null,
    Object? canDrag = null,
    Object? isArranged = null,
  }) {
    return _then(_GraphNodeData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      logicalPosition: null == logicalPosition
          ? _self.logicalPosition
          : logicalPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      stackOrder: null == stackOrder
          ? _self.stackOrder
          : stackOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      canSelect: null == canSelect
          ? _self.canSelect
          : canSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      canDrag: null == canDrag
          ? _self.canDrag
          : canDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      isArranged: null == isArranged
          ? _self.isArranged
          : isArranged // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of GraphNodeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$GraphLinkData {
  GraphId get id;
  GraphNode? get source;
  GraphNode? get target;
  GraphLinkDirection get direction;
  Offset get logicalPosition;
  double get weight;
  int get stackOrder;
  bool get isEnabled;
  bool get visible;
  bool get canSelect;
  bool get canDrag;
  bool get isArranged;

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphLinkDataCopyWith<GraphLinkData> get copyWith =>
      _$GraphLinkDataCopyWithImpl<GraphLinkData>(
          this as GraphLinkData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphLinkData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.logicalPosition, logicalPosition) ||
                other.logicalPosition == logicalPosition) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.stackOrder, stackOrder) ||
                other.stackOrder == stackOrder) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.canSelect, canSelect) ||
                other.canSelect == canSelect) &&
            (identical(other.canDrag, canDrag) || other.canDrag == canDrag) &&
            (identical(other.isArranged, isArranged) ||
                other.isArranged == isArranged));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      source,
      target,
      direction,
      logicalPosition,
      weight,
      stackOrder,
      isEnabled,
      visible,
      canSelect,
      canDrag,
      isArranged);

  @override
  String toString() {
    return 'GraphLinkData(id: $id, source: $source, target: $target, direction: $direction, logicalPosition: $logicalPosition, weight: $weight, stackOrder: $stackOrder, isEnabled: $isEnabled, visible: $visible, canSelect: $canSelect, canDrag: $canDrag, isArranged: $isArranged)';
  }
}

/// @nodoc
abstract mixin class $GraphLinkDataCopyWith<$Res> {
  factory $GraphLinkDataCopyWith(
          GraphLinkData value, $Res Function(GraphLinkData) _then) =
      _$GraphLinkDataCopyWithImpl;
  @useResult
  $Res call(
      {GraphId id,
      GraphNode? source,
      GraphNode? target,
      GraphLinkDirection direction,
      Offset logicalPosition,
      double weight,
      int stackOrder,
      bool isEnabled,
      bool visible,
      bool canSelect,
      bool canDrag,
      bool isArranged});

  $GraphIdCopyWith<$Res> get id;
}

/// @nodoc
class _$GraphLinkDataCopyWithImpl<$Res>
    implements $GraphLinkDataCopyWith<$Res> {
  _$GraphLinkDataCopyWithImpl(this._self, this._then);

  final GraphLinkData _self;
  final $Res Function(GraphLinkData) _then;

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = freezed,
    Object? target = freezed,
    Object? direction = null,
    Object? logicalPosition = null,
    Object? weight = null,
    Object? stackOrder = null,
    Object? isEnabled = null,
    Object? visible = null,
    Object? canSelect = null,
    Object? canDrag = null,
    Object? isArranged = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      source: freezed == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNode?,
      target: freezed == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNode?,
      direction: null == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as GraphLinkDirection,
      logicalPosition: null == logicalPosition
          ? _self.logicalPosition
          : logicalPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      stackOrder: null == stackOrder
          ? _self.stackOrder
          : stackOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      canSelect: null == canSelect
          ? _self.canSelect
          : canSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      canDrag: null == canDrag
          ? _self.canDrag
          : canDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      isArranged: null == isArranged
          ? _self.isArranged
          : isArranged // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphLinkData].
extension GraphLinkDataPatterns on GraphLinkData {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GraphLinkData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GraphLinkData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GraphLinkData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            GraphId id,
            GraphNode? source,
            GraphNode? target,
            GraphLinkDirection direction,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData() when $default != null:
        return $default(
            _that.id,
            _that.source,
            _that.target,
            _that.direction,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            GraphId id,
            GraphNode? source,
            GraphNode? target,
            GraphLinkDirection direction,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData():
        return $default(
            _that.id,
            _that.source,
            _that.target,
            _that.direction,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            GraphId id,
            GraphNode? source,
            GraphNode? target,
            GraphLinkDirection direction,
            Offset logicalPosition,
            double weight,
            int stackOrder,
            bool isEnabled,
            bool visible,
            bool canSelect,
            bool canDrag,
            bool isArranged)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkData() when $default != null:
        return $default(
            _that.id,
            _that.source,
            _that.target,
            _that.direction,
            _that.logicalPosition,
            _that.weight,
            _that.stackOrder,
            _that.isEnabled,
            _that.visible,
            _that.canSelect,
            _that.canDrag,
            _that.isArranged);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphLinkData implements GraphLinkData {
  const _GraphLinkData(
      {required this.id,
      this.source,
      this.target,
      this.direction = GraphLinkDirection.none,
      this.logicalPosition = Offset.zero,
      this.weight = 1.0,
      this.stackOrder = -1,
      this.isEnabled = true,
      this.visible = true,
      this.canSelect = true,
      this.canDrag = true,
      this.isArranged = false});

  @override
  final GraphId id;
  @override
  final GraphNode? source;
  @override
  final GraphNode? target;
  @override
  @JsonKey()
  final GraphLinkDirection direction;
  @override
  @JsonKey()
  final Offset logicalPosition;
  @override
  @JsonKey()
  final double weight;
  @override
  @JsonKey()
  final int stackOrder;
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final bool canSelect;
  @override
  @JsonKey()
  final bool canDrag;
  @override
  @JsonKey()
  final bool isArranged;

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphLinkDataCopyWith<_GraphLinkData> get copyWith =>
      __$GraphLinkDataCopyWithImpl<_GraphLinkData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphLinkData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.logicalPosition, logicalPosition) ||
                other.logicalPosition == logicalPosition) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.stackOrder, stackOrder) ||
                other.stackOrder == stackOrder) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.canSelect, canSelect) ||
                other.canSelect == canSelect) &&
            (identical(other.canDrag, canDrag) || other.canDrag == canDrag) &&
            (identical(other.isArranged, isArranged) ||
                other.isArranged == isArranged));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      source,
      target,
      direction,
      logicalPosition,
      weight,
      stackOrder,
      isEnabled,
      visible,
      canSelect,
      canDrag,
      isArranged);

  @override
  String toString() {
    return 'GraphLinkData(id: $id, source: $source, target: $target, direction: $direction, logicalPosition: $logicalPosition, weight: $weight, stackOrder: $stackOrder, isEnabled: $isEnabled, visible: $visible, canSelect: $canSelect, canDrag: $canDrag, isArranged: $isArranged)';
  }
}

/// @nodoc
abstract mixin class _$GraphLinkDataCopyWith<$Res>
    implements $GraphLinkDataCopyWith<$Res> {
  factory _$GraphLinkDataCopyWith(
          _GraphLinkData value, $Res Function(_GraphLinkData) _then) =
      __$GraphLinkDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GraphId id,
      GraphNode? source,
      GraphNode? target,
      GraphLinkDirection direction,
      Offset logicalPosition,
      double weight,
      int stackOrder,
      bool isEnabled,
      bool visible,
      bool canSelect,
      bool canDrag,
      bool isArranged});

  @override
  $GraphIdCopyWith<$Res> get id;
}

/// @nodoc
class __$GraphLinkDataCopyWithImpl<$Res>
    implements _$GraphLinkDataCopyWith<$Res> {
  __$GraphLinkDataCopyWithImpl(this._self, this._then);

  final _GraphLinkData _self;
  final $Res Function(_GraphLinkData) _then;

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? source = freezed,
    Object? target = freezed,
    Object? direction = null,
    Object? logicalPosition = null,
    Object? weight = null,
    Object? stackOrder = null,
    Object? isEnabled = null,
    Object? visible = null,
    Object? canSelect = null,
    Object? canDrag = null,
    Object? isArranged = null,
  }) {
    return _then(_GraphLinkData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      source: freezed == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNode?,
      target: freezed == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNode?,
      direction: null == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as GraphLinkDirection,
      logicalPosition: null == logicalPosition
          ? _self.logicalPosition
          : logicalPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      stackOrder: null == stackOrder
          ? _self.stackOrder
          : stackOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      canSelect: null == canSelect
          ? _self.canSelect
          : canSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      canDrag: null == canDrag
          ? _self.canDrag
          : canDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      isArranged: null == isArranged
          ? _self.isArranged
          : isArranged // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of GraphLinkData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$GraphData {
  /// Unique identifier for this graph instance.
  GraphId get id;

  /// Map of node IDs to their corresponding [GraphNode] instances.
  IMap<GraphId, GraphNode> get nodes;

  /// Map of link IDs to their corresponding [GraphLink] instances.
  IMap<GraphId, GraphLink> get links;

  /// List of IDs for currently selected nodes.
  IList<GraphId> get selectedNodeIds;

  /// List of IDs for currently selected links.
  IList<GraphId> get selectedLinkIds;

  /// Whether selection of graph elements is enabled.
  bool get allowSelection;

  /// Whether multiple elements can be selected simultaneously.
  bool get allowMultiSelection;
  bool get needsLayout;
  bool get shouldAnimateLayout;
  GraphViewGeometry? get geometry;

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphDataCopyWith<GraphData> get copyWith =>
      _$GraphDataCopyWithImpl<GraphData>(this as GraphData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nodes, nodes) || other.nodes == nodes) &&
            (identical(other.links, links) || other.links == links) &&
            const DeepCollectionEquality()
                .equals(other.selectedNodeIds, selectedNodeIds) &&
            const DeepCollectionEquality()
                .equals(other.selectedLinkIds, selectedLinkIds) &&
            (identical(other.allowSelection, allowSelection) ||
                other.allowSelection == allowSelection) &&
            (identical(other.allowMultiSelection, allowMultiSelection) ||
                other.allowMultiSelection == allowMultiSelection) &&
            (identical(other.needsLayout, needsLayout) ||
                other.needsLayout == needsLayout) &&
            (identical(other.shouldAnimateLayout, shouldAnimateLayout) ||
                other.shouldAnimateLayout == shouldAnimateLayout) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nodes,
      links,
      const DeepCollectionEquality().hash(selectedNodeIds),
      const DeepCollectionEquality().hash(selectedLinkIds),
      allowSelection,
      allowMultiSelection,
      needsLayout,
      shouldAnimateLayout,
      geometry);

  @override
  String toString() {
    return 'GraphData(id: $id, nodes: $nodes, links: $links, selectedNodeIds: $selectedNodeIds, selectedLinkIds: $selectedLinkIds, allowSelection: $allowSelection, allowMultiSelection: $allowMultiSelection, needsLayout: $needsLayout, shouldAnimateLayout: $shouldAnimateLayout, geometry: $geometry)';
  }
}

/// @nodoc
abstract mixin class $GraphDataCopyWith<$Res> {
  factory $GraphDataCopyWith(GraphData value, $Res Function(GraphData) _then) =
      _$GraphDataCopyWithImpl;
  @useResult
  $Res call(
      {GraphId id,
      IMap<GraphId, GraphNode> nodes,
      IMap<GraphId, GraphLink> links,
      IList<GraphId> selectedNodeIds,
      IList<GraphId> selectedLinkIds,
      bool allowSelection,
      bool allowMultiSelection,
      bool needsLayout,
      bool shouldAnimateLayout,
      GraphViewGeometry? geometry});

  $GraphIdCopyWith<$Res> get id;
  $GraphViewGeometryCopyWith<$Res>? get geometry;
}

/// @nodoc
class _$GraphDataCopyWithImpl<$Res> implements $GraphDataCopyWith<$Res> {
  _$GraphDataCopyWithImpl(this._self, this._then);

  final GraphData _self;
  final $Res Function(GraphData) _then;

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nodes = null,
    Object? links = null,
    Object? selectedNodeIds = null,
    Object? selectedLinkIds = null,
    Object? allowSelection = null,
    Object? allowMultiSelection = null,
    Object? needsLayout = null,
    Object? shouldAnimateLayout = null,
    Object? geometry = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      nodes: null == nodes
          ? _self.nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as IMap<GraphId, GraphNode>,
      links: null == links
          ? _self.links
          : links // ignore: cast_nullable_to_non_nullable
              as IMap<GraphId, GraphLink>,
      selectedNodeIds: null == selectedNodeIds
          ? _self.selectedNodeIds
          : selectedNodeIds // ignore: cast_nullable_to_non_nullable
              as IList<GraphId>,
      selectedLinkIds: null == selectedLinkIds
          ? _self.selectedLinkIds
          : selectedLinkIds // ignore: cast_nullable_to_non_nullable
              as IList<GraphId>,
      allowSelection: null == allowSelection
          ? _self.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _self.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      needsLayout: null == needsLayout
          ? _self.needsLayout
          : needsLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldAnimateLayout: null == shouldAnimateLayout
          ? _self.shouldAnimateLayout
          : shouldAnimateLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GraphViewGeometry?,
    ));
  }

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphViewGeometryCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GraphViewGeometryCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphData].
extension GraphDataPatterns on GraphData {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GraphData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphData() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GraphData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphData():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GraphData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphData() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            GraphId id,
            IMap<GraphId, GraphNode> nodes,
            IMap<GraphId, GraphLink> links,
            IList<GraphId> selectedNodeIds,
            IList<GraphId> selectedLinkIds,
            bool allowSelection,
            bool allowMultiSelection,
            bool needsLayout,
            bool shouldAnimateLayout,
            GraphViewGeometry? geometry)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphData() when $default != null:
        return $default(
            _that.id,
            _that.nodes,
            _that.links,
            _that.selectedNodeIds,
            _that.selectedLinkIds,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.needsLayout,
            _that.shouldAnimateLayout,
            _that.geometry);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            GraphId id,
            IMap<GraphId, GraphNode> nodes,
            IMap<GraphId, GraphLink> links,
            IList<GraphId> selectedNodeIds,
            IList<GraphId> selectedLinkIds,
            bool allowSelection,
            bool allowMultiSelection,
            bool needsLayout,
            bool shouldAnimateLayout,
            GraphViewGeometry? geometry)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphData():
        return $default(
            _that.id,
            _that.nodes,
            _that.links,
            _that.selectedNodeIds,
            _that.selectedLinkIds,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.needsLayout,
            _that.shouldAnimateLayout,
            _that.geometry);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            GraphId id,
            IMap<GraphId, GraphNode> nodes,
            IMap<GraphId, GraphLink> links,
            IList<GraphId> selectedNodeIds,
            IList<GraphId> selectedLinkIds,
            bool allowSelection,
            bool allowMultiSelection,
            bool needsLayout,
            bool shouldAnimateLayout,
            GraphViewGeometry? geometry)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphData() when $default != null:
        return $default(
            _that.id,
            _that.nodes,
            _that.links,
            _that.selectedNodeIds,
            _that.selectedLinkIds,
            _that.allowSelection,
            _that.allowMultiSelection,
            _that.needsLayout,
            _that.shouldAnimateLayout,
            _that.geometry);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphData implements GraphData {
  const _GraphData(
      {required this.id,
      this.nodes = const IMapConst({}),
      this.links = const IMapConst({}),
      this.selectedNodeIds = const IListConst([]),
      this.selectedLinkIds = const IListConst([]),
      this.allowSelection = true,
      this.allowMultiSelection = false,
      this.needsLayout = true,
      this.shouldAnimateLayout = false,
      this.geometry});

  /// Unique identifier for this graph instance.
  @override
  final GraphId id;

  /// Map of node IDs to their corresponding [GraphNode] instances.
  @override
  @JsonKey()
  final IMap<GraphId, GraphNode> nodes;

  /// Map of link IDs to their corresponding [GraphLink] instances.
  @override
  @JsonKey()
  final IMap<GraphId, GraphLink> links;

  /// List of IDs for currently selected nodes.
  @override
  @JsonKey()
  final IList<GraphId> selectedNodeIds;

  /// List of IDs for currently selected links.
  @override
  @JsonKey()
  final IList<GraphId> selectedLinkIds;

  /// Whether selection of graph elements is enabled.
  @override
  @JsonKey()
  final bool allowSelection;

  /// Whether multiple elements can be selected simultaneously.
  @override
  @JsonKey()
  final bool allowMultiSelection;
  @override
  @JsonKey()
  final bool needsLayout;
  @override
  @JsonKey()
  final bool shouldAnimateLayout;
  @override
  final GraphViewGeometry? geometry;

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphDataCopyWith<_GraphData> get copyWith =>
      __$GraphDataCopyWithImpl<_GraphData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nodes, nodes) || other.nodes == nodes) &&
            (identical(other.links, links) || other.links == links) &&
            const DeepCollectionEquality()
                .equals(other.selectedNodeIds, selectedNodeIds) &&
            const DeepCollectionEquality()
                .equals(other.selectedLinkIds, selectedLinkIds) &&
            (identical(other.allowSelection, allowSelection) ||
                other.allowSelection == allowSelection) &&
            (identical(other.allowMultiSelection, allowMultiSelection) ||
                other.allowMultiSelection == allowMultiSelection) &&
            (identical(other.needsLayout, needsLayout) ||
                other.needsLayout == needsLayout) &&
            (identical(other.shouldAnimateLayout, shouldAnimateLayout) ||
                other.shouldAnimateLayout == shouldAnimateLayout) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nodes,
      links,
      const DeepCollectionEquality().hash(selectedNodeIds),
      const DeepCollectionEquality().hash(selectedLinkIds),
      allowSelection,
      allowMultiSelection,
      needsLayout,
      shouldAnimateLayout,
      geometry);

  @override
  String toString() {
    return 'GraphData(id: $id, nodes: $nodes, links: $links, selectedNodeIds: $selectedNodeIds, selectedLinkIds: $selectedLinkIds, allowSelection: $allowSelection, allowMultiSelection: $allowMultiSelection, needsLayout: $needsLayout, shouldAnimateLayout: $shouldAnimateLayout, geometry: $geometry)';
  }
}

/// @nodoc
abstract mixin class _$GraphDataCopyWith<$Res>
    implements $GraphDataCopyWith<$Res> {
  factory _$GraphDataCopyWith(
          _GraphData value, $Res Function(_GraphData) _then) =
      __$GraphDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GraphId id,
      IMap<GraphId, GraphNode> nodes,
      IMap<GraphId, GraphLink> links,
      IList<GraphId> selectedNodeIds,
      IList<GraphId> selectedLinkIds,
      bool allowSelection,
      bool allowMultiSelection,
      bool needsLayout,
      bool shouldAnimateLayout,
      GraphViewGeometry? geometry});

  @override
  $GraphIdCopyWith<$Res> get id;
  @override
  $GraphViewGeometryCopyWith<$Res>? get geometry;
}

/// @nodoc
class __$GraphDataCopyWithImpl<$Res> implements _$GraphDataCopyWith<$Res> {
  __$GraphDataCopyWithImpl(this._self, this._then);

  final _GraphData _self;
  final $Res Function(_GraphData) _then;

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nodes = null,
    Object? links = null,
    Object? selectedNodeIds = null,
    Object? selectedLinkIds = null,
    Object? allowSelection = null,
    Object? allowMultiSelection = null,
    Object? needsLayout = null,
    Object? shouldAnimateLayout = null,
    Object? geometry = freezed,
  }) {
    return _then(_GraphData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as GraphId,
      nodes: null == nodes
          ? _self.nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as IMap<GraphId, GraphNode>,
      links: null == links
          ? _self.links
          : links // ignore: cast_nullable_to_non_nullable
              as IMap<GraphId, GraphLink>,
      selectedNodeIds: null == selectedNodeIds
          ? _self.selectedNodeIds
          : selectedNodeIds // ignore: cast_nullable_to_non_nullable
              as IList<GraphId>,
      selectedLinkIds: null == selectedLinkIds
          ? _self.selectedLinkIds
          : selectedLinkIds // ignore: cast_nullable_to_non_nullable
              as IList<GraphId>,
      allowSelection: null == allowSelection
          ? _self.allowSelection
          : allowSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMultiSelection: null == allowMultiSelection
          ? _self.allowMultiSelection
          : allowMultiSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      needsLayout: null == needsLayout
          ? _self.needsLayout
          : needsLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldAnimateLayout: null == shouldAnimateLayout
          ? _self.shouldAnimateLayout
          : shouldAnimateLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GraphViewGeometry?,
    ));
  }

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<$Res> get id {
    return $GraphIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }

  /// Create a copy of GraphData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphViewGeometryCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GraphViewGeometryCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }
}

// dart format on
