import 'dart:convert';
import 'service_locator.dart';

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
      profileDescription: json['profileDescription'] as String? ?? 'No description',
      major: json['major'] as String? ?? 'Undeclared',
    );
  }
}

class UserService {
  UserService();

  Future<UserProfile> getUserProfile(int userId) async {
    try {
      final response = await ServiceLocator().api.get(
        '/user/$userId',
      );
      
      if (response == null) {
        throw Exception('No response received from API');
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }
} 