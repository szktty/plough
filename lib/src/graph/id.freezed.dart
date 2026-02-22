// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphId {
  /// The category of graph element this ID represents (graph, node, or link).
  GraphIdType get type;

  /// The unique identifier string in UUIDv7 format.
  String get value;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphIdCopyWith<GraphId> get copyWith =>
      _$GraphIdCopyWithImpl<GraphId>(this as GraphId, _$identity);

  /// Serializes this GraphId to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphId &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, value);
}

/// @nodoc
abstract mixin class $GraphIdCopyWith<$Res> {
  factory $GraphIdCopyWith(GraphId value, $Res Function(GraphId) _then) =
      _$GraphIdCopyWithImpl;
  @useResult
  $Res call({GraphIdType type, String value});
}

/// @nodoc
class _$GraphIdCopyWithImpl<$Res> implements $GraphIdCopyWith<$Res> {
  _$GraphIdCopyWithImpl(this._self, this._then);

  final GraphId _self;
  final $Res Function(GraphId) _then;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as GraphIdType,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphId].
extension GraphIdPatterns on GraphId {
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
    TResult Function(_GraphId value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphId() when $default != null:
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
    TResult Function(_GraphId value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphId():
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
    TResult? Function(_GraphId value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphId() when $default != null:
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
    TResult Function(GraphIdType type, String value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphId() when $default != null:
        return $default(_that.type, _that.value);
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
    TResult Function(GraphIdType type, String value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphId():
        return $default(_that.type, _that.value);
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
    TResult? Function(GraphIdType type, String value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphId() when $default != null:
        return $default(_that.type, _that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GraphId extends GraphId {
  const _GraphId({required this.type, required this.value}) : super._();
  factory _GraphId.fromJson(Map<String, dynamic> json) =>
      _$GraphIdFromJson(json);

  /// The category of graph element this ID represents (graph, node, or link).
  @override
  final GraphIdType type;

  /// The unique identifier string in UUIDv7 format.
  @override
  final String value;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphIdCopyWith<_GraphId> get copyWith =>
      __$GraphIdCopyWithImpl<_GraphId>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GraphIdToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphId &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, value);
}

/// @nodoc
abstract mixin class _$GraphIdCopyWith<$Res> implements $GraphIdCopyWith<$Res> {
  factory _$GraphIdCopyWith(_GraphId value, $Res Function(_GraphId) _then) =
      __$GraphIdCopyWithImpl;
  @override
  @useResult
  $Res call({GraphIdType type, String value});
}

/// @nodoc
class __$GraphIdCopyWithImpl<$Res> implements _$GraphIdCopyWith<$Res> {
  __$GraphIdCopyWithImpl(this._self, this._then);

  final _GraphId _self;
  final $Res Function(_GraphId) _then;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? value = null,
  }) {
    return _then(_GraphId(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as GraphIdType,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
