import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@internal
mixin ListenableValueNotifierStateMixin<T> implements Listenable {
  ValueNotifier<T> get state;

  void setState(T value, {bool force = false}) {
    state.value = value;
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
