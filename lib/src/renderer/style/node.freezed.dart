// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphDefaultNodeRendererStyle {
  /// The background color of the node.
  Color get color;

  /// The color of the node's border.
  Color get borderColor;

  /// The color of the node's label text.
  Color get labelColor;

  /// The color of the node's ID text.
  Color get idColor;

  /// The background color when the node is hovered.
  Color get hoverColor;

  /// The background color when the node is both selected and hovered.
  Color get selectedHoverColor;

  /// The border color when the node is selected.
  Color get selectedBorderColor; // Complementary color
  /// The background color for emphasized nodes.
  Color get highlightColor;

  /// The radius of circular nodes.
  ///
  /// If null, the radius is automatically calculated based on the content.
  double? get radius;

  /// The fixed width of the node.
  ///
  /// If null, the width is automatically calculated based on the content.
  double? get width;

  /// The fixed height of the node.
  ///
  /// If null, the height is automatically calculated based on the content.
  double? get height;

  /// The minimum width constraint for the node.
  double get minWidth;

  /// The minimum height constraint for the node.
  double get minHeight;

  /// The width of the node's border in normal state.
  double get borderWidth;

  /// The width of the node's border when hovered.
  double get hoverBorderWidth;

  /// The width of the node's border when selected.
  double get selectedBorderWidth;

  /// The width of the node's border when both selected and hovered.
  double get selectedHoverBorderWidth;

  /// The width of the node's border when selection ends.
  double get selectedUnhoverBorderWidth;

  /// The shape of the node. Can be either circle or rectangle.
  GraphDefaultNodeRendererShape get shape;

  /// The padding inside the node's border.
  ///
  /// This padding is applied between the node's border and its child content.
  /// Defaults to 8 pixels on all sides.
  EdgeInsets get padding;

  /// Create a copy of GraphDefaultNodeRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphDefaultNodeRendererStyleCopyWith<GraphDefaultNodeRendererStyle>
      get copyWith => _$GraphDefaultNodeRendererStyleCopyWithImpl<
              GraphDefaultNodeRendererStyle>(
          this as GraphDefaultNodeRendererStyle, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphDefaultNodeRendererStyle &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.labelColor, labelColor) ||
                other.labelColor == labelColor) &&
            (identical(other.idColor, idColor) || other.idColor == idColor) &&
            (identical(other.hoverColor, hoverColor) ||
                other.hoverColor == hoverColor) &&
            (identical(other.selectedHoverColor, selectedHoverColor) ||
                other.selectedHoverColor == selectedHoverColor) &&
            (identical(other.selectedBorderColor, selectedBorderColor) ||
                other.selectedBorderColor == selectedBorderColor) &&
            (identical(other.highlightColor, highlightColor) ||
                other.highlightColor == highlightColor) &&
            (identical(other.radius, radius) || other.radius == radius) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.minWidth, minWidth) ||
                other.minWidth == minWidth) &&
            (identical(other.minHeight, minHeight) ||
                other.minHeight == minHeight) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.hoverBorderWidth, hoverBorderWidth) ||
                other.hoverBorderWidth == hoverBorderWidth) &&
            (identical(other.selectedBorderWidth, selectedBorderWidth) ||
                other.selectedBorderWidth == selectedBorderWidth) &&
            (identical(
                    other.selectedHoverBorderWidth, selectedHoverBorderWidth) ||
                other.selectedHoverBorderWidth == selectedHoverBorderWidth) &&
            (identical(other.selectedUnhoverBorderWidth,
                    selectedUnhoverBorderWidth) ||
                other.selectedUnhoverBorderWidth ==
                    selectedUnhoverBorderWidth) &&
            (identical(other.shape, shape) || other.shape == shape) &&
            (identical(other.padding, padding) || other.padding == padding));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        color,
        borderColor,
        labelColor,
        idColor,
        hoverColor,
        selectedHoverColor,
        selectedBorderColor,
        highlightColor,
        radius,
        width,
        height,
        minWidth,
        minHeight,
        borderWidth,
        hoverBorderWidth,
        selectedBorderWidth,
        selectedHoverBorderWidth,
        selectedUnhoverBorderWidth,
        shape,
        padding
      ]);

  @override
  String toString() {
    return 'GraphDefaultNodeRendererStyle(color: $color, borderColor: $borderColor, labelColor: $labelColor, idColor: $idColor, hoverColor: $hoverColor, selectedHoverColor: $selectedHoverColor, selectedBorderColor: $selectedBorderColor, highlightColor: $highlightColor, radius: $radius, width: $width, height: $height, minWidth: $minWidth, minHeight: $minHeight, borderWidth: $borderWidth, hoverBorderWidth: $hoverBorderWidth, selectedBorderWidth: $selectedBorderWidth, selectedHoverBorderWidth: $selectedHoverBorderWidth, selectedUnhoverBorderWidth: $selectedUnhoverBorderWidth, shape: $shape, padding: $padding)';
  }
}

/// @nodoc
abstract mixin class $GraphDefaultNodeRendererStyleCopyWith<$Res> {
  factory $GraphDefaultNodeRendererStyleCopyWith(
          GraphDefaultNodeRendererStyle value,
          $Res Function(GraphDefaultNodeRendererStyle) _then) =
      _$GraphDefaultNodeRendererStyleCopyWithImpl;
  @useResult
  $Res call(
      {Color color,
      Color borderColor,
      Color labelColor,
      Color idColor,
      Color hoverColor,
      Color selectedHoverColor,
      Color selectedBorderColor,
      Color highlightColor,
      double? radius,
      double? width,
      double? height,
      double minWidth,
      double minHeight,
      double borderWidth,
      double hoverBorderWidth,
      double selectedBorderWidth,
      double selectedHoverBorderWidth,
      double selectedUnhoverBorderWidth,
      GraphDefaultNodeRendererShape shape,
      EdgeInsets padding});
}

/// @nodoc
class _$GraphDefaultNodeRendererStyleCopyWithImpl<$Res>
    implements $GraphDefaultNodeRendererStyleCopyWith<$Res> {
  _$GraphDefaultNodeRendererStyleCopyWithImpl(this._self, this._then);

  final GraphDefaultNodeRendererStyle _self;
  final $Res Function(GraphDefaultNodeRendererStyle) _then;

  /// Create a copy of GraphDefaultNodeRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? borderColor = null,
    Object? labelColor = null,
    Object? idColor = null,
    Object? hoverColor = null,
    Object? selectedHoverColor = null,
    Object? selectedBorderColor = null,
    Object? highlightColor = null,
    Object? radius = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? minWidth = null,
    Object? minHeight = null,
    Object? borderWidth = null,
    Object? hoverBorderWidth = null,
    Object? selectedBorderWidth = null,
    Object? selectedHoverBorderWidth = null,
    Object? selectedUnhoverBorderWidth = null,
    Object? shape = null,
    Object? padding = null,
  }) {
    return _then(_self.copyWith(
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      borderColor: null == borderColor
          ? _self.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      labelColor: null == labelColor
          ? _self.labelColor
          : labelColor // ignore: cast_nullable_to_non_nullable
              as Color,
      idColor: null == idColor
          ? _self.idColor
          : idColor // ignore: cast_nullable_to_non_nullable
              as Color,
      hoverColor: null == hoverColor
          ? _self.hoverColor
          : hoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedHoverColor: null == selectedHoverColor
          ? _self.selectedHoverColor
          : selectedHoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedBorderColor: null == selectedBorderColor
          ? _self.selectedBorderColor
          : selectedBorderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      highlightColor: null == highlightColor
          ? _self.highlightColor
          : highlightColor // ignore: cast_nullable_to_non_nullable
              as Color,
      radius: freezed == radius
          ? _self.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double?,
      width: freezed == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      minWidth: null == minWidth
          ? _self.minWidth
          : minWidth // ignore: cast_nullable_to_non_nullable
              as double,
      minHeight: null == minHeight
          ? _self.minHeight
          : minHeight // ignore: cast_nullable_to_non_nullable
              as double,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      hoverBorderWidth: null == hoverBorderWidth
          ? _self.hoverBorderWidth
          : hoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedBorderWidth: null == selectedBorderWidth
          ? _self.selectedBorderWidth
          : selectedBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedHoverBorderWidth: null == selectedHoverBorderWidth
          ? _self.selectedHoverBorderWidth
          : selectedHoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedUnhoverBorderWidth: null == selectedUnhoverBorderWidth
          ? _self.selectedUnhoverBorderWidth
          : selectedUnhoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as GraphDefaultNodeRendererShape,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphDefaultNodeRendererStyle].
extension GraphDefaultNodeRendererStylePatterns
    on GraphDefaultNodeRendererStyle {
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
    TResult Function(_GraphDefaultNodeRendererStyle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle() when $default != null:
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
    TResult Function(_GraphDefaultNodeRendererStyle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle():
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
    TResult? Function(_GraphDefaultNodeRendererStyle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle() when $default != null:
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
            Color color,
            Color borderColor,
            Color labelColor,
            Color idColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedBorderColor,
            Color highlightColor,
            double? radius,
            double? width,
            double? height,
            double minWidth,
            double minHeight,
            double borderWidth,
            double hoverBorderWidth,
            double selectedBorderWidth,
            double selectedHoverBorderWidth,
            double selectedUnhoverBorderWidth,
            GraphDefaultNodeRendererShape shape,
            EdgeInsets padding)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle() when $default != null:
        return $default(
            _that.color,
            _that.borderColor,
            _that.labelColor,
            _that.idColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedBorderColor,
            _that.highlightColor,
            _that.radius,
            _that.width,
            _that.height,
            _that.minWidth,
            _that.minHeight,
            _that.borderWidth,
            _that.hoverBorderWidth,
            _that.selectedBorderWidth,
            _that.selectedHoverBorderWidth,
            _that.selectedUnhoverBorderWidth,
            _that.shape,
            _that.padding);
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
            Color color,
            Color borderColor,
            Color labelColor,
            Color idColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedBorderColor,
            Color highlightColor,
            double? radius,
            double? width,
            double? height,
            double minWidth,
            double minHeight,
            double borderWidth,
            double hoverBorderWidth,
            double selectedBorderWidth,
            double selectedHoverBorderWidth,
            double selectedUnhoverBorderWidth,
            GraphDefaultNodeRendererShape shape,
            EdgeInsets padding)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle():
        return $default(
            _that.color,
            _that.borderColor,
            _that.labelColor,
            _that.idColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedBorderColor,
            _that.highlightColor,
            _that.radius,
            _that.width,
            _that.height,
            _that.minWidth,
            _that.minHeight,
            _that.borderWidth,
            _that.hoverBorderWidth,
            _that.selectedBorderWidth,
            _that.selectedHoverBorderWidth,
            _that.selectedUnhoverBorderWidth,
            _that.shape,
            _that.padding);
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
            Color color,
            Color borderColor,
            Color labelColor,
            Color idColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedBorderColor,
            Color highlightColor,
            double? radius,
            double? width,
            double? height,
            double minWidth,
            double minHeight,
            double borderWidth,
            double hoverBorderWidth,
            double selectedBorderWidth,
            double selectedHoverBorderWidth,
            double selectedUnhoverBorderWidth,
            GraphDefaultNodeRendererShape shape,
            EdgeInsets padding)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultNodeRendererStyle() when $default != null:
        return $default(
            _that.color,
            _that.borderColor,
            _that.labelColor,
            _that.idColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedBorderColor,
            _that.highlightColor,
            _that.radius,
            _that.width,
            _that.height,
            _that.minWidth,
            _that.minHeight,
            _that.borderWidth,
            _that.hoverBorderWidth,
            _that.selectedBorderWidth,
            _that.selectedHoverBorderWidth,
            _that.selectedUnhoverBorderWidth,
            _that.shape,
            _that.padding);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphDefaultNodeRendererStyle implements GraphDefaultNodeRendererStyle {
  const _GraphDefaultNodeRendererStyle(
      {this.color = const Color(0xFFE2E8F0),
      this.borderColor = const Color(0xFF64748B),
      this.labelColor = const Color(0xFF1E293B),
      this.idColor = Colors.grey,
      this.hoverColor = Colors.red,
      this.selectedHoverColor = Colors.green,
      this.selectedBorderColor = const Color(0xFF4A5568),
      this.highlightColor = Colors.yellow,
      this.radius,
      this.width,
      this.height,
      this.minWidth = 50,
      this.minHeight = 50,
      this.borderWidth = 2,
      this.hoverBorderWidth = 2,
      this.selectedBorderWidth = 2,
      this.selectedHoverBorderWidth = 2,
      this.selectedUnhoverBorderWidth = 2,
      this.shape = GraphDefaultNodeRendererShape.circle,
      this.padding = const EdgeInsets.all(8)});

  /// The background color of the node.
  @override
  @JsonKey()
  final Color color;

  /// The color of the node's border.
  @override
  @JsonKey()
  final Color borderColor;

  /// The color of the node's label text.
  @override
  @JsonKey()
  final Color labelColor;

  /// The color of the node's ID text.
  @override
  @JsonKey()
  final Color idColor;

  /// The background color when the node is hovered.
  @override
  @JsonKey()
  final Color hoverColor;

  /// The background color when the node is both selected and hovered.
  @override
  @JsonKey()
  final Color selectedHoverColor;

  /// The border color when the node is selected.
  @override
  @JsonKey()
  final Color selectedBorderColor;
// Complementary color
  /// The background color for emphasized nodes.
  @override
  @JsonKey()
  final Color highlightColor;

  /// The radius of circular nodes.
  ///
  /// If null, the radius is automatically calculated based on the content.
  @override
  final double? radius;

  /// The fixed width of the node.
  ///
  /// If null, the width is automatically calculated based on the content.
  @override
  final double? width;

  /// The fixed height of the node.
  ///
  /// If null, the height is automatically calculated based on the content.
  @override
  final double? height;

  /// The minimum width constraint for the node.
  @override
  @JsonKey()
  final double minWidth;

  /// The minimum height constraint for the node.
  @override
  @JsonKey()
  final double minHeight;

  /// The width of the node's border in normal state.
  @override
  @JsonKey()
  final double borderWidth;

  /// The width of the node's border when hovered.
  @override
  @JsonKey()
  final double hoverBorderWidth;

  /// The width of the node's border when selected.
  @override
  @JsonKey()
  final double selectedBorderWidth;

  /// The width of the node's border when both selected and hovered.
  @override
  @JsonKey()
  final double selectedHoverBorderWidth;

  /// The width of the node's border when selection ends.
  @override
  @JsonKey()
  final double selectedUnhoverBorderWidth;

  /// The shape of the node. Can be either circle or rectangle.
  @override
  @JsonKey()
  final GraphDefaultNodeRendererShape shape;

  /// The padding inside the node's border.
  ///
  /// This padding is applied between the node's border and its child content.
  /// Defaults to 8 pixels on all sides.
  @override
  @JsonKey()
  final EdgeInsets padding;

  /// Create a copy of GraphDefaultNodeRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphDefaultNodeRendererStyleCopyWith<_GraphDefaultNodeRendererStyle>
      get copyWith => __$GraphDefaultNodeRendererStyleCopyWithImpl<
          _GraphDefaultNodeRendererStyle>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphDefaultNodeRendererStyle &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.labelColor, labelColor) ||
                other.labelColor == labelColor) &&
            (identical(other.idColor, idColor) || other.idColor == idColor) &&
            (identical(other.hoverColor, hoverColor) ||
                other.hoverColor == hoverColor) &&
            (identical(other.selectedHoverColor, selectedHoverColor) ||
                other.selectedHoverColor == selectedHoverColor) &&
            (identical(other.selectedBorderColor, selectedBorderColor) ||
                other.selectedBorderColor == selectedBorderColor) &&
            (identical(other.highlightColor, highlightColor) ||
                other.highlightColor == highlightColor) &&
            (identical(other.radius, radius) || other.radius == radius) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.minWidth, minWidth) ||
                other.minWidth == minWidth) &&
            (identical(other.minHeight, minHeight) ||
                other.minHeight == minHeight) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.hoverBorderWidth, hoverBorderWidth) ||
                other.hoverBorderWidth == hoverBorderWidth) &&
            (identical(other.selectedBorderWidth, selectedBorderWidth) ||
                other.selectedBorderWidth == selectedBorderWidth) &&
            (identical(
                    other.selectedHoverBorderWidth, selectedHoverBorderWidth) ||
                other.selectedHoverBorderWidth == selectedHoverBorderWidth) &&
            (identical(other.selectedUnhoverBorderWidth,
                    selectedUnhoverBorderWidth) ||
                other.selectedUnhoverBorderWidth ==
                    selectedUnhoverBorderWidth) &&
            (identical(other.shape, shape) || other.shape == shape) &&
            (identical(other.padding, padding) || other.padding == padding));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        color,
        borderColor,
        labelColor,
        idColor,
        hoverColor,
        selectedHoverColor,
        selectedBorderColor,
        highlightColor,
        radius,
        width,
        height,
        minWidth,
        minHeight,
        borderWidth,
        hoverBorderWidth,
        selectedBorderWidth,
        selectedHoverBorderWidth,
        selectedUnhoverBorderWidth,
        shape,
        padding
      ]);

  @override
  String toString() {
    return 'GraphDefaultNodeRendererStyle(color: $color, borderColor: $borderColor, labelColor: $labelColor, idColor: $idColor, hoverColor: $hoverColor, selectedHoverColor: $selectedHoverColor, selectedBorderColor: $selectedBorderColor, highlightColor: $highlightColor, radius: $radius, width: $width, height: $height, minWidth: $minWidth, minHeight: $minHeight, borderWidth: $borderWidth, hoverBorderWidth: $hoverBorderWidth, selectedBorderWidth: $selectedBorderWidth, selectedHoverBorderWidth: $selectedHoverBorderWidth, selectedUnhoverBorderWidth: $selectedUnhoverBorderWidth, shape: $shape, padding: $padding)';
  }
}

/// @nodoc
abstract mixin class _$GraphDefaultNodeRendererStyleCopyWith<$Res>
    implements $GraphDefaultNodeRendererStyleCopyWith<$Res> {
  factory _$GraphDefaultNodeRendererStyleCopyWith(
          _GraphDefaultNodeRendererStyle value,
          $Res Function(_GraphDefaultNodeRendererStyle) _then) =
      __$GraphDefaultNodeRendererStyleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Color color,
      Color borderColor,
      Color labelColor,
      Color idColor,
      Color hoverColor,
      Color selectedHoverColor,
      Color selectedBorderColor,
      Color highlightColor,
      double? radius,
      double? width,
      double? height,
      double minWidth,
      double minHeight,
      double borderWidth,
      double hoverBorderWidth,
      double selectedBorderWidth,
      double selectedHoverBorderWidth,
      double selectedUnhoverBorderWidth,
      GraphDefaultNodeRendererShape shape,
      EdgeInsets padding});
}

/// @nodoc
class __$GraphDefaultNodeRendererStyleCopyWithImpl<$Res>
    implements _$GraphDefaultNodeRendererStyleCopyWith<$Res> {
  __$GraphDefaultNodeRendererStyleCopyWithImpl(this._self, this._then);

  final _GraphDefaultNodeRendererStyle _self;
  final $Res Function(_GraphDefaultNodeRendererStyle) _then;

  /// Create a copy of GraphDefaultNodeRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? color = null,
    Object? borderColor = null,
    Object? labelColor = null,
    Object? idColor = null,
    Object? hoverColor = null,
    Object? selectedHoverColor = null,
    Object? selectedBorderColor = null,
    Object? highlightColor = null,
    Object? radius = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? minWidth = null,
    Object? minHeight = null,
    Object? borderWidth = null,
    Object? hoverBorderWidth = null,
    Object? selectedBorderWidth = null,
    Object? selectedHoverBorderWidth = null,
    Object? selectedUnhoverBorderWidth = null,
    Object? shape = null,
    Object? padding = null,
  }) {
    return _then(_GraphDefaultNodeRendererStyle(
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      borderColor: null == borderColor
          ? _self.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      labelColor: null == labelColor
          ? _self.labelColor
          : labelColor // ignore: cast_nullable_to_non_nullable
              as Color,
      idColor: null == idColor
          ? _self.idColor
          : idColor // ignore: cast_nullable_to_non_nullable
              as Color,
      hoverColor: null == hoverColor
          ? _self.hoverColor
          : hoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedHoverColor: null == selectedHoverColor
          ? _self.selectedHoverColor
          : selectedHoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedBorderColor: null == selectedBorderColor
          ? _self.selectedBorderColor
          : selectedBorderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      highlightColor: null == highlightColor
          ? _self.highlightColor
          : highlightColor // ignore: cast_nullable_to_non_nullable
              as Color,
      radius: freezed == radius
          ? _self.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double?,
      width: freezed == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      minWidth: null == minWidth
          ? _self.minWidth
          : minWidth // ignore: cast_nullable_to_non_nullable
              as double,
      minHeight: null == minHeight
          ? _self.minHeight
          : minHeight // ignore: cast_nullable_to_non_nullable
              as double,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      hoverBorderWidth: null == hoverBorderWidth
          ? _self.hoverBorderWidth
          : hoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedBorderWidth: null == selectedBorderWidth
          ? _self.selectedBorderWidth
          : selectedBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedHoverBorderWidth: null == selectedHoverBorderWidth
          ? _self.selectedHoverBorderWidth
          : selectedHoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      selectedUnhoverBorderWidth: null == selectedUnhoverBorderWidth
          ? _self.selectedUnhoverBorderWidth
          : selectedUnhoverBorderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as GraphDefaultNodeRendererShape,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
    ));
  }
}

// dart format on
