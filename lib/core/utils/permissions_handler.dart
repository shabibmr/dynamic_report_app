import 'dart:io';
import 'package:flutter/foundation.dart';

class PermissionsHandler {
  static Future<bool> checkStoragePermission() async {
    if (kIsWeb) {
      return true;
    }

    // On desktop platforms, we don't need explicit permissions
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }

    // For mobile platforms, we would typically check permissions here
    // TODO: Add mobile platform permission checks when needed
    // For now, return true as we're using share_plus which handles its own permissions
    return true;
  }

  static String getStorageErrorMessage() {
    if (Platform.isAndroid) {
      return 'Storage permission is required to export reports. Please grant the permission in app settings.';
    } else if (Platform.isIOS) {
      return 'Storage access is required to export reports. Please grant the permission in app settings.';
    }
    return 'Unable to access storage. Please check your system settings.';
  }
}
