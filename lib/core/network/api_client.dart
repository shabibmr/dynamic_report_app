import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_interceptor.dart';

class ApiClient {
  final String baseUrl;
  final HttpInterceptor _httpClient;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _httpClient = HttpInterceptor(client: httpClient);

  Future<List<Map<String, dynamic>>> getReportsList() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/list'),
      );
      List<Map<String, dynamic>> reports = _handleResponse(response);
      // print('Reports count: ${reports.length}');
      return reports;
    } catch (e) {
      print('Error fetching reports: $e');
      print('Base URL: $baseUrl/list');
      throw Exception('Failed to fetch reports list: $e');
    }
  }

  Future<Map<String, dynamic>> executeReport(
    int reportId,
    Map<String, dynamic>? filters,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_id': reportId,
          'filters': filters ?? {},
        }),
      );
      return _handleResponseData(response);
    } catch (e) {
      print('Error executing report: $e');
      print('Base URL: $baseUrl/execute');
      print('Report ID: $reportId');
      print('Filters: $filters');
      throw Exception('Failed to execute report: $e');
    }
  }

  List<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // print('Response data: $data');
      if (data.containsKey('reports') && data['reports'] is List) {
        final List<dynamic> listData = data['reports'];
        return listData.cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Map<String, dynamic> _handleResponseData(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // print('Response data: $data');
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        print(data);
        return data;
      }
      throw Exception('Invalid response format');
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  void dispose() {
    _httpClient.dispose();
  }
}
