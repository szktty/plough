import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/utils/widget.dart';

@internal
class GraphTooltipContainer extends StatefulWidget {
  const GraphTooltipContainer({
    required this.entity,
    required this.child,
    this.behavior,
    super.key,
  });

  final GraphTooltipBehavior? behavior;
  final GraphEntity entity;
  final Widget child;

  @override
  State<GraphTooltipContainer> createState() => _GraphTooltipContainerState();
}

class _GraphTooltipContainerState extends State<GraphTooltipContainer> {
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _tooltipKey = GlobalKey();
  Size? _widgetSize;
  Size? _tooltipSize;
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _overlayPortalController.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChildSize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateChildSize() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      setState(() {
        _widgetSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _build(context, widget.entity);
  }

  Widget _build(BuildContext context, GraphEntity entity) {
    final behavior = widget.behavior!;
    final tooltip = behavior.builder(context, entity);
    if (_tooltipSize == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetUtils.withSizedRenderBoxIfPresent(_tooltipKey, (renderBox) {
          _overlayPortalController.show();
          _tooltipSize = renderBox.size;
          setState(() {});
        });
      });
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        KeyedSubtree(key: _childKey, child: widget.child),
        if (_widgetSize != null)
          CompositedTransformTarget(
            link: _layerLink,
            child: OverlayPortal.targetsRootOverlay(
              controller: _overlayPortalController,
              overlayChildBuilder: (context) => CompositedTransformFollower(
                link: _layerLink,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _getLeftPosition(behavior.position) ??
                          double.infinity,
                      top:
                          _getTopPosition(behavior.position) ?? double.infinity,
                      child: KeyedSubtree(key: _tooltipKey, child: tooltip),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  double? _getLeftPosition(GraphTooltipPosition position) {
    if (_tooltipSize == null) {
      return null;
    } else {
      switch (position) {
        case GraphTooltipPosition.left:
          return -_tooltipSize!.width;
        case GraphTooltipPosition.right:
          return _widgetSize!.width;
        case GraphTooltipPosition.top:
        case GraphTooltipPosition.bottom:
          return (_widgetSize!.width - _tooltipSize!.width) / 2;
      }
    }
    return null;
  }

  double? _getTopPosition(GraphTooltipPosition position) {
    if (_tooltipSize == null) {
      return null;
    } else {
      switch (position) {
        case GraphTooltipPosition.top:
          return -_tooltipSize!.height;
        case GraphTooltipPosition.bottom:
          return _widgetSize!.height;
        case GraphTooltipPosition.left:
        case GraphTooltipPosition.right:
          if (_widgetSize!.height >= _tooltipSize!.height) {
            return (_widgetSize!.height - _tooltipSize!.height) / 2;
          } else {
            return (_tooltipSize!.height - _widgetSize!.height) / 2;
          }
      }
    }
    return null;
  }
}
