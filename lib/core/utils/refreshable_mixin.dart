import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin RefreshableMixin {
  Future<void> onRefresh();

  Map<ShortcutActivator, VoidCallback> get refreshShortcuts => {
    const SingleActivator(LogicalKeyboardKey.keyR, control: true): () async {
      await onRefresh();
    },
  };
}
