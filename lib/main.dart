/// Entry point for the Dynamic Reports application.
/// This file serves as the main entry point that launches the application
/// by running the [App] widget.
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';

/// The main entry point of the application.
/// Initializes and runs the [App] widget which sets up the application infrastructure.
void main() async {
  // Initialize service locator for dependency injection
  ServiceLocator.init(); // Uncommenting the service locator initialization
  runApp(const App());
}
