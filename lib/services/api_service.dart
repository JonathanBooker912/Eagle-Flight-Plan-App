import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_session_storage.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();
  static const int _maxRetries = 2; // Maximum number of retries for 401 errors

  ApiService({required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final token = (await ApiSessionStorage.getSession()).token;
    final headers = {'Content-Type': 'application/json'};

    if (token != "") {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    return _handleResponse(
      await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      ),
      originalBody: null,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final bodyString = jsonEncode(body);
    return _handleResponse(
      await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: bodyString,
      ),
      originalBody: bodyString,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final bodyString = jsonEncode(body);
    return _handleResponse(
      await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: bodyString,
      ),
      originalBody: bodyString,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final bodyString = body != null ? jsonEncode(body) : null;
    return _handleResponse(
      await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: bodyString,
      ),
      originalBody: bodyString,
    );
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {
    int retryCount = 0,
    String? originalBody,
  }) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return {"data": data};
      return data;
    } else if (response.statusCode == 401 && retryCount < _maxRetries) {
      return await _handleUnauthorized(
        response,
        retryCount: retryCount,
        originalBody: originalBody,
      );
    } else {
      throw Exception(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> _handleUnauthorized(
    http.Response response, {
    required int retryCount,
    String? originalBody,
  }) async {
    await ApiSessionStorage.refreshSession();

    // Create a new request based on the original request's properties
    final originalRequest = response.request!;
    final headers = await _getHeaders();
    final uri = originalRequest.url;
    final method = originalRequest.method;

    http.Response retryResponse;
    switch (method) {
      case 'GET':
        retryResponse = await _client.get(uri, headers: headers);
        break;
      case 'POST':
        retryResponse = await _client.post(
          uri,
          headers: headers,
          body: originalBody ?? '',
        );
        break;
      case 'PUT':
        retryResponse = await _client.put(
          uri,
          headers: headers,
          body: originalBody ?? '',
        );
        break;
      case 'DELETE':
        retryResponse = await _client.delete(
          uri,
          headers: headers,
          body: originalBody,
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return _handleResponse(
      retryResponse,
      retryCount: retryCount + 1,
      originalBody: originalBody,
    );
  }

  void dispose() {
    _client.close();
  }
}
