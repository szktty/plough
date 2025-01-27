// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drag_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphDragData {
  DragStartDetails? get dragStartDetails => throw _privateConstructorUsedError;
  Offset? get dragStartPosition => throw _privateConstructorUsedError;
  DragUpdateDetails? get dragUpdateDetails =>
      throw _privateConstructorUsedError;

  /// Create a copy of GraphDragData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphDragDataCopyWith<GraphDragData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphDragDataCopyWith<$Res> {
  factory $GraphDragDataCopyWith(
          GraphDragData value, $Res Function(GraphDragData) then) =
      _$GraphDragDataCopyWithImpl<$Res, GraphDragData>;
  @useResult
  $Res call(
      {DragStartDetails? dragStartDetails,
      Offset? dragStartPosition,
      DragUpdateDetails? dragUpdateDetails});
}

/// @nodoc
class _$GraphDragDataCopyWithImpl<$Res, $Val extends GraphDragData>
    implements $GraphDragDataCopyWith<$Res> {
  _$GraphDragDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphDragData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dragStartDetails = freezed,
    Object? dragStartPosition = freezed,
    Object? dragUpdateDetails = freezed,
  }) {
    return _then(_value.copyWith(
      dragStartDetails: freezed == dragStartDetails
          ? _value.dragStartDetails
          : dragStartDetails // ignore: cast_nullable_to_non_nullable
              as DragStartDetails?,
      dragStartPosition: freezed == dragStartPosition
          ? _value.dragStartPosition
          : dragStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      dragUpdateDetails: freezed == dragUpdateDetails
          ? _value.dragUpdateDetails
          : dragUpdateDetails // ignore: cast_nullable_to_non_nullable
              as DragUpdateDetails?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphDragDataImplCopyWith<$Res>
    implements $GraphDragDataCopyWith<$Res> {
  factory _$$GraphDragDataImplCopyWith(
          _$GraphDragDataImpl value, $Res Function(_$GraphDragDataImpl) then) =
      __$$GraphDragDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DragStartDetails? dragStartDetails,
      Offset? dragStartPosition,
      DragUpdateDetails? dragUpdateDetails});
}

/// @nodoc
class __$$GraphDragDataImplCopyWithImpl<$Res>
    extends _$GraphDragDataCopyWithImpl<$Res, _$GraphDragDataImpl>
    implements _$$GraphDragDataImplCopyWith<$Res> {
  __$$GraphDragDataImplCopyWithImpl(
      _$GraphDragDataImpl _value, $Res Function(_$GraphDragDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphDragData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dragStartDetails = freezed,
    Object? dragStartPosition = freezed,
    Object? dragUpdateDetails = freezed,
  }) {
    return _then(_$GraphDragDataImpl(
      dragStartDetails: freezed == dragStartDetails
          ? _value.dragStartDetails
          : dragStartDetails // ignore: cast_nullable_to_non_nullable
              as DragStartDetails?,
      dragStartPosition: freezed == dragStartPosition
          ? _value.dragStartPosition
          : dragStartPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      dragUpdateDetails: freezed == dragUpdateDetails
          ? _value.dragUpdateDetails
          : dragUpdateDetails // ignore: cast_nullable_to_non_nullable
              as DragUpdateDetails?,
    ));
  }
}

/// @nodoc

class _$GraphDragDataImpl
    with DiagnosticableTreeMixin
    implements _GraphDragData {
  const _$GraphDragDataImpl(
      {this.dragStartDetails, this.dragStartPosition, this.dragUpdateDetails});

  @override
  final DragStartDetails? dragStartDetails;
  @override
  final Offset? dragStartPosition;
  @override
  final DragUpdateDetails? dragUpdateDetails;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraphDragData(dragStartDetails: $dragStartDetails, dragStartPosition: $dragStartPosition, dragUpdateDetails: $dragUpdateDetails)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GraphDragData'))
      ..add(DiagnosticsProperty('dragStartDetails', dragStartDetails))
      ..add(DiagnosticsProperty('dragStartPosition', dragStartPosition))
      ..add(DiagnosticsProperty('dragUpdateDetails', dragUpdateDetails));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphDragDataImpl &&
            (identical(other.dragStartDetails, dragStartDetails) ||
                other.dragStartDetails == dragStartDetails) &&
            (identical(other.dragStartPosition, dragStartPosition) ||
                other.dragStartPosition == dragStartPosition) &&
            (identical(other.dragUpdateDetails, dragUpdateDetails) ||
                other.dragUpdateDetails == dragUpdateDetails));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, dragStartDetails, dragStartPosition, dragUpdateDetails);

  /// Create a copy of GraphDragData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphDragDataImplCopyWith<_$GraphDragDataImpl> get copyWith =>
      __$$GraphDragDataImplCopyWithImpl<_$GraphDragDataImpl>(this, _$identity);
}

abstract class _GraphDragData implements GraphDragData {
  const factory _GraphDragData(
      {final DragStartDetails? dragStartDetails,
      final Offset? dragStartPosition,
      final DragUpdateDetails? dragUpdateDetails}) = _$GraphDragDataImpl;

  @override
  DragStartDetails? get dragStartDetails;
  @override
  Offset? get dragStartPosition;
  @override
  DragUpdateDetails? get dragUpdateDetails;

  /// Create a copy of GraphDragData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphDragDataImplCopyWith<_$GraphDragDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
