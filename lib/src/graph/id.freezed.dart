// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GraphId _$GraphIdFromJson(Map<String, dynamic> json) {
  return _GraphId.fromJson(json);
}

/// @nodoc
mixin _$GraphId {
  /// The category of graph element this ID represents (graph, node, or link).
  GraphIdType get type => throw _privateConstructorUsedError;

  /// The unique identifier string in UUIDv7 format.
  String get value => throw _privateConstructorUsedError;

  /// Serializes this GraphId to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphIdCopyWith<GraphId> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphIdCopyWith<$Res> {
  factory $GraphIdCopyWith(GraphId value, $Res Function(GraphId) then) =
      _$GraphIdCopyWithImpl<$Res, GraphId>;
  @useResult
  $Res call({GraphIdType type, String value});
}

/// @nodoc
class _$GraphIdCopyWithImpl<$Res, $Val extends GraphId>
    implements $GraphIdCopyWith<$Res> {
  _$GraphIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? value = null}) {
    return _then(
      _value.copyWith(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                as GraphIdType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                as String,
      ) as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GraphIdImplCopyWith<$Res> implements $GraphIdCopyWith<$Res> {
  factory _$$GraphIdImplCopyWith(
    _$GraphIdImpl value,
    $Res Function(_$GraphIdImpl) then,
  ) = __$$GraphIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GraphIdType type, String value});
}

/// @nodoc
class __$$GraphIdImplCopyWithImpl<$Res>
    extends _$GraphIdCopyWithImpl<$Res, _$GraphIdImpl>
    implements _$$GraphIdImplCopyWith<$Res> {
  __$$GraphIdImplCopyWithImpl(
    _$GraphIdImpl _value,
    $Res Function(_$GraphIdImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? value = null}) {
    return _then(
      _$GraphIdImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                as GraphIdType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GraphIdImpl extends _GraphId {
  const _$GraphIdImpl({required this.type, required this.value}) : super._();

  factory _$GraphIdImpl.fromJson(Map<String, dynamic> json) =>
      _$$GraphIdImplFromJson(json);

  /// The category of graph element this ID represents (graph, node, or link).
  @override
  final GraphIdType type;

  /// The unique identifier string in UUIDv7 format.
  @override
  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphIdImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, value);

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphIdImplCopyWith<_$GraphIdImpl> get copyWith =>
      __$$GraphIdImplCopyWithImpl<_$GraphIdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GraphIdImplToJson(this);
  }
}

abstract class _GraphId extends GraphId {
  const factory _GraphId({
    required final GraphIdType type,
    required final String value,
  }) = _$GraphIdImpl;
  const _GraphId._() : super._();

  factory _GraphId.fromJson(Map<String, dynamic> json) = _$GraphIdImpl.fromJson;

  /// The category of graph element this ID represents (graph, node, or link).
  @override
  GraphIdType get type;

  /// The unique identifier string in UUIDv7 format.
  @override
  String get value;

  /// Create a copy of GraphId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphIdImplCopyWith<_$GraphIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
