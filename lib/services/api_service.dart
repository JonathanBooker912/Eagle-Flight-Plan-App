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
}
