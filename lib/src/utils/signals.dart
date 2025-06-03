import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@internal
mixin ListenableValueNotifierStateMixin<T> implements Listenable {
  ValueNotifier<T> get state;

  bool useOverrideState = false;

  void setState(T value, {bool force = false}) {
    if (useOverrideState) {
      overrideState(value);
    } else {
      // Try immediate update first, defer if it fails due to build cycle
      try {
        state.value = value;
      } catch (e) {
        // If immediate update fails due to setState during build,
        // defer to next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.value = value;
        });
      }
    }
  }

  void overrideState(T value) {
    // Defer state updates to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final oldValue = state.value;
      state.value = value;
      // Restore after next frame if needed
      if (!useOverrideState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.value == value) {
            state.value = oldValue;
          }
        });
      }
    });
  }

  void overrideStateWith(void Function() callback) {
    useOverrideState = true;
    callback();
    useOverrideState = false;
  }

  @override
  void addListener(VoidCallback listener) {
    state.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    state.removeListener(listener);
  }

  void disposeState() {
    state.dispose();
  }
}
