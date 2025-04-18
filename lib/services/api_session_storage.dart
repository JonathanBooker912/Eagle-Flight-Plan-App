import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_session.dart';

class ApiSessionStorage {
  static const String _sessionKey = 'session';

  static Future<void> saveSession(ApiSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session.toJsonString());
  }

  static Future<ApiSession> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return ApiSession.fromJson(
      jsonDecode(prefs.getString(_sessionKey) ?? '{}'),
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
