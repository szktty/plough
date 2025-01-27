// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geometry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphConnectionPoints {
  /// The point where the link enters the target node.
  Offset get incoming => throw _privateConstructorUsedError;
  Offset get outgoing => throw _privateConstructorUsedError;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphConnectionPointsCopyWith<GraphConnectionPoints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphConnectionPointsCopyWith<$Res> {
  factory $GraphConnectionPointsCopyWith(GraphConnectionPoints value,
          $Res Function(GraphConnectionPoints) then) =
      _$GraphConnectionPointsCopyWithImpl<$Res, GraphConnectionPoints>;
  @useResult
  $Res call({Offset incoming, Offset outgoing});
}

/// @nodoc
class _$GraphConnectionPointsCopyWithImpl<$Res,
        $Val extends GraphConnectionPoints>
    implements $GraphConnectionPointsCopyWith<$Res> {
  _$GraphConnectionPointsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incoming = null,
    Object? outgoing = null,
  }) {
    return _then(_value.copyWith(
      incoming: null == incoming
          ? _value.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as Offset,
      outgoing: null == outgoing
          ? _value.outgoing
          : outgoing // ignore: cast_nullable_to_non_nullable
              as Offset,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphConnectionPointsImplCopyWith<$Res>
    implements $GraphConnectionPointsCopyWith<$Res> {
  factory _$$GraphConnectionPointsImplCopyWith(
          _$GraphConnectionPointsImpl value,
          $Res Function(_$GraphConnectionPointsImpl) then) =
      __$$GraphConnectionPointsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Offset incoming, Offset outgoing});
}

/// @nodoc
class __$$GraphConnectionPointsImplCopyWithImpl<$Res>
    extends _$GraphConnectionPointsCopyWithImpl<$Res,
        _$GraphConnectionPointsImpl>
    implements _$$GraphConnectionPointsImplCopyWith<$Res> {
  __$$GraphConnectionPointsImplCopyWithImpl(_$GraphConnectionPointsImpl _value,
      $Res Function(_$GraphConnectionPointsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incoming = null,
    Object? outgoing = null,
  }) {
    return _then(_$GraphConnectionPointsImpl(
      incoming: null == incoming
          ? _value.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as Offset,
      outgoing: null == outgoing
          ? _value.outgoing
          : outgoing // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc

class _$GraphConnectionPointsImpl extends _GraphConnectionPoints
    with DiagnosticableTreeMixin {
  const _$GraphConnectionPointsImpl(
      {required this.incoming, required this.outgoing})
      : super._();

  /// The point where the link enters the target node.
  @override
  final Offset incoming;
  @override
  final Offset outgoing;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionPoints(incoming: $incoming, outgoing: $outgoing)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphConnectionPoints'))
      ..add(DiagnosticsProperty('incoming', incoming))
      ..add(DiagnosticsProperty('outgoing', outgoing));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphConnectionPointsImpl &&
            (identical(other.incoming, incoming) ||
                other.incoming == incoming) &&
            (identical(other.outgoing, outgoing) ||
                other.outgoing == outgoing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, incoming, outgoing);

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphConnectionPointsImplCopyWith<_$GraphConnectionPointsImpl>
      get copyWith => __$$GraphConnectionPointsImplCopyWithImpl<
          _$GraphConnectionPointsImpl>(this, _$identity);
}

abstract class _GraphConnectionPoints extends GraphConnectionPoints {
  const factory _GraphConnectionPoints(
      {required final Offset incoming,
      required final Offset outgoing}) = _$GraphConnectionPointsImpl;
  const _GraphConnectionPoints._() : super._();

  /// The point where the link enters the target node.
  @override
  Offset get incoming;
  @override
  Offset get outgoing;

  /// Create a copy of GraphConnectionPoints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphConnectionPointsImplCopyWith<_$GraphConnectionPointsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GraphNodeViewGeometry {
  Rect get bounds => throw _privateConstructorUsedError;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphNodeViewGeometryCopyWith<GraphNodeViewGeometry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphNodeViewGeometryCopyWith<$Res> {
  factory $GraphNodeViewGeometryCopyWith(GraphNodeViewGeometry value,
          $Res Function(GraphNodeViewGeometry) then) =
      _$GraphNodeViewGeometryCopyWithImpl<$Res, GraphNodeViewGeometry>;
  @useResult
  $Res call({Rect bounds});
}

/// @nodoc
class _$GraphNodeViewGeometryCopyWithImpl<$Res,
        $Val extends GraphNodeViewGeometry>
    implements $GraphNodeViewGeometryCopyWith<$Res> {
  _$GraphNodeViewGeometryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bounds = null,
  }) {
    return _then(_value.copyWith(
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphNodeViewGeometryImplCopyWith<$Res>
    implements $GraphNodeViewGeometryCopyWith<$Res> {
  factory _$$GraphNodeViewGeometryImplCopyWith(
          _$GraphNodeViewGeometryImpl value,
          $Res Function(_$GraphNodeViewGeometryImpl) then) =
      __$$GraphNodeViewGeometryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Rect bounds});
}

/// @nodoc
class __$$GraphNodeViewGeometryImplCopyWithImpl<$Res>
    extends _$GraphNodeViewGeometryCopyWithImpl<$Res,
        _$GraphNodeViewGeometryImpl>
    implements _$$GraphNodeViewGeometryImplCopyWith<$Res> {
  __$$GraphNodeViewGeometryImplCopyWithImpl(_$GraphNodeViewGeometryImpl _value,
      $Res Function(_$GraphNodeViewGeometryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bounds = null,
  }) {
    return _then(_$GraphNodeViewGeometryImpl(
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// @nodoc

class _$GraphNodeViewGeometryImpl
    with DiagnosticableTreeMixin
    implements _GraphNodeViewGeometry {
  const _$GraphNodeViewGeometryImpl({required this.bounds});

  @override
  final Rect bounds;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphNodeViewGeometry(bounds: $bounds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphNodeViewGeometry'))
      ..add(DiagnosticsProperty('bounds', bounds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphNodeViewGeometryImpl &&
            (identical(other.bounds, bounds) || other.bounds == bounds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bounds);

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphNodeViewGeometryImplCopyWith<_$GraphNodeViewGeometryImpl>
      get copyWith => __$$GraphNodeViewGeometryImplCopyWithImpl<
          _$GraphNodeViewGeometryImpl>(this, _$identity);
}

abstract class _GraphNodeViewGeometry implements GraphNodeViewGeometry {
  const factory _GraphNodeViewGeometry({required final Rect bounds}) =
      _$GraphNodeViewGeometryImpl;

  @override
  Rect get bounds;

  /// Create a copy of GraphNodeViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphNodeViewGeometryImplCopyWith<_$GraphNodeViewGeometryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GraphLinkViewGeometry {
  Rect get bounds => throw _privateConstructorUsedError;
  GraphConnectionGeometry get connection => throw _privateConstructorUsedError;
  double get thickness => throw _privateConstructorUsedError;
  double get angle => throw _privateConstructorUsedError;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphLinkViewGeometryCopyWith<GraphLinkViewGeometry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphLinkViewGeometryCopyWith<$Res> {
  factory $GraphLinkViewGeometryCopyWith(GraphLinkViewGeometry value,
          $Res Function(GraphLinkViewGeometry) then) =
      _$GraphLinkViewGeometryCopyWithImpl<$Res, GraphLinkViewGeometry>;
  @useResult
  $Res call(
      {Rect bounds,
      GraphConnectionGeometry connection,
      double thickness,
      double angle});

  $GraphConnectionGeometryCopyWith<$Res> get connection;
}

/// @nodoc
class _$GraphLinkViewGeometryCopyWithImpl<$Res,
        $Val extends GraphLinkViewGeometry>
    implements $GraphLinkViewGeometryCopyWith<$Res> {
  _$GraphLinkViewGeometryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      connection: null == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as GraphConnectionGeometry,
      thickness: null == thickness
          ? _value.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
      angle: null == angle
          ? _value.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionGeometryCopyWith<$Res> get connection {
    return $GraphConnectionGeometryCopyWith<$Res>(_value.connection, (value) {
      return _then(_value.copyWith(connection: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GraphLinkViewGeometryImplCopyWith<$Res>
    implements $GraphLinkViewGeometryCopyWith<$Res> {
  factory _$$GraphLinkViewGeometryImplCopyWith(
          _$GraphLinkViewGeometryImpl value,
          $Res Function(_$GraphLinkViewGeometryImpl) then) =
      __$$GraphLinkViewGeometryImplCopyWithImpl<$Res>;
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
class __$$GraphLinkViewGeometryImplCopyWithImpl<$Res>
    extends _$GraphLinkViewGeometryCopyWithImpl<$Res,
        _$GraphLinkViewGeometryImpl>
    implements _$$GraphLinkViewGeometryImplCopyWith<$Res> {
  __$$GraphLinkViewGeometryImplCopyWithImpl(_$GraphLinkViewGeometryImpl _value,
      $Res Function(_$GraphLinkViewGeometryImpl) _then)
      : super(_value, _then);

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
    return _then(_$GraphLinkViewGeometryImpl(
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      connection: null == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as GraphConnectionGeometry,
      thickness: null == thickness
          ? _value.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
      angle: null == angle
          ? _value.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$GraphLinkViewGeometryImpl extends _GraphLinkViewGeometry
    with DiagnosticableTreeMixin {
  const _$GraphLinkViewGeometryImpl(
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphLinkViewGeometry(bounds: $bounds, connection: $connection, thickness: $thickness, angle: $angle)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
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
            other is _$GraphLinkViewGeometryImpl &&
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

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphLinkViewGeometryImplCopyWith<_$GraphLinkViewGeometryImpl>
      get copyWith => __$$GraphLinkViewGeometryImplCopyWithImpl<
          _$GraphLinkViewGeometryImpl>(this, _$identity);
}

abstract class _GraphLinkViewGeometry extends GraphLinkViewGeometry {
  const factory _GraphLinkViewGeometry(
      {required final Rect bounds,
      required final GraphConnectionGeometry connection,
      required final double thickness,
      required final double angle}) = _$GraphLinkViewGeometryImpl;
  const _GraphLinkViewGeometry._() : super._();

  @override
  Rect get bounds;
  @override
  GraphConnectionGeometry get connection;
  @override
  double get thickness;
  @override
  double get angle;

  /// Create a copy of GraphLinkViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphLinkViewGeometryImplCopyWith<_$GraphLinkViewGeometryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GraphConnectionGeometry {
  /// The source node's layout geometry from which the link originates.
  GraphNodeViewGeometry get source => throw _privateConstructorUsedError;

  /// The target node's layout geometry where the link terminates.
  GraphNodeViewGeometry get target => throw _privateConstructorUsedError;

  /// The specific points where the link intersects with source and target nodes.
  GraphConnectionPoints get connectionPoints =>
      throw _privateConstructorUsedError;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphConnectionGeometryCopyWith<GraphConnectionGeometry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphConnectionGeometryCopyWith<$Res> {
  factory $GraphConnectionGeometryCopyWith(GraphConnectionGeometry value,
          $Res Function(GraphConnectionGeometry) then) =
      _$GraphConnectionGeometryCopyWithImpl<$Res, GraphConnectionGeometry>;
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
class _$GraphConnectionGeometryCopyWithImpl<$Res,
        $Val extends GraphConnectionGeometry>
    implements $GraphConnectionGeometryCopyWith<$Res> {
  _$GraphConnectionGeometryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? connectionPoints = null,
  }) {
    return _then(_value.copyWith(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      connectionPoints: null == connectionPoints
          ? _value.connectionPoints
          : connectionPoints // ignore: cast_nullable_to_non_nullable
              as GraphConnectionPoints,
    ) as $Val);
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get source {
    return $GraphNodeViewGeometryCopyWith<$Res>(_value.source, (value) {
      return _then(_value.copyWith(source: value) as $Val);
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphNodeViewGeometryCopyWith<$Res> get target {
    return $GraphNodeViewGeometryCopyWith<$Res>(_value.target, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GraphConnectionPointsCopyWith<$Res> get connectionPoints {
    return $GraphConnectionPointsCopyWith<$Res>(_value.connectionPoints,
        (value) {
      return _then(_value.copyWith(connectionPoints: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GraphConnectionGeometryImplCopyWith<$Res>
    implements $GraphConnectionGeometryCopyWith<$Res> {
  factory _$$GraphConnectionGeometryImplCopyWith(
          _$GraphConnectionGeometryImpl value,
          $Res Function(_$GraphConnectionGeometryImpl) then) =
      __$$GraphConnectionGeometryImplCopyWithImpl<$Res>;
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
class __$$GraphConnectionGeometryImplCopyWithImpl<$Res>
    extends _$GraphConnectionGeometryCopyWithImpl<$Res,
        _$GraphConnectionGeometryImpl>
    implements _$$GraphConnectionGeometryImplCopyWith<$Res> {
  __$$GraphConnectionGeometryImplCopyWithImpl(
      _$GraphConnectionGeometryImpl _value,
      $Res Function(_$GraphConnectionGeometryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? connectionPoints = null,
  }) {
    return _then(_$GraphConnectionGeometryImpl(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as GraphNodeViewGeometry,
      connectionPoints: null == connectionPoints
          ? _value.connectionPoints
          : connectionPoints // ignore: cast_nullable_to_non_nullable
              as GraphConnectionPoints,
    ));
  }
}

/// @nodoc

class _$GraphConnectionGeometryImpl
    with DiagnosticableTreeMixin
    implements _GraphConnectionGeometry {
  const _$GraphConnectionGeometryImpl(
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphConnectionGeometry(source: $source, target: $target, connectionPoints: $connectionPoints)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
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
            other is _$GraphConnectionGeometryImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.connectionPoints, connectionPoints) ||
                other.connectionPoints == connectionPoints));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, source, target, connectionPoints);

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphConnectionGeometryImplCopyWith<_$GraphConnectionGeometryImpl>
      get copyWith => __$$GraphConnectionGeometryImplCopyWithImpl<
          _$GraphConnectionGeometryImpl>(this, _$identity);
}

abstract class _GraphConnectionGeometry implements GraphConnectionGeometry {
  const factory _GraphConnectionGeometry(
          {required final GraphNodeViewGeometry source,
          required final GraphNodeViewGeometry target,
          required final GraphConnectionPoints connectionPoints}) =
      _$GraphConnectionGeometryImpl;

  /// The source node's layout geometry from which the link originates.
  @override
  GraphNodeViewGeometry get source;

  /// The target node's layout geometry where the link terminates.
  @override
  GraphNodeViewGeometry get target;

  /// The specific points where the link intersects with source and target nodes.
  @override
  GraphConnectionPoints get connectionPoints;

  /// Create a copy of GraphConnectionGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphConnectionGeometryImplCopyWith<_$GraphConnectionGeometryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GraphViewGeometry {
  Offset get position => throw _privateConstructorUsedError;
  Size get size => throw _privateConstructorUsedError;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphViewGeometryCopyWith<GraphViewGeometry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphViewGeometryCopyWith<$Res> {
  factory $GraphViewGeometryCopyWith(
          GraphViewGeometry value, $Res Function(GraphViewGeometry) then) =
      _$GraphViewGeometryCopyWithImpl<$Res, GraphViewGeometry>;
  @useResult
  $Res call({Offset position, Size size});
}

/// @nodoc
class _$GraphViewGeometryCopyWithImpl<$Res, $Val extends GraphViewGeometry>
    implements $GraphViewGeometryCopyWith<$Res> {
  _$GraphViewGeometryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? size = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphViewGeometryImplCopyWith<$Res>
    implements $GraphViewGeometryCopyWith<$Res> {
  factory _$$GraphViewGeometryImplCopyWith(_$GraphViewGeometryImpl value,
          $Res Function(_$GraphViewGeometryImpl) then) =
      __$$GraphViewGeometryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Offset position, Size size});
}

/// @nodoc
class __$$GraphViewGeometryImplCopyWithImpl<$Res>
    extends _$GraphViewGeometryCopyWithImpl<$Res, _$GraphViewGeometryImpl>
    implements _$$GraphViewGeometryImplCopyWith<$Res> {
  __$$GraphViewGeometryImplCopyWithImpl(_$GraphViewGeometryImpl _value,
      $Res Function(_$GraphViewGeometryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? size = null,
  }) {
    return _then(_$GraphViewGeometryImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// @nodoc

class _$GraphViewGeometryImpl
    with DiagnosticableTreeMixin
    implements _GraphViewGeometry {
  const _$GraphViewGeometryImpl({required this.position, required this.size});

  @override
  final Offset position;
  @override
  final Size size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphViewGeometry(position: $position, size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphViewGeometry'))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphViewGeometryImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position, size);

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphViewGeometryImplCopyWith<_$GraphViewGeometryImpl> get copyWith =>
      __$$GraphViewGeometryImplCopyWithImpl<_$GraphViewGeometryImpl>(
          this, _$identity);
}

abstract class _GraphViewGeometry implements GraphViewGeometry {
  const factory _GraphViewGeometry(
      {required final Offset position,
      required final Size size}) = _$GraphViewGeometryImpl;

  @override
  Offset get position;
  @override
  Size get size;

  /// Create a copy of GraphViewGeometry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphViewGeometryImplCopyWith<_$GraphViewGeometryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
