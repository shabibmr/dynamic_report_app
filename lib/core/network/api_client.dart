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
        Uri.parse('$baseUrl/reports/list'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch reports list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> executeReport(
    int reportId,
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/reports/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'report_id': reportId, 'filters': filters}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to execute report: $e');
    }
  }

  List<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> listData = data['data'];
        return listData.cast<Map<String, dynamic>>();
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
