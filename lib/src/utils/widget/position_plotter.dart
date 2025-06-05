import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph_view/widget/graph.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget.dart';

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: cascade_invocations

@internal
class GraphPositionPlotter extends StatefulWidget {
  GraphPositionPlotter({
    required this.child,
    super.key,
    Color? borderColor,
    Color? textColor,
    double? fontSize,
    this.updateInterval = const Duration(milliseconds: 100),
  }) {
    this.borderColor = borderColor ?? Colors.red;
    this.textColor = textColor ?? Colors.red;
    this.fontSize = fontSize ?? 14;
  }

  static bool enabled = false;

  static W wrapOr<W extends Widget>({
    required W child,
    Key? key,
    Color? borderColor,
    Color? textColor,
    double? fontSize,
  }) {
    return enabled
        ? GraphPositionPlotter(
            key: key,
            borderColor: borderColor,
            textColor: textColor,
            fontSize: fontSize,
            child: child,
          ) as W
        : child;
  }

  final Widget child;
  late final Color borderColor;
  late final Color textColor;
  late final double fontSize;
  final Duration updateInterval;

  @override
  State createState() => _GraphPositionPlotterState();
}

class _GraphPositionPlotterState extends State<GraphPositionPlotter> {
  final GlobalKey _childKey = GlobalKey();
  Rect _geometry = Rect.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.updateInterval, (_) {
      _updateGeometry();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateGeometry() {
    logDebug(LogCategory.rendering, 'GraphPositionPlotter: update geometry');
    WidgetUtils.withSizedRenderBoxIfPresent(_childKey, (childRenderBox) {
      final parentContext = _childKey.currentContext
          ?.findAncestorStateOfType<GraphViewState>()
          ?.context;
      if (parentContext == null || !parentContext.mounted) {
        return;
      }

      final parentRenderBox = parentContext.findRenderObject() as RenderBox?;
      if (parentRenderBox == null || !parentRenderBox.hasSize) {
        return;
      }
      final childPosition = childRenderBox.localToGlobal(Offset.zero);
      final parentPosition = parentRenderBox.localToGlobal(Offset.zero);
      final localPosition = childPosition - parentPosition;
      final size = childRenderBox.size;
      setState(() {
        _geometry = Rect.fromLTWH(
          localPosition.dx,
          localPosition.dy,
          size.width,
          size.height,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KeyedSubtree(key: _childKey, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PositionPlotterPainter(
                borderColor: widget.borderColor,
                textColor: widget.textColor,
                position: _geometry.topLeft,
                size: _geometry.size,
                fontSize: widget.fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PositionPlotterPainter extends CustomPainter {
  _PositionPlotterPainter({
    required this.borderColor,
    required this.textColor,
    required this.position,
    required this.size,
    required this.fontSize,
  });

  final Color borderColor;
  final Color textColor;
  final Offset position;
  final Size size;
  final double fontSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw bounding box
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw top-left marker
    canvas.drawCircle(Offset.zero, 4, paint..style = PaintingStyle.fill);

    // Draw center marker
    final center = Offset(size.width / 2, size.height / 2);
    paint.color = Colors.blue;
    canvas.drawCircle(center, 4, paint);

    // Draw coordinate labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text:
            '(${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)})',
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    )..layout();
    textPainter.paint(canvas, const Offset(-5, -24));

    textPainter.text = TextSpan(
      text:
          '(${(position.dx + center.dx).toStringAsFixed(1)}, ${(position.dy + center.dy).toStringAsFixed(1)})',
      style: TextStyle(color: Colors.blue, fontSize: fontSize),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width + 4, center.dy - 8));

    textPainter.text = TextSpan(
      text:
          'w${size.width.toStringAsFixed(0)} x h${size.height.toStringAsFixed(0)}',
      style: TextStyle(color: textColor, fontSize: fontSize),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height + 5));
  }

  @override
  bool shouldRepaint(covariant _PositionPlotterPainter oldDelegate) {
    return position != oldDelegate.position || size != oldDelegate.size;
  }
}
