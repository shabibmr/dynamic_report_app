import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class HttpInterceptor extends http.BaseClient {
  final http.Client _client;
  final Duration timeout;

  HttpInterceptor({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      timeout = timeout ?? AppConfig.instance.apiTimeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Add common headers
      request.headers['Content-Type'] = 'application/json';

      // TODO: Add authentication token when implemented
      // request.headers['Authorization'] = 'Bearer $token';

      // Send request with timeout
      final response = await _client.send(request).timeout(timeout);

      // Handle common status codes
      switch (response.statusCode) {
        case HttpStatus.unauthorized:
          throw Exception('Unauthorized. Please log in again.');
        case HttpStatus.forbidden:
          throw Exception(
            'You do not have permission to access this resource.',
          );
        case HttpStatus.notFound:
          throw Exception('The requested resource was not found.');
        case HttpStatus.internalServerError:
          throw Exception(
            'An internal server error occurred. Please try again later.',
          );
        default:
          if (response.statusCode >= 400) {
            throw Exception(
              'Request failed with status: ${response.statusCode}',
            );
          }
      }

      return response;
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
