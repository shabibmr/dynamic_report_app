import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import '../models/report_config.dart';

class ReportRepository {
  final String baseUrl;
  final http.Client _client;

  ReportRepository({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Report>> getReports() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/list'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reports = (data['reports'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
        return reports;
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }

  Future<Map<String, dynamic>> executeReport(
    ReportConfig report,
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'report_id': report.id, 'filters': filters}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to execute report');
      }
    } catch (e) {
      throw Exception('Failed to execute report: $e');
    }
  }
}
