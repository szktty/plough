// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tooltip_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphTooltipData {
  DateTime? get showRequestTime => throw _privateConstructorUsedError;
  DateTime? get hideRequestTime => throw _privateConstructorUsedError;

  /// Create a copy of GraphTooltipData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphTooltipDataCopyWith<GraphTooltipData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphTooltipDataCopyWith<$Res> {
  factory $GraphTooltipDataCopyWith(
          GraphTooltipData value, $Res Function(GraphTooltipData) then) =
      _$GraphTooltipDataCopyWithImpl<$Res, GraphTooltipData>;
  @useResult
  $Res call({DateTime? showRequestTime, DateTime? hideRequestTime});
}

/// @nodoc
class _$GraphTooltipDataCopyWithImpl<$Res, $Val extends GraphTooltipData>
    implements $GraphTooltipDataCopyWith<$Res> {
  _$GraphTooltipDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphTooltipData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showRequestTime = freezed,
    Object? hideRequestTime = freezed,
  }) {
    return _then(_value.copyWith(
      showRequestTime: freezed == showRequestTime
          ? _value.showRequestTime
          : showRequestTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hideRequestTime: freezed == hideRequestTime
          ? _value.hideRequestTime
          : hideRequestTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphTooltipDataImplCopyWith<$Res>
    implements $GraphTooltipDataCopyWith<$Res> {
  factory _$$GraphTooltipDataImplCopyWith(_$GraphTooltipDataImpl value,
          $Res Function(_$GraphTooltipDataImpl) then) =
      __$$GraphTooltipDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime? showRequestTime, DateTime? hideRequestTime});
}

/// @nodoc
class __$$GraphTooltipDataImplCopyWithImpl<$Res>
    extends _$GraphTooltipDataCopyWithImpl<$Res, _$GraphTooltipDataImpl>
    implements _$$GraphTooltipDataImplCopyWith<$Res> {
  __$$GraphTooltipDataImplCopyWithImpl(_$GraphTooltipDataImpl _value,
      $Res Function(_$GraphTooltipDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphTooltipData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showRequestTime = freezed,
    Object? hideRequestTime = freezed,
  }) {
    return _then(_$GraphTooltipDataImpl(
      showRequestTime: freezed == showRequestTime
          ? _value.showRequestTime
          : showRequestTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hideRequestTime: freezed == hideRequestTime
          ? _value.hideRequestTime
          : hideRequestTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$GraphTooltipDataImpl implements _GraphTooltipData {
  const _$GraphTooltipDataImpl({this.showRequestTime, this.hideRequestTime});

  @override
  final DateTime? showRequestTime;
  @override
  final DateTime? hideRequestTime;

  @override
  String toString() {
    return 'GraphTooltipData(showRequestTime: $showRequestTime, hideRequestTime: $hideRequestTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphTooltipDataImpl &&
            (identical(other.showRequestTime, showRequestTime) ||
                other.showRequestTime == showRequestTime) &&
            (identical(other.hideRequestTime, hideRequestTime) ||
                other.hideRequestTime == hideRequestTime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, showRequestTime, hideRequestTime);

  /// Create a copy of GraphTooltipData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphTooltipDataImplCopyWith<_$GraphTooltipDataImpl> get copyWith =>
      __$$GraphTooltipDataImplCopyWithImpl<_$GraphTooltipDataImpl>(
          this, _$identity);
}

abstract class _GraphTooltipData implements GraphTooltipData {
  const factory _GraphTooltipData(
      {final DateTime? showRequestTime,
      final DateTime? hideRequestTime}) = _$GraphTooltipDataImpl;

  @override
  DateTime? get showRequestTime;
  @override
  DateTime? get hideRequestTime;

  /// Create a copy of GraphTooltipData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphTooltipDataImplCopyWith<_$GraphTooltipDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
