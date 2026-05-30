import 'package:example/widget/graph_area.dart';
import 'package:example/widget/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const _minScale = 0.25;
  static const _maxScale = 4.0;

  final _viewportController = GraphViewportController(
    minScale: _minScale,
    maxScale: _maxScale,
  );

  // The latest viewport size, used to zoom around its center.
  final _graphAreaKey = GlobalKey();

  @override
  void dispose() {
    _viewportController.dispose();
    super.dispose();
  }

  /// Zooms by [factor] (>1 zoom in, <1 zoom out) around the viewport center.
  void _zoomBy(double factor) {
    final box = _graphAreaKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size;
    final focalPoint = size == null
        ? Offset.zero
        : Offset(size.width / 2, size.height / 2);
    _viewportController.zoomAt(factor, focalPoint: focalPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MainPageToolbar(
          viewportController: _viewportController,
          onZoomIn: () => _zoomBy(1.25),
          onZoomOut: () => _zoomBy(0.8),
        ),
        Expanded(
          child: GraphArea(
            key: _graphAreaKey,
            viewportController: _viewportController,
            minScale: _minScale,
            maxScale: _maxScale,
          ),
        ),
      ],
    );
  }
}
