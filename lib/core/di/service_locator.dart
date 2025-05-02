import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../data/datasources/entity_search_datasource.dart';
import '../network/api_client.dart';
import '../repositories/entity_search_repository.dart';
import '../repositories/mock_report_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/report_repository_impl.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();

  ServiceLocator._();

  late final ApiClient _apiClient;
  late final ReportRepository _reportRepository;
  late final EntitySearchRepository _entitySearchRepository;

  // Set this to false to use the real API implementation
  static const bool useMockRepository = false;

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

      // Initialize repositories
      _reportRepository = ReportRepositoryImpl(apiClient: _apiClient);

      // Initialize entity search repository
      final entitySearchDataSource = RemoteEntitySearchDataSource(
        baseUrl: AppConfig.instance.apiBaseUrl,
      );
      _entitySearchRepository =
          EntitySearchRepositoryImpl(entitySearchDataSource);
    }
  }

  ReportRepository get reportRepository => _reportRepository;
  EntitySearchRepository get entitySearchRepository => _entitySearchRepository;

  void dispose() {
    if (!useMockRepository) {
      _apiClient.dispose();
    }
  }
}
