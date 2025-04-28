import 'package:eagle_flight_plan/services/api_session_storage.dart';

import 'api_service.dart';

class UserProfile {
  final int id;
  final String email;
  final String fullName;
  final String profileDescription;
  final String major;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.profileDescription,
    required this.major,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      profileDescription:
          json['profileDescription'] as String? ?? 'No description',
      major: json['major'] as String? ?? 'Undeclared',
    );
  }
}

class UserService extends ApiService {
  UserService({required super.baseUrl});

  Future<UserProfile> getUserProfile() async {
    final userId = (await ApiSessionStorage.getSession()).userId;
    try {
      final response = await get(
        '/user/$userId',
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
