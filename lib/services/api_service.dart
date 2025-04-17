import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_token_service.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService({required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    print('Current auth token: $token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Access-Control-Allow-Origin': '*',
      'crossDomain': 'true',
    };
    
    // Match Vue frontend's auth header handling exactly
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('Added Authorization header with token');
    } else {
      print('No valid token found, skipping Authorization header');
    }
    
    print('Final request headers: $headers');
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );
    print('Making GET request to: $url');
    final headers = await _getHeaders();
    
    final response = await _client.get(
      url,
      headers: headers,
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 401) {
      // Handle unauthorized response
      print('Unauthorized response - clearing token');
      await TokenService.clearToken();
      throw Exception('Unauthorized - Please login again');
    }
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$endpoint';
    print('Making POST request to: $url');
    final headers = await _getHeaders();
    print('Headers: $headers');
    print('Body: ${jsonEncode(body)}');
    
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 401) {
      // Handle unauthorized response
      print('Unauthorized response - clearing token');
      await TokenService.clearToken();
      throw Exception('Unauthorized - Please login again');
    }
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$endpoint';
    print('Making PUT request to: $url');
    final headers = await _getHeaders();
    print('Headers: $headers');
    print('Body: ${jsonEncode(body)}');
    
    final response = await _client.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 401) {
      // Handle unauthorized response
      print('Unauthorized response - clearing token');
      await TokenService.clearToken();
      throw Exception('Unauthorized - Please login again');
    }
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('Making DELETE request to: $url');
    final headers = await _getHeaders();
    print('Headers: $headers');
    
    final response = await _client.delete(
      Uri.parse(url),
      headers: headers,
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 401) {
      // Handle unauthorized response
      print('Unauthorized response - clearing token');
      await TokenService.clearToken();
      throw Exception('Unauthorized - Please login again');
    }
    
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
