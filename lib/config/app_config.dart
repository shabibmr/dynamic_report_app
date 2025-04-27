class AppConfig {
  static final AppConfig instance = AppConfig._();

  AppConfig._();

  // API Configuration
  final String apiBaseUrl =
      'http://localhost:8080/api'; // Replace with your actual API endpoint

  // Report Configuration
  final int defaultPageSize = 20;
  final Duration apiTimeout = const Duration(seconds: 30);

  // Theme Configuration
  final bool useDarkMode = false;
}
