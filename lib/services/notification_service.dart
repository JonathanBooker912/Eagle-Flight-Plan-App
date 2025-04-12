import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class Notification {
  final String id;
  final String header;
  final String description;
  final DateTime dateTime;
  final bool read;
  final User user;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.header,
    required this.description,
    required this.dateTime,
    required this.read,
    required this.user,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      header: json['header'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      read: json['read'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class User {
  final String fName;
  final String lName;

  User({
    required this.fName,
    required this.lName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fName: json['fName'],
      lName: json['lName'],
    );
  }
}

class NotificationService {
  final http.Client _client;

  NotificationService() : _client = http.Client();

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    int retryCount = 0,
    bool isRetry = false,
  }) async {
    try {
      var token = await AuthService.getToken();
      if (token == null) {
        await AuthService.loginTestUser();
        token = await AuthService.getToken();
      }

      final response = await _client.send(
        http.Request(
          method,
          Uri.parse('${AppConfig.baseUrl}/flight-plan-t1$endpoint'),
        )
          ..headers.addAll({
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            ...?headers,
          })
          ..body = body ?? '',
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      } else if (response.statusCode == 401 && !isRetry) {
        // Token expired, try to refresh
        await AuthService.logout();
        await AuthService.loginTestUser();
        return _makeRequest(method, endpoint,
            headers: headers, body: body, retryCount: retryCount, isRetry: true);
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found: $endpoint');
      } else if (response.statusCode >= 500 && retryCount < AppConfig.maxRetries) {
        await Future.delayed(AppConfig.retryDelay);
        return _makeRequest(method, endpoint,
            headers: headers, body: body, retryCount: retryCount + 1);
      } else {
        throw Exception(
            'Request failed with status ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      throw Exception('Error making request: $e');
    }
  }

  Future<Map<String, dynamic>> getAllNotificationsForUser(
    String userId,
    int page,
    int pageSize,
  ) async {
    try {
      final result = await _makeRequest(
        'GET',
        '/notification/user/$userId?page=$page&pageSize=$pageSize',
      );

      return {
        'notifications': (result['notifications'] as List)
            .map((notif) => Notification.fromJson(notif))
            .toList(),
        'total': result['total'],
      };
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _makeRequest(
        'PUT',
        '/notification/user/$userId/notification/$notificationId',
        body: json.encode({'read': true}),
      );
    } catch (e) {
      throw Exception('Error updating notification: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 