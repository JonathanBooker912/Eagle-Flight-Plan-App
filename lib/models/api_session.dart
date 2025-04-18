import 'dart:convert';

class ApiSession {
  final String token;
  final int userId;
  final String email;
  final int studentId;

  ApiSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.studentId,
  });

  factory ApiSession.fromJson(Map<String, dynamic> json) {
    return ApiSession(
      token: json['token'] as String? ?? "",
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? -1,
      email: json['email'] as String? ?? "",
      studentId: int.tryParse(json['studentId']?.toString() ?? '') ?? -1,
    );
  }

  String toJsonString() {
    return jsonEncode({
      'token': token,
      'userId': userId,
      'email': email,
      'studentId': studentId,
    });
  }
}
