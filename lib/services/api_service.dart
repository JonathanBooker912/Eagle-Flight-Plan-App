import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_session_storage.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

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
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    
    return _handleResponse(
      await _client.get(
        Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
        headers: await _getHeaders(),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    
    return _handleResponse(
      await _client.post(
        Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    
    return _handleResponse(
      await _client.put(
        Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    
    return _handleResponse(
      await _client.delete(
        Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
        headers: await _getHeaders(),
      ),
    );
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return {"data": data};
      return data;
    } else {
      throw Exception(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    return await get('/user/${userId}');
  }

  Future<Map<String, dynamic>> getAllLinksForUser(String userId) async {
    final response = await get('/user/${userId}/links');
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getStudentForUserId(String userId) async {
    return await get('/students/user/${userId}');
  }

  Future<Map<String, dynamic>> getStrengthsForStudent(String studentId) async {
    final response = await get('/strengths/student/$studentId');
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getBadgesForStudent(String studentId, int page, int pageSize) async {
    final response = await get('/badges/student/$studentId?page=$page&pageSize=$pageSize');
    return Map<String, dynamic>.from(response);
  }
}
