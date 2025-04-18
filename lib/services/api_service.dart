import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_token_service.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService({required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    return _handleResponse(
      await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _handleResponse(
      await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _handleResponse(
      await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _handleResponse(
      await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      ),
    );
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded;
    } else {
      throw Exception(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  void dispose() {
    _client.close();
  }

  Future<dynamic> getStudentForUserId(String userId) async {
    final endpoint = '/students/user/$userId';
    print('ApiService: Fetching student for user ID: $userId');
    try {
      final response = await get(endpoint);
      print('ApiService: Student response: $response');
      return response;
    } catch (e) {
      print('ApiService: Error fetching student: $e');
      rethrow;
    }
  }

  Future<dynamic> getStrengthsForStudent(String studentId) async {
    final endpoint = '/strengths/student/$studentId';
    print('ApiService: Fetching strengths for student ID: $studentId');
    try {
      final response = await get(endpoint);
      print('ApiService: Strengths response: $response');
      return response;
    } catch (e) {
      print('ApiService: Error fetching strengths: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAllLinksForUser(String userId) async {
    final endpoint = '/link/user/$userId';
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final endpoint = '/user/$userId';
    final response = await get(endpoint);
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getBadgesForStudent(String studentId, int page, int pageSize) async {
    final endpoint = '/badge/student/$studentId?page=$page&pageSize=$pageSize';
    final response = await get(endpoint);
    return Map<String, dynamic>.from(response);
  }
}
