import 'api_service.dart';
import '../models/api_session.dart';
import '../services/api_session_storage.dart';

class Auth extends ApiService {
  Auth({required super.baseUrl});

  Future<ApiSession> login(String? idToken) async {
    if (idToken == null) {
      throw Exception(
        'ID token is null. Please check Google Sign-In configuration.',
      );
    }

    final session = await post('/login', {
      'credential': idToken,
      'clientType': 'firebase',
    });
    // save token to make student request
    ApiSessionStorage.saveSession(
      ApiSession.fromJson({
        'token': session['token'],
        'userId': '',
        'email': '',
        'studentId': '',
      }),
    );
    final student = await get('/students/user/${session['userId']}');

    // save complete session
    final apiSession = ApiSession.fromJson({
      'token': session['token'],
      'userId': session['userId'],
      'email': session['email'],
      'studentId': student['id'],
    });

    ApiSessionStorage.saveSession(apiSession);
    return apiSession;
  }
}
