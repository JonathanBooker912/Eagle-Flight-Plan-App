import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_session.dart';
import '../services/service_locator.dart';

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

  static Future<void> refreshSession() async {
    final currentSession = await getSession();
    clearSession();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      final newToken = (await ServiceLocator().auth.login(idToken)).token;
      final newSession = ApiSession(
        token: newToken,
        userId: currentSession.userId,
        email: currentSession.email,
        studentId: currentSession.studentId,
      );
      await saveSession(newSession);
    }
  }
}
