import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin ListenableSignalStateMixin<T> implements Listenable {
  Signal<T> get state;

  ValueNotifier<T> get notifier => state as ValueNotifier<T>;

  bool useOverrideState = false;

  void setState(T value, {bool force = false}) {
    if (useOverrideState) {
      overrideState(value);
    } else {
      state.set(value, force: force);
    }
  }

  void overrideState(T value) {
    state.overrideWith(value);
  }

  void overrideStateWith(void Function() callback) {
    useOverrideState = true;
    callback();
    useOverrideState = false;
  }

  @override
  void addListener(VoidCallback listener) {
    notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    notifier.removeListener(listener);
  }

  void disposeState() {
    state.dispose();
  }
}
