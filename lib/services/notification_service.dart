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
  final String baseUrl;
  final String token;

  NotificationService({required this.baseUrl, required this.token});

  Future<NotificationResponse> getNotificationsForUser(int userId, {int page = 1, int pageSize = 14}) async {
    print('Fetching notifications for user $userId, page $page');
    final response = await ServiceLocator().api.get(
      '/notification/user/$userId?page=$page&pageSize=$pageSize&sortBy=createdAt&sortOrder=desc',
    );

    final List<dynamic> notificationsJson = response['notifications'];
    final total = response['total'] ?? 0;
    final totalPages = (total / pageSize).ceil();
    
    return NotificationResponse(
      notifications: notificationsJson.map((json) => NotificationModel.fromJson(json)).toList(),
      totalPages: totalPages,
    );
  }

  Future<void> markAsRead(int userId, int notificationId) async {
    print('Marking notification $notificationId as read for user $userId');
    await ServiceLocator().api.put(
      '/notification/user/$userId/notification/$notificationId',
      {'read': true},
    );
  }

  Future<void> deleteNotification(int notificationId) async {
    print('Deleting notification $notificationId');
    await ServiceLocator().api.delete('/notification/$notificationId');
  }
} 