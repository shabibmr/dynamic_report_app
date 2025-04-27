import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class KeyboardShortcuts {
  static final Map<ShortcutActivator, void Function(BuildContext)>
  _shortcuts = {
    // Refresh - F5 or Ctrl+R
    LogicalKeySet(LogicalKeyboardKey.f5): (context) => _handleRefresh(context),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
        (context) => _handleRefresh(context),

    // Export - Ctrl+E
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
        (context) => _handleExport(context),

    // Search - Ctrl+F
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
        (context) => _handleSearch(context),

    // Back - Alt+Left or Escape
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft):
        (context) => _handleBack(context),
    LogicalKeySet(LogicalKeyboardKey.escape): (context) => _handleBack(context),

    // Help - F1
    LogicalKeySet(LogicalKeyboardKey.f1): (context) => _handleHelp(context),
  };

  static Map<ShortcutActivator, Action<Intent>> get actions {
    return _shortcuts.map((key, handler) {
      return MapEntry(
        key,
        CallbackAction(
          onInvoke: (intent) => handler(navigatorKey.currentContext!),
        ),
      );
    });
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void _handleRefresh(BuildContext context) {
    final refreshable =
        context.findAncestorWidgetOfExactType<RefreshableWidget>();
    refreshable?.onRefresh?.call();
  }

  static void _handleExport(BuildContext context) {
    final exportable =
        context.findAncestorWidgetOfExactType<ExportableWidget>();
    exportable?.onExport?.call();
  }

  static void _handleSearch(BuildContext context) {
    final searchable =
        context.findAncestorWidgetOfExactType<SearchableWidget>();
    searchable?.onSearch?.call();
  }

  static void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void _handleHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keyboard Shortcuts'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('F5 or Ctrl+R: Refresh'),
                Text('Ctrl+E: Export'),
                Text('Ctrl+F: Search'),
                Text('Alt+Left or Esc: Go back'),
                Text('F1: Show this help'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

// Mixin for widgets that can be refreshed
mixin RefreshableWidget on Widget {
  VoidCallback? get onRefresh;
}

// Mixin for widgets that can export data
mixin ExportableWidget on Widget {
  VoidCallback? get onExport;
}

// Mixin for widgets that can be searched
mixin SearchableWidget on Widget {
  VoidCallback? get onSearch;
}
