// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphDefaultLinkRendererStyle {
  /// The color of the arrow at the end of the link.
  Color get arrowColor;

  /// The color of the link line.
  Color get borderColor;

  /// The color of the link's label text.
  Color get labelColor;

  /// The color of the link when hovered.
  Color get hoverColor;

  /// The color when the link is both selected and hovered.
  Color get selectedHoverColor;

  /// The color when the selection ends.
  Color get selectedUnhoverColor;

  /// The color for emphasized links.
  Color get highlightColor;

  /// The size of the arrow at the end of the link.
  ///
  /// Width and height can be set independently.
  Size get arrowSize;

  /// Create a copy of GraphDefaultLinkRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GraphDefaultLinkRendererStyleCopyWith<GraphDefaultLinkRendererStyle>
      get copyWith => _$GraphDefaultLinkRendererStyleCopyWithImpl<
              GraphDefaultLinkRendererStyle>(
          this as GraphDefaultLinkRendererStyle, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GraphDefaultLinkRendererStyle &&
            (identical(other.arrowColor, arrowColor) ||
                other.arrowColor == arrowColor) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.labelColor, labelColor) ||
                other.labelColor == labelColor) &&
            (identical(other.hoverColor, hoverColor) ||
                other.hoverColor == hoverColor) &&
            (identical(other.selectedHoverColor, selectedHoverColor) ||
                other.selectedHoverColor == selectedHoverColor) &&
            (identical(other.selectedUnhoverColor, selectedUnhoverColor) ||
                other.selectedUnhoverColor == selectedUnhoverColor) &&
            (identical(other.highlightColor, highlightColor) ||
                other.highlightColor == highlightColor) &&
            (identical(other.arrowSize, arrowSize) ||
                other.arrowSize == arrowSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      arrowColor,
      borderColor,
      labelColor,
      hoverColor,
      selectedHoverColor,
      selectedUnhoverColor,
      highlightColor,
      arrowSize);

  @override
  String toString() {
    return 'GraphDefaultLinkRendererStyle(arrowColor: $arrowColor, borderColor: $borderColor, labelColor: $labelColor, hoverColor: $hoverColor, selectedHoverColor: $selectedHoverColor, selectedUnhoverColor: $selectedUnhoverColor, highlightColor: $highlightColor, arrowSize: $arrowSize)';
  }
}

/// @nodoc
abstract mixin class $GraphDefaultLinkRendererStyleCopyWith<$Res> {
  factory $GraphDefaultLinkRendererStyleCopyWith(
          GraphDefaultLinkRendererStyle value,
          $Res Function(GraphDefaultLinkRendererStyle) _then) =
      _$GraphDefaultLinkRendererStyleCopyWithImpl;
  @useResult
  $Res call(
      {Color arrowColor,
      Color borderColor,
      Color labelColor,
      Color hoverColor,
      Color selectedHoverColor,
      Color selectedUnhoverColor,
      Color highlightColor,
      Size arrowSize});
}

/// @nodoc
class _$GraphDefaultLinkRendererStyleCopyWithImpl<$Res>
    implements $GraphDefaultLinkRendererStyleCopyWith<$Res> {
  _$GraphDefaultLinkRendererStyleCopyWithImpl(this._self, this._then);

  final GraphDefaultLinkRendererStyle _self;
  final $Res Function(GraphDefaultLinkRendererStyle) _then;

  /// Create a copy of GraphDefaultLinkRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arrowColor = null,
    Object? borderColor = null,
    Object? labelColor = null,
    Object? hoverColor = null,
    Object? selectedHoverColor = null,
    Object? selectedUnhoverColor = null,
    Object? highlightColor = null,
    Object? arrowSize = null,
  }) {
    return _then(_self.copyWith(
      arrowColor: null == arrowColor
          ? _self.arrowColor
          : arrowColor // ignore: cast_nullable_to_non_nullable
              as Color,
      borderColor: null == borderColor
          ? _self.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      labelColor: null == labelColor
          ? _self.labelColor
          : labelColor // ignore: cast_nullable_to_non_nullable
              as Color,
      hoverColor: null == hoverColor
          ? _self.hoverColor
          : hoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedHoverColor: null == selectedHoverColor
          ? _self.selectedHoverColor
          : selectedHoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedUnhoverColor: null == selectedUnhoverColor
          ? _self.selectedUnhoverColor
          : selectedUnhoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      highlightColor: null == highlightColor
          ? _self.highlightColor
          : highlightColor // ignore: cast_nullable_to_non_nullable
              as Color,
      arrowSize: null == arrowSize
          ? _self.arrowSize
          : arrowSize // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// Adds pattern-matching-related methods to [GraphDefaultLinkRendererStyle].
extension GraphDefaultLinkRendererStylePatterns
    on GraphDefaultLinkRendererStyle {
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
    TResult Function(_GraphDefaultLinkRendererStyle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle() when $default != null:
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
    TResult Function(_GraphDefaultLinkRendererStyle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle():
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
    TResult? Function(_GraphDefaultLinkRendererStyle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle() when $default != null:
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
            Color arrowColor,
            Color borderColor,
            Color labelColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedUnhoverColor,
            Color highlightColor,
            Size arrowSize)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle() when $default != null:
        return $default(
            _that.arrowColor,
            _that.borderColor,
            _that.labelColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedUnhoverColor,
            _that.highlightColor,
            _that.arrowSize);
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
            Color arrowColor,
            Color borderColor,
            Color labelColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedUnhoverColor,
            Color highlightColor,
            Size arrowSize)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle():
        return $default(
            _that.arrowColor,
            _that.borderColor,
            _that.labelColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedUnhoverColor,
            _that.highlightColor,
            _that.arrowSize);
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
            Color arrowColor,
            Color borderColor,
            Color labelColor,
            Color hoverColor,
            Color selectedHoverColor,
            Color selectedUnhoverColor,
            Color highlightColor,
            Size arrowSize)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GraphDefaultLinkRendererStyle() when $default != null:
        return $default(
            _that.arrowColor,
            _that.borderColor,
            _that.labelColor,
            _that.hoverColor,
            _that.selectedHoverColor,
            _that.selectedUnhoverColor,
            _that.highlightColor,
            _that.arrowSize);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GraphDefaultLinkRendererStyle implements GraphDefaultLinkRendererStyle {
  const _GraphDefaultLinkRendererStyle(
      {this.arrowColor = Colors.black,
      this.borderColor = Colors.black,
      this.labelColor = Colors.black,
      this.hoverColor = Colors.red,
      this.selectedHoverColor = Colors.green,
      this.selectedUnhoverColor = Colors.blue,
      this.highlightColor = Colors.yellow,
      this.arrowSize = const Size(1, 1)});

  /// The color of the arrow at the end of the link.
  @override
  @JsonKey()
  final Color arrowColor;

  /// The color of the link line.
  @override
  @JsonKey()
  final Color borderColor;

  /// The color of the link's label text.
  @override
  @JsonKey()
  final Color labelColor;

  /// The color of the link when hovered.
  @override
  @JsonKey()
  final Color hoverColor;

  /// The color when the link is both selected and hovered.
  @override
  @JsonKey()
  final Color selectedHoverColor;

  /// The color when the selection ends.
  @override
  @JsonKey()
  final Color selectedUnhoverColor;

  /// The color for emphasized links.
  @override
  @JsonKey()
  final Color highlightColor;

  /// The size of the arrow at the end of the link.
  ///
  /// Width and height can be set independently.
  @override
  @JsonKey()
  final Size arrowSize;

  /// Create a copy of GraphDefaultLinkRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GraphDefaultLinkRendererStyleCopyWith<_GraphDefaultLinkRendererStyle>
      get copyWith => __$GraphDefaultLinkRendererStyleCopyWithImpl<
          _GraphDefaultLinkRendererStyle>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GraphDefaultLinkRendererStyle &&
            (identical(other.arrowColor, arrowColor) ||
                other.arrowColor == arrowColor) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.labelColor, labelColor) ||
                other.labelColor == labelColor) &&
            (identical(other.hoverColor, hoverColor) ||
                other.hoverColor == hoverColor) &&
            (identical(other.selectedHoverColor, selectedHoverColor) ||
                other.selectedHoverColor == selectedHoverColor) &&
            (identical(other.selectedUnhoverColor, selectedUnhoverColor) ||
                other.selectedUnhoverColor == selectedUnhoverColor) &&
            (identical(other.highlightColor, highlightColor) ||
                other.highlightColor == highlightColor) &&
            (identical(other.arrowSize, arrowSize) ||
                other.arrowSize == arrowSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      arrowColor,
      borderColor,
      labelColor,
      hoverColor,
      selectedHoverColor,
      selectedUnhoverColor,
      highlightColor,
      arrowSize);

  @override
  String toString() {
    return 'GraphDefaultLinkRendererStyle(arrowColor: $arrowColor, borderColor: $borderColor, labelColor: $labelColor, hoverColor: $hoverColor, selectedHoverColor: $selectedHoverColor, selectedUnhoverColor: $selectedUnhoverColor, highlightColor: $highlightColor, arrowSize: $arrowSize)';
  }
}

/// @nodoc
abstract mixin class _$GraphDefaultLinkRendererStyleCopyWith<$Res>
    implements $GraphDefaultLinkRendererStyleCopyWith<$Res> {
  factory _$GraphDefaultLinkRendererStyleCopyWith(
          _GraphDefaultLinkRendererStyle value,
          $Res Function(_GraphDefaultLinkRendererStyle) _then) =
      __$GraphDefaultLinkRendererStyleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Color arrowColor,
      Color borderColor,
      Color labelColor,
      Color hoverColor,
      Color selectedHoverColor,
      Color selectedUnhoverColor,
      Color highlightColor,
      Size arrowSize});
}

/// @nodoc
class __$GraphDefaultLinkRendererStyleCopyWithImpl<$Res>
    implements _$GraphDefaultLinkRendererStyleCopyWith<$Res> {
  __$GraphDefaultLinkRendererStyleCopyWithImpl(this._self, this._then);

  final _GraphDefaultLinkRendererStyle _self;
  final $Res Function(_GraphDefaultLinkRendererStyle) _then;

  /// Create a copy of GraphDefaultLinkRendererStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? arrowColor = null,
    Object? borderColor = null,
    Object? labelColor = null,
    Object? hoverColor = null,
    Object? selectedHoverColor = null,
    Object? selectedUnhoverColor = null,
    Object? highlightColor = null,
    Object? arrowSize = null,
  }) {
    return _then(_GraphDefaultLinkRendererStyle(
      arrowColor: null == arrowColor
          ? _self.arrowColor
          : arrowColor // ignore: cast_nullable_to_non_nullable
              as Color,
      borderColor: null == borderColor
          ? _self.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as Color,
      labelColor: null == labelColor
          ? _self.labelColor
          : labelColor // ignore: cast_nullable_to_non_nullable
              as Color,
      hoverColor: null == hoverColor
          ? _self.hoverColor
          : hoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedHoverColor: null == selectedHoverColor
          ? _self.selectedHoverColor
          : selectedHoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      selectedUnhoverColor: null == selectedUnhoverColor
          ? _self.selectedUnhoverColor
          : selectedUnhoverColor // ignore: cast_nullable_to_non_nullable
              as Color,
      highlightColor: null == highlightColor
          ? _self.highlightColor
          : highlightColor // ignore: cast_nullable_to_non_nullable
              as Color,
      arrowSize: null == arrowSize
          ? _self.arrowSize
          : arrowSize // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

// dart format on
