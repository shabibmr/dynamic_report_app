import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../network/api_client.dart';
import '../repositories/mock_report_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/report_repository_impl.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();

  ServiceLocator._();

  late final ApiClient _apiClient;
  late final ReportRepository _reportRepository;

  // Set this to false to use the real API implementation
  static const bool useMockRepository = true;

  static Future<void> init() async {
    instance.initialize();
  }

  void initialize() {
    if (useMockRepository) {
      _reportRepository = MockReportRepository();
    } else {
      // Initialize API client with configured base URL
      final httpClient = http.Client();
      _apiClient = ApiClient(
        baseUrl: AppConfig.instance.apiBaseUrl,
        httpClient: httpClient,
      );

      // Initialize repository
      _reportRepository = ReportRepositoryImpl(apiClient: _apiClient);
    }
  }

  ReportRepository get reportRepository => _reportRepository;

  void dispose() {
    if (!useMockRepository) {
      _apiClient.dispose();
    }
  }
}
