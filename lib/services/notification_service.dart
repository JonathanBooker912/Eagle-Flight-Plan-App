import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int totalPages;

  NotificationResponse({
    required this.notifications,
    required this.totalPages,
  });
}

class NotificationService {
  final String baseUrl;
  final String token;

  NotificationService({required this.baseUrl, required this.token});

  Future<NotificationResponse> getNotificationsForUser(int userId, {int page = 1, int pageSize = 14}) async {
    print('Fetching notifications for user $userId, page $page');
    final url = Uri.parse('$baseUrl/notification/user/$userId?page=$page&pageSize=$pageSize&sortBy=createdAt&sortOrder=desc');
    print('API URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> notificationsJson = data['notifications'];
      final total = data['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();
      
      print('Total notifications: $total');
      print('Total pages: $totalPages');
      print('Notifications count: ${notificationsJson.length}');
      
      return NotificationResponse(
        notifications: notificationsJson.map((json) => NotificationModel.fromJson(json)).toList(),
        totalPages: totalPages,
      );
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(int userId, int notificationId) async {
    print('Marking notification $notificationId as read for user $userId');
    final response = await http.put(
      Uri.parse('$baseUrl/notification/user/$userId/notification/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'read': true}),
    );

    print('Mark as read response: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error response: ${response.body}');
      throw Exception('Failed to mark notification as read: ${response.statusCode}');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    print('Deleting notification $notificationId');
    final response = await http.delete(
      Uri.parse('$baseUrl/notification/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Delete response: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error response: ${response.body}');
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }
} 