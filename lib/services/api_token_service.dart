import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(String token) async {
    print('Saving token: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token saved successfully');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: $token');
    return token;
  }

  static Future<void> clearToken() async {
    print('Clearing token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    print('Token and user ID cleared successfully');
  }

  static Future<void> saveUserId(String userId) async {
    print('Saving user ID: $userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    print('User ID saved successfully');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    print('Retrieved user ID: $userId');
    return userId;
  }
}
