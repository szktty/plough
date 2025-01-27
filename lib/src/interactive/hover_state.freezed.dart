// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hover_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphHoverData {
  DateTime? get lastHoverTime => throw _privateConstructorUsedError;
  Offset? get lastHoverPosition => throw _privateConstructorUsedError;

  /// Create a copy of GraphHoverData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphHoverDataCopyWith<GraphHoverData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphHoverDataCopyWith<$Res> {
  factory $GraphHoverDataCopyWith(
          GraphHoverData value, $Res Function(GraphHoverData) then) =
      _$GraphHoverDataCopyWithImpl<$Res, GraphHoverData>;
  @useResult
  $Res call({DateTime? lastHoverTime, Offset? lastHoverPosition});
}

/// @nodoc
class _$GraphHoverDataCopyWithImpl<$Res, $Val extends GraphHoverData>
    implements $GraphHoverDataCopyWith<$Res> {
  _$GraphHoverDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphHoverData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastHoverTime = freezed,
    Object? lastHoverPosition = freezed,
  }) {
    return _then(_value.copyWith(
      lastHoverTime: freezed == lastHoverTime
          ? _value.lastHoverTime
          : lastHoverTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastHoverPosition: freezed == lastHoverPosition
          ? _value.lastHoverPosition
          : lastHoverPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphHoverDataImplCopyWith<$Res>
    implements $GraphHoverDataCopyWith<$Res> {
  factory _$$GraphHoverDataImplCopyWith(_$GraphHoverDataImpl value,
          $Res Function(_$GraphHoverDataImpl) then) =
      __$$GraphHoverDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime? lastHoverTime, Offset? lastHoverPosition});
}

/// @nodoc
class __$$GraphHoverDataImplCopyWithImpl<$Res>
    extends _$GraphHoverDataCopyWithImpl<$Res, _$GraphHoverDataImpl>
    implements _$$GraphHoverDataImplCopyWith<$Res> {
  __$$GraphHoverDataImplCopyWithImpl(
      _$GraphHoverDataImpl _value, $Res Function(_$GraphHoverDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphHoverData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastHoverTime = freezed,
    Object? lastHoverPosition = freezed,
  }) {
    return _then(_$GraphHoverDataImpl(
      lastHoverTime: freezed == lastHoverTime
          ? _value.lastHoverTime
          : lastHoverTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastHoverPosition: freezed == lastHoverPosition
          ? _value.lastHoverPosition
          : lastHoverPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
    ));
  }
}

/// @nodoc

class _$GraphHoverDataImpl implements _GraphHoverData {
  const _$GraphHoverDataImpl({this.lastHoverTime, this.lastHoverPosition});

  @override
  final DateTime? lastHoverTime;
  @override
  final Offset? lastHoverPosition;

  @override
  String toString() {
    return 'GraphHoverData(lastHoverTime: $lastHoverTime, lastHoverPosition: $lastHoverPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphHoverDataImpl &&
            (identical(other.lastHoverTime, lastHoverTime) ||
                other.lastHoverTime == lastHoverTime) &&
            (identical(other.lastHoverPosition, lastHoverPosition) ||
                other.lastHoverPosition == lastHoverPosition));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lastHoverTime, lastHoverPosition);

  /// Create a copy of GraphHoverData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphHoverDataImplCopyWith<_$GraphHoverDataImpl> get copyWith =>
      __$$GraphHoverDataImplCopyWithImpl<_$GraphHoverDataImpl>(
          this, _$identity);
}

abstract class _GraphHoverData implements GraphHoverData {
  const factory _GraphHoverData(
      {final DateTime? lastHoverTime,
      final Offset? lastHoverPosition}) = _$GraphHoverDataImpl;

  @override
  DateTime? get lastHoverTime;
  @override
  Offset? get lastHoverPosition;

  /// Create a copy of GraphHoverData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphHoverDataImplCopyWith<_$GraphHoverDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
