import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class Auth {
  final ApiService _apiService;
  final String _baseUrl;

  Auth(this._apiService, this._baseUrl);

  Future<Map<String, dynamic>> loginWithGoogle(String idToken, {String? accessToken}) async {
    try {
      print('Attempting Google login with token: $idToken');
      print('Access token: $accessToken');

      final response = await _apiService.post(
        '$_baseUrl/auth/google',
        {
          'idToken': idToken,
          if (accessToken != null) 'accessToken': accessToken,
        },
      );

      print('Login response: $response');

      if (response['token'] == null) {
        throw Exception('No token received from server');
      }

      return response;
    } catch (e) {
      print('Error during Google login: $e');
      rethrow;
    }
  }
}
