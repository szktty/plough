// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geometry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphConnectionPoints implements DiagnosticableTreeMixin {
  /// The point where the link enters the target node.
  Offset get incoming;

  /// The point where the link exits the source node.
  Offset get outgoing;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphConnectionPointsCopyWith<GraphConnectionPoints> get copyWith =>
      _$GraphConnectionPointsCopyWithImpl<GraphConnectionPoints>(
          this as GraphConnectionPoints, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphConnectionPoints'))
      ..add(DiagnosticsProperty('incoming', incoming))
      ..add(DiagnosticsProperty('outgoing', outgoing));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphConnectionPoints &&
            (identical(other.incoming, incoming) ||
                other.incoming == incoming) &&
            (identical(other.outgoing, outgoing) ||
                other.outgoing == outgoing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, incoming, outgoing);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionPoints(incoming: $incoming, outgoing: $outgoing)';
  }
}

/// @nodoc
abstract mixin class $GraphConnectionPointsCopyWith<$Res> {
  factory $GraphConnectionPointsCopyWith(GraphConnectionPoints value,
          $Res Function(GraphConnectionPoints) _then) =
      _$GraphConnectionPointsCopyWithImpl;
  @useResult
  $Res call({Offset incoming, Offset outgoing});
}

/// @nodoc
class _$GraphConnectionPointsCopyWithImpl<$Res>
    implements $GraphConnectionPointsCopyWith<$Res> {
  _$GraphConnectionPointsCopyWithImpl(this._self, this._then);

  final GraphConnectionPoints _self;
  final $Res Function(GraphConnectionPoints) _then;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incoming = null,
    Object? outgoing = null,
  }) {
    return _then(_self.copyWith(
      incoming: null == incoming
          ? _self.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as Offset,
      outgoing: null == outgoing
          ? _self.outgoing
          : outgoing // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphConnectionPoints].
extension GraphConnectionPointsPatterns on GraphConnectionPoints {
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
    TResult Function(_GraphConnectionPoints value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints() when $default != null:
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
    TResult Function(_GraphConnectionPoints value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints():
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
    TResult? Function(_GraphConnectionPoints value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints() when $default != null:
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
    TResult Function(Offset incoming, Offset outgoing)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints() when $default != null:
        return $default(_that.incoming, _that.outgoing);
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
    TResult Function(Offset incoming, Offset outgoing) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints():
        return $default(_that.incoming, _that.outgoing);
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
    TResult? Function(Offset incoming, Offset outgoing)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionPoints() when $default != null:
        return $default(_that.incoming, _that.outgoing);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphConnectionPoints extends GraphConnectionPoints
    with DiagnosticableTreeMixin {
  const _GraphConnectionPoints({required this.incoming, required this.outgoing})
      : super._();

  /// The point where the link enters the target node.
  @override
  final Offset incoming;

  /// The point where the link exits the source node.
  @override
  final Offset outgoing;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphConnectionPointsCopyWith<_GraphConnectionPoints> get copyWith =>
      __$GraphConnectionPointsCopyWithImpl<_GraphConnectionPoints>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphConnectionPoints'))
      ..add(DiagnosticsProperty('incoming', incoming))
      ..add(DiagnosticsProperty('outgoing', outgoing));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphConnectionPoints &&
            (identical(other.incoming, incoming) ||
                other.incoming == incoming) &&
            (identical(other.outgoing, outgoing) ||
                other.outgoing == outgoing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, incoming, outgoing);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionPoints(incoming: $incoming, outgoing: $outgoing)';
  }
}

/// @nodoc
abstract mixin class _$GraphConnectionPointsCopyWith<$Res>
    implements $GraphConnectionPointsCopyWith<$Res> {
  factory _$GraphConnectionPointsCopyWith(_GraphConnectionPoints value,
          $Res Function(_GraphConnectionPoints) _then) =
      __$GraphConnectionPointsCopyWithImpl;
  @override
  @useResult
  $Res call({Offset incoming, Offset outgoing});
}

/// @nodoc
class __$GraphConnectionPointsCopyWithImpl<$Res>
    implements _$GraphConnectionPointsCopyWith<$Res> {
  __$GraphConnectionPointsCopyWithImpl(this._self, this._then);

  final _GraphConnectionPoints _self;
  final $Res Function(_GraphConnectionPoints) _then;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? incoming = null,
    Object? outgoing = null,
  }) {
    return _then(_GraphConnectionPoints(
      incoming: null == incoming
          ? _self.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as Offset,
      outgoing: null == outgoing
          ? _self.outgoing
          : outgoing // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc
mixin _$GraphNodeViewGeometry implements DiagnosticableTreeMixin {
  Rect get bounds;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<GraphNodeViewGeometry> get copyWith =>
      _$GraphNodeViewGeometryCopyWithImpl<GraphNodeViewGeometry>(
          this as GraphNodeViewGeometry, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphNodeViewGeometry'))
      ..add(DiagnosticsProperty('bounds', bounds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphNodeViewGeometry &&
            (identical(other.bounds, bounds) || other.bounds == bounds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bounds);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphNodeViewGeometry(bounds: $bounds)';
  }
}

/// @nodoc
abstract mixin class $GraphNodeViewGeometryCopyWith<$Res> {
  factory $GraphNodeViewGeometryCopyWith(GraphNodeViewGeometry value,
          $Res Function(GraphNodeViewGeometry) _then) =
      _$GraphNodeViewGeometryCopyWithImpl;
  @useResult
  $Res call({Rect bounds});
}

/// @nodoc
class _$GraphNodeViewGeometryCopyWithImpl<$Res>
    implements $GraphNodeViewGeometryCopyWith<$Res> {
  _$GraphNodeViewGeometryCopyWithImpl(this._self, this._then);

  final GraphNodeViewGeometry _self;
  final $Res Function(GraphNodeViewGeometry) _then;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bounds = null,
  }) {
    return _then(_self.copyWith(
      bounds: null == bounds
          ? _self.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphNodeViewGeometry].
extension GraphNodeViewGeometryPatterns on GraphNodeViewGeometry {
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
    TResult Function(_GraphNodeViewGeometry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry() when $default != null:
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
    TResult Function(_GraphNodeViewGeometry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry():
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
    TResult? Function(_GraphNodeViewGeometry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry() when $default != null:
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
    TResult Function(Rect bounds)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry() when $default != null:
        return $default(_that.bounds);
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
    TResult Function(Rect bounds) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry():
        return $default(_that.bounds);
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
    TResult? Function(Rect bounds)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphNodeViewGeometry() when $default != null:
        return $default(_that.bounds);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphNodeViewGeometry
    with DiagnosticableTreeMixin
    implements GraphNodeViewGeometry {
  const _GraphNodeViewGeometry({required this.bounds});

  @override
  final Rect bounds;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphNodeViewGeometryCopyWith<_GraphNodeViewGeometry> get copyWith =>
      __$GraphNodeViewGeometryCopyWithImpl<_GraphNodeViewGeometry>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphNodeViewGeometry'))
      ..add(DiagnosticsProperty('bounds', bounds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphNodeViewGeometry &&
            (identical(other.bounds, bounds) || other.bounds == bounds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bounds);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphNodeViewGeometry(bounds: $bounds)';
  }
}

/// @nodoc
abstract mixin class _$GraphNodeViewGeometryCopyWith<$Res>
    implements $GraphNodeViewGeometryCopyWith<$Res> {
  factory _$GraphNodeViewGeometryCopyWith(_GraphNodeViewGeometry value,
          $Res Function(_GraphNodeViewGeometry) _then) =
      __$GraphNodeViewGeometryCopyWithImpl;
  @override
  @useResult
  $Res call({Rect bounds});
}

/// @nodoc
class __$GraphNodeViewGeometryCopyWithImpl<$Res>
    implements _$GraphNodeViewGeometryCopyWith<$Res> {
  __$GraphNodeViewGeometryCopyWithImpl(this._self, this._then);

  final _GraphNodeViewGeometry _self;
  final $Res Function(_GraphNodeViewGeometry) _then;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bounds = null,
  }) {
    return _then(_GraphNodeViewGeometry(
      bounds: null == bounds
          ? _self.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// @nodoc
mixin _$GraphLinkViewGeometry implements DiagnosticableTreeMixin {
  Rect get bounds;
  GraphConnectionGeometry get connection;
  double get thickness;
  double get angle;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphLinkViewGeometryCopyWith<GraphLinkViewGeometry> get copyWith =>
      _$GraphLinkViewGeometryCopyWithImpl<GraphLinkViewGeometry>(
          this as GraphLinkViewGeometry, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphLinkViewGeometry'))
      ..add(DiagnosticsProperty('bounds', bounds))
      ..add(DiagnosticsProperty('connection', connection))
      ..add(DiagnosticsProperty('thickness', thickness))
      ..add(DiagnosticsProperty('angle', angle));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphLinkViewGeometry &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.thickness, thickness) ||
                other.thickness == thickness) &&
            (identical(other.angle, angle) || other.angle == angle));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, bounds, connection, thickness, angle);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphLinkViewGeometry(bounds: $bounds, connection: $connection, thickness: $thickness, angle: $angle)';
  }
}

/// @nodoc
abstract mixin class $GraphLinkViewGeometryCopyWith<$Res> {
  factory $GraphLinkViewGeometryCopyWith(GraphLinkViewGeometry value,
          $Res Function(GraphLinkViewGeometry) _then) =
      _$GraphLinkViewGeometryCopyWithImpl;
  @useResult
  $Res call(
      {Rect bounds,
      GraphConnectionGeometry connection,
      double thickness,
      double angle});

  $GraphConnectionGeometryCopyWith<$Res> get connection;
}

/// @nodoc
class _$GraphLinkViewGeometryCopyWithImpl<$Res>
    implements $GraphLinkViewGeometryCopyWith<$Res> {
  _$GraphLinkViewGeometryCopyWithImpl(this._self, this._then);

  final GraphLinkViewGeometry _self;
  final $Res Function(GraphLinkViewGeometry) _then;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bounds = null,
    Object? connection = null,
    Object? thickness = null,
    Object? angle = null,
  }) {
    return _then(_self.copyWith(
      bounds: null == bounds
          ? _self.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      connection: null == connection
          ? _self.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as GraphConnectionGeometry,
      thickness: null == thickness
          ? _self.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
      angle: null == angle
          ? _self.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionGeometryCopyWith<$Res> get connection {
    return $GraphConnectionGeometryCopyWith<$Res>(_self.connection, (value) {
      return _then(_self.copyWith(connection: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphLinkViewGeometry].
extension GraphLinkViewGeometryPatterns on GraphLinkViewGeometry {
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
    TResult Function(_GraphLinkViewGeometry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry() when $default != null:
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
    TResult Function(_GraphLinkViewGeometry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry():
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
    TResult? Function(_GraphLinkViewGeometry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry() when $default != null:
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
    TResult Function(Rect bounds, GraphConnectionGeometry connection,
            double thickness, double angle)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry() when $default != null:
        return $default(
            _that.bounds, _that.connection, _that.thickness, _that.angle);
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
    TResult Function(Rect bounds, GraphConnectionGeometry connection,
            double thickness, double angle)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry():
        return $default(
            _that.bounds, _that.connection, _that.thickness, _that.angle);
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
    TResult? Function(Rect bounds, GraphConnectionGeometry connection,
            double thickness, double angle)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphLinkViewGeometry() when $default != null:
        return $default(
            _that.bounds, _that.connection, _that.thickness, _that.angle);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphLinkViewGeometry extends GraphLinkViewGeometry
    with DiagnosticableTreeMixin {
  const _GraphLinkViewGeometry(
      {required this.bounds,
      required this.connection,
      required this.thickness,
      required this.angle})
      : super._();

  @override
  final Rect bounds;
  @override
  final GraphConnectionGeometry connection;
  @override
  final double thickness;
  @override
  final double angle;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphLinkViewGeometryCopyWith<_GraphLinkViewGeometry> get copyWith =>
      __$GraphLinkViewGeometryCopyWithImpl<_GraphLinkViewGeometry>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphLinkViewGeometry'))
      ..add(DiagnosticsProperty('bounds', bounds))
      ..add(DiagnosticsProperty('connection', connection))
      ..add(DiagnosticsProperty('thickness', thickness))
      ..add(DiagnosticsProperty('angle', angle));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphLinkViewGeometry &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.thickness, thickness) ||
                other.thickness == thickness) &&
            (identical(other.angle, angle) || other.angle == angle));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, bounds, connection, thickness, angle);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphLinkViewGeometry(bounds: $bounds, connection: $connection, thickness: $thickness, angle: $angle)';
  }
}

/// @nodoc
abstract mixin class _$GraphLinkViewGeometryCopyWith<$Res>
    implements $GraphLinkViewGeometryCopyWith<$Res> {
  factory _$GraphLinkViewGeometryCopyWith(_GraphLinkViewGeometry value,
          $Res Function(_GraphLinkViewGeometry) _then) =
      __$GraphLinkViewGeometryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Rect bounds,
      GraphConnectionGeometry connection,
      double thickness,
      double angle});

  @override
  $GraphConnectionGeometryCopyWith<$Res> get connection;
}

/// @nodoc
class __$GraphLinkViewGeometryCopyWithImpl<$Res>
    implements _$GraphLinkViewGeometryCopyWith<$Res> {
  __$GraphLinkViewGeometryCopyWithImpl(this._self, this._then);

  final _GraphLinkViewGeometry _self;
  final $Res Function(_GraphLinkViewGeometry) _then;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bounds = null,
    Object? connection = null,
    Object? thickness = null,
    Object? angle = null,
  }) {
    return _then(_GraphLinkViewGeometry(
      bounds: null == bounds
          ? _self.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      connection: null == connection
          ? _self.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as GraphConnectionGeometry,
      thickness: null == thickness
          ? _self.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
      angle: null == angle
          ? _self.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionGeometryCopyWith<$Res> get connection {
    return $GraphConnectionGeometryCopyWith<$Res>(_self.connection, (value) {
      return _then(_self.copyWith(connection: value));
    });
  }
}

/// @nodoc
mixin _$GraphConnectionGeometry implements DiagnosticableTreeMixin {
  /// The source node's layout geometry from which the link originates.
  GraphNodeViewGeometry get source;

  /// The target node's layout geometry where the link terminates.
  GraphNodeViewGeometry get target;

  /// The specific points where the link intersects with source and target nodes.
  GraphConnectionPoints get connectionPoints;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphConnectionGeometryCopyWith<GraphConnectionGeometry> get copyWith =>
      _$GraphConnectionGeometryCopyWithImpl<GraphConnectionGeometry>(
          this as GraphConnectionGeometry, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphConnectionGeometry'))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('target', target))
      ..add(DiagnosticsProperty('connectionPoints', connectionPoints));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphConnectionGeometry &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.connectionPoints, connectionPoints) ||
                other.connectionPoints == connectionPoints));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, source, target, connectionPoints);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionGeometry(source: $source, target: $target, connectionPoints: $connectionPoints)';
  }
}

/// @nodoc
abstract mixin class $GraphConnectionGeometryCopyWith<$Res> {
  factory $GraphConnectionGeometryCopyWith(GraphConnectionGeometry value,
          $Res Function(GraphConnectionGeometry) _then) =
      _$GraphConnectionGeometryCopyWithImpl;
  @useResult
  $Res call(
      {GraphNodeViewGeometry source,
      GraphNodeViewGeometry target,
      GraphConnectionPoints connectionPoints});

  $GraphNodeViewGeometryCopyWith<$Res> get source;
  $GraphNodeViewGeometryCopyWith<$Res> get target;
  $GraphConnectionPointsCopyWith<$Res> get connectionPoints;
}

/// @nodoc
class _$GraphConnectionGeometryCopyWithImpl<$Res>
    implements $GraphConnectionGeometryCopyWith<$Res> {
  _$GraphConnectionGeometryCopyWithImpl(this._self, this._then);

  final GraphConnectionGeometry _self;
  final $Res Function(GraphConnectionGeometry) _then;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? connectionPoints = null,
  }) {
    return _then(_self.copyWith(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      target: null == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      connectionPoints: null == connectionPoints
          ? _self.connectionPoints
          : connectionPoints // ignore: cast_nullable_to_non_nullable
              as GraphConnectionPoints,
    ));
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get source {
    return $GraphNodeViewGeometryCopyWith<$Res>(_self.source, (value) {
      return _then(_self.copyWith(source: value));
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get target {
    return $GraphNodeViewGeometryCopyWith<$Res>(_self.target, (value) {
      return _then(_self.copyWith(target: value));
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionPointsCopyWith<$Res> get connectionPoints {
    return $GraphConnectionPointsCopyWith<$Res>(_self.connectionPoints,
        (value) {
      return _then(_self.copyWith(connectionPoints: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GraphConnectionGeometry].
extension GraphConnectionGeometryPatterns on GraphConnectionGeometry {
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
    TResult Function(_GraphConnectionGeometry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry() when $default != null:
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
    TResult Function(_GraphConnectionGeometry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry():
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
    TResult? Function(_GraphConnectionGeometry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry() when $default != null:
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
    TResult Function(GraphNodeViewGeometry source, GraphNodeViewGeometry target,
            GraphConnectionPoints connectionPoints)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry() when $default != null:
        return $default(_that.source, _that.target, _that.connectionPoints);
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
    TResult Function(GraphNodeViewGeometry source, GraphNodeViewGeometry target,
            GraphConnectionPoints connectionPoints)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry():
        return $default(_that.source, _that.target, _that.connectionPoints);
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
            GraphNodeViewGeometry source,
            GraphNodeViewGeometry target,
            GraphConnectionPoints connectionPoints)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphConnectionGeometry() when $default != null:
        return $default(_that.source, _that.target, _that.connectionPoints);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphConnectionGeometry
    with DiagnosticableTreeMixin
    implements GraphConnectionGeometry {
  const _GraphConnectionGeometry(
      {required this.source,
      required this.target,
      required this.connectionPoints});

  /// The source node's layout geometry from which the link originates.
  @override
  final GraphNodeViewGeometry source;

  /// The target node's layout geometry where the link terminates.
  @override
  final GraphNodeViewGeometry target;

  /// The specific points where the link intersects with source and target nodes.
  @override
  final GraphConnectionPoints connectionPoints;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphConnectionGeometryCopyWith<_GraphConnectionGeometry> get copyWith =>
      __$GraphConnectionGeometryCopyWithImpl<_GraphConnectionGeometry>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphConnectionGeometry'))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('target', target))
      ..add(DiagnosticsProperty('connectionPoints', connectionPoints));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphConnectionGeometry &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.connectionPoints, connectionPoints) ||
                other.connectionPoints == connectionPoints));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, source, target, connectionPoints);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionGeometry(source: $source, target: $target, connectionPoints: $connectionPoints)';
  }
}

/// @nodoc
abstract mixin class _$GraphConnectionGeometryCopyWith<$Res>
    implements $GraphConnectionGeometryCopyWith<$Res> {
  factory _$GraphConnectionGeometryCopyWith(_GraphConnectionGeometry value,
          $Res Function(_GraphConnectionGeometry) _then) =
      __$GraphConnectionGeometryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {GraphNodeViewGeometry source,
      GraphNodeViewGeometry target,
      GraphConnectionPoints connectionPoints});

  @override
  $GraphNodeViewGeometryCopyWith<$Res> get source;
  @override
  $GraphNodeViewGeometryCopyWith<$Res> get target;
  @override
  $GraphConnectionPointsCopyWith<$Res> get connectionPoints;
}

/// @nodoc
class __$GraphConnectionGeometryCopyWithImpl<$Res>
    implements _$GraphConnectionGeometryCopyWith<$Res> {
  __$GraphConnectionGeometryCopyWithImpl(this._self, this._then);

  final _GraphConnectionGeometry _self;
  final $Res Function(_GraphConnectionGeometry) _then;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? connectionPoints = null,
  }) {
    return _then(_GraphConnectionGeometry(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      target: null == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      connectionPoints: null == connectionPoints
          ? _self.connectionPoints
          : connectionPoints // ignore: cast_nullable_to_non_nullable
              as GraphConnectionPoints,
    ));
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get source {
    return $GraphNodeViewGeometryCopyWith<$Res>(_self.source, (value) {
      return _then(_self.copyWith(source: value));
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get target {
    return $GraphNodeViewGeometryCopyWith<$Res>(_self.target, (value) {
      return _then(_self.copyWith(target: value));
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionPointsCopyWith<$Res> get connectionPoints {
    return $GraphConnectionPointsCopyWith<$Res>(_self.connectionPoints,
        (value) {
      return _then(_self.copyWith(connectionPoints: value));
    });
  }
}

/// @nodoc
mixin _$GraphViewGeometry implements DiagnosticableTreeMixin {
  Offset get position;
  Size get size;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphViewGeometryCopyWith<GraphViewGeometry> get copyWith =>
      _$GraphViewGeometryCopyWithImpl<GraphViewGeometry>(
          this as GraphViewGeometry, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphViewGeometry'))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphViewGeometry &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position, size);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphViewGeometry(position: $position, size: $size)';
  }
}

/// @nodoc
abstract mixin class $GraphViewGeometryCopyWith<$Res> {
  factory $GraphViewGeometryCopyWith(
          GraphViewGeometry value, $Res Function(GraphViewGeometry) _then) =
      _$GraphViewGeometryCopyWithImpl;
  @useResult
  $Res call({Offset position, Size size});
}

/// @nodoc
class _$GraphViewGeometryCopyWithImpl<$Res>
    implements $GraphViewGeometryCopyWith<$Res> {
  _$GraphViewGeometryCopyWithImpl(this._self, this._then);

  final GraphViewGeometry _self;
  final $Res Function(GraphViewGeometry) _then;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? size = null,
  }) {
    return _then(_self.copyWith(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphViewGeometry].
extension GraphViewGeometryPatterns on GraphViewGeometry {
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
    TResult Function(_GraphViewGeometry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry() when $default != null:
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
    TResult Function(_GraphViewGeometry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry():
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
    TResult? Function(_GraphViewGeometry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry() when $default != null:
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
    TResult Function(Offset position, Size size)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry() when $default != null:
        return $default(_that.position, _that.size);
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
    TResult Function(Offset position, Size size) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry():
        return $default(_that.position, _that.size);
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
    TResult? Function(Offset position, Size size)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphViewGeometry() when $default != null:
        return $default(_that.position, _that.size);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphViewGeometry
    with DiagnosticableTreeMixin
    implements GraphViewGeometry {
  const _GraphViewGeometry({required this.position, required this.size});

  @override
  final Offset position;
  @override
  final Size size;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphViewGeometryCopyWith<_GraphViewGeometry> get copyWith =>
      __$GraphViewGeometryCopyWithImpl<_GraphViewGeometry>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GraphViewGeometry'))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphViewGeometry &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position, size);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphViewGeometry(position: $position, size: $size)';
  }
}

/// @nodoc
abstract mixin class _$GraphViewGeometryCopyWith<$Res>
    implements $GraphViewGeometryCopyWith<$Res> {
  factory _$GraphViewGeometryCopyWith(
          _GraphViewGeometry value, $Res Function(_GraphViewGeometry) _then) =
      __$GraphViewGeometryCopyWithImpl;
  @override
  @useResult
  $Res call({Offset position, Size size});
}

/// @nodoc
class __$GraphViewGeometryCopyWithImpl<$Res>
    implements _$GraphViewGeometryCopyWith<$Res> {
  __$GraphViewGeometryCopyWithImpl(this._self, this._then);

  final _GraphViewGeometry _self;
  final $Res Function(_GraphViewGeometry) _then;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? position = null,
    Object? size = null,
  }) {
    return _then(_GraphViewGeometry(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

// dart format on
