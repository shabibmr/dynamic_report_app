import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'An unknown error occurred';
  }

  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    // TODO: Implement proper error logging
    print('Error: $message');
    print('Details: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
}
