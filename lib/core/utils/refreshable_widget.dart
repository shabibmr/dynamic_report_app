import 'package:flutter/material.dart';
import 'refresh_controller.dart';

mixin RefreshableWidget on Widget {
  void Function()? get onRefresh;

  void triggerRefresh() {
    if (onRefresh != null) {
      onRefresh!();
    }
  }

  static void refreshAll() {
    RefreshController().refresh();
  }
}
