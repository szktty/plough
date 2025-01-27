import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/renderer/widget/link.dart';

part 'link.freezed.dart';

/// Controls link appearance with colors and dimensions that automatically update with
/// state changes. Customizable properties include arrow styles and line thickness.
///
/// See also:
///
/// * [GraphDefaultLinkRenderer], which uses this style configuration
@freezed
class GraphDefaultLinkRendererStyle with _$GraphDefaultLinkRendererStyle {
  /// Creates a style configuration with default values for all properties.
  const factory GraphDefaultLinkRendererStyle({
    /// The color of the arrow at the end of the link.
    @Default(Colors.black) Color arrowColor,

    /// The color of the link line.
    @Default(Colors.black) Color borderColor,

    /// The color of the link's label text.
    @Default(Colors.black) Color labelColor,

    /// The color of the link when hovered.
    @Default(Colors.red) Color hoverColor,

    /// The color when the link is both selected and hovered.
    @Default(Colors.green) Color selectedHoverColor,

    /// The color when the selection ends.
    @Default(Colors.blue) Color selectedUnhoverColor,

    /// The color for emphasized links.
    @Default(Colors.yellow) Color highlightColor,

    /// The size of the arrow at the end of the link.
    ///
    /// Width and height can be set independently.
    @Default(Size(1, 1)) Size arrowSize,
  }) = _GraphDefaultLinkRendererStyle;
}
