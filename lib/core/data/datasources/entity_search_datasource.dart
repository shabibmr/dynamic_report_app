import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class EntitySearchDataSource {
  /// Search entities based on query string
  ///
  /// Returns a List of entities matching the search query
  /// Throws Exception if the search fails
  Future<List<Map<String, dynamic>>> searchEntities(String query);
}

class RemoteEntitySearchDataSource implements EntitySearchDataSource {
  final http.Client _client;
  final String baseUrl;

  RemoteEntitySearchDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<Map<String, dynamic>>> searchEntities(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search entities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search entities: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
