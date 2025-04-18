import 'dart:convert';
import '../models/notification.dart';
import 'service_locator.dart';

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int totalPages;

  NotificationResponse({
    required this.notifications,
    required this.totalPages,
  });
}

class NotificationService {
  NotificationService();

  Future<NotificationResponse> getNotificationsForUser(int userId, {int page = 1, int pageSize = 14}) async {
    print('Fetching notifications for user $userId, page $page');
    try {
      final response = await ServiceLocator().api.get(
        '/notification/user/$userId?page=$page&pageSize=$pageSize&sortBy=createdAt&sortOrder=desc',
      );
      
      print('API Response: $response');
      
      if (response == null) {
        return NotificationResponse(notifications: [], totalPages: 0);
      }

      final List<dynamic> notificationsJson = response['notifications'] ?? [];
      final total = response['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();
      
      return NotificationResponse(
        notifications: notificationsJson.map((json) => NotificationModel.fromJson(json)).toList(),
        totalPages: totalPages,
      );
    } catch (e) {
      print('Error in getNotificationsForUser: $e');
      // Return empty response instead of throwing error
      return NotificationResponse(notifications: [], totalPages: 0);
    }
  }

  Future<void> markAsRead(int userId, int notificationId) async {
    print('Marking notification $notificationId as read for user $userId');
    try {
      await ServiceLocator().api.put(
        '/notification/user/$userId/notification/$notificationId',
        {'read': true},
      );
    } catch (e) {
      print('Error in markAsRead: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    print('Deleting notification $notificationId');
    await ServiceLocator().api.delete('/notification/$notificationId');
  }
} 