import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@internal
abstract class WidgetUtils {
  static void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el
        ..markNeedsBuild()
        ..visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  static RenderBox? getSizedRenderBox(Key? key) {
    final context = (key as GlobalKey?)?.currentContext;
    if (context == null || !context.mounted) {
      return null;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox;
    } else {
      return null;
    }
  }

  static bool withSizedRenderBoxIfPresent(
    Key? key,
    void Function(RenderBox) callback,
  ) {
    final renderBox = getSizedRenderBox(key);
    if (renderBox != null && renderBox.attached) {
      callback(renderBox);
      return true;
    } else {
      return false;
    }
  }
}
