import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin KeyboardShortcutsMixin<T extends StatefulWidget> on State<T> {
  Map<ShortcutActivator, VoidCallback> get shortcuts;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        for (var entry in shortcuts.entries)
          entry.key: CallbackIntent(entry.value),
      },
      child: Actions(
        actions: {
          CallbackIntent: CallbackAction<CallbackIntent>(
            onInvoke: (intent) => intent.callback(),
          ),
        },
        child: buildWithShortcuts(context),
      ),
    );
  }

  Widget buildWithShortcuts(BuildContext context);
}

class CallbackIntent extends Intent {
  final VoidCallback callback;
  const CallbackIntent(this.callback);
}
