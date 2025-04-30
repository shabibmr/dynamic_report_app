import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../models/report.dart';
import '../models/report_config.dart';

class ReportRepository {
  final String baseUrl;
  final http.Client _client;

  ReportRepository({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<List<ReportConfig>> getReports() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/list'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int i = 1;
        print('Data : ${data.runtimeType}');
        final reports = (data['reports'] as List).map((json) {
          print('${i++}');
          return ReportConfig.fromJson(json);
        }).toList();
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
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'report_id': report.id, 'filters': report.filters}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed Response: ${response.body}');
        throw Exception('Failed to execute report');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to execute report: $e');
    }
  }
}
