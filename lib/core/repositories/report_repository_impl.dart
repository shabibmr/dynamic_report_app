import '../models/report.dart';
import '../models/report_config.dart';
import '../network/api_client.dart';
import 'report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient _apiClient;

  const ReportRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<Report>> getReports() async {
    try {
      final response = await _apiClient.getReportsList();
      return response.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> executeReport(
    ReportConfig report,
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _apiClient.executeReport(report.id, filters);
      return {'data': response};
    } catch (e) {
      throw Exception('Failed to execute report: $e');
    }
  }

  @override
  // TODO: implement baseUrl
  String get baseUrl => throw UnimplementedError();
}
