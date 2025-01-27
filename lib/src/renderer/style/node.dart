import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/renderer/widget/node.dart';

part 'node.freezed.dart';

/// Controls node appearance with color and dimension options that automatically update
/// based on interaction states.
///
/// See also:
///
/// * [GraphDefaultNodeRenderer], which uses this style configuration
/// * [GraphDefaultNodeRendererShape], which defines available node shapes
@freezed
class GraphDefaultNodeRendererStyle with _$GraphDefaultNodeRendererStyle {
  /// Creates a style configuration with default values for all properties.
  const factory GraphDefaultNodeRendererStyle({
    /// The background color of the node.
    @Default(Color(0xFFE2E8F0)) Color color,

    /// The color of the node's border.
    @Default(Color(0xFF64748B)) Color borderColor,

    /// The color of the node's label text.
    @Default(Color(0xFF1E293B)) Color labelColor,

    /// The color of the node's ID text.
    @Default(Colors.grey) Color idColor,

    /// The background color when the node is hovered.
    @Default(Colors.red) Color hoverColor,

    /// The background color when the node is both selected and hovered.
    @Default(Colors.green) Color selectedHoverColor,

    /// The border color when the node is selected.
    @Default(Color(0xFF4A5568))
    Color selectedBorderColor, // Complementary color
    /// The background color for emphasized nodes.
    @Default(Colors.yellow) Color highlightColor,

    /// The radius of circular nodes.
    ///
    /// If null, the radius is automatically calculated based on the content.
    double? radius,

    /// The fixed width of the node.
    ///
    /// If null, the width is automatically calculated based on the content.
    double? width,

    /// The fixed height of the node.
    ///
    /// If null, the height is automatically calculated based on the content.
    double? height,

    /// The minimum width constraint for the node.
    @Default(50) double minWidth,

    /// The minimum height constraint for the node.
    @Default(50) double minHeight,

    /// The width of the node's border in normal state.
    @Default(2) double borderWidth,

    /// The width of the node's border when hovered.
    @Default(2) double hoverBorderWidth,

    /// The width of the node's border when selected.
    @Default(2) double selectedBorderWidth,

    /// The width of the node's border when both selected and hovered.
    @Default(2) double selectedHoverBorderWidth,

    /// The width of the node's border when selection ends.
    @Default(2) double selectedUnhoverBorderWidth,

    /// The shape of the node. Can be either circle or rectangle.
    @Default(GraphDefaultNodeRendererShape.circle)
    GraphDefaultNodeRendererShape shape,
  }) = _GraphDefaultNodeRendererStyle;
}

/// Shape options available for nodes in the default renderer.
///
/// The shape affects both the node's visual appearance and its hit testing behavior.
enum GraphDefaultNodeRendererShape {
  circle,
  rectangle,
}
