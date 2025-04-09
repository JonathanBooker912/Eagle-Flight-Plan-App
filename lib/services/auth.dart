import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class Auth extends ApiService {
  Auth({required super.baseUrl});

  Future<Map<String, dynamic>> loginWithGoogle(
    GoogleSignInAuthentication auth,
  ) async {
    if (auth.idToken == null) {
      throw Exception(
        'ID token is null. Please check Google Sign-In configuration.',
      );
    }

    return post('/login', {'credential': auth.idToken});
  }
}
