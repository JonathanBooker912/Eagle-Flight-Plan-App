import 'dart:convert';
import '../models/notification.dart';
import 'service_locator.dart';
import '../services/api_session_storage.dart';

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

  Future<NotificationResponse> getNotificationsForUser(
      {int page = 1, int pageSize = 14}) async {
    try {
      print('🔍 Fetching notifications for user');
      final session = await ApiSessionStorage.getSession();
      print('📦 Session data: ${session.toJsonString()}');

      if (session.userId == -1) {
        print('❌ Invalid user ID in session');
        return NotificationResponse(notifications: [], totalPages: 0);
      }

      final response = await ServiceLocator().api.get(
            '/notification/user/${session.userId}?page=$page&pageSize=$pageSize&sortBy=createdAt&sortOrder=desc',
          );

      print('📦 Raw API Response: $response');

      if (response == null) {
        print('❌ No response received from API');
        return NotificationResponse(notifications: [], totalPages: 0);
      }

      final List<dynamic> notificationsJson = response['notifications'] ?? [];
      final total = response['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();

      print('📊 Response Stats:');
      print('   - Number of notifications: ${notificationsJson.length}');
      print('   - Total notifications: $total');
      print('   - Total pages: $totalPages');

      final notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      print('🎯 Parsed Notifications:');
      for (var notification in notifications) {
        print('   - ${notification.header} (${notification.id})');
      }

      return NotificationResponse(
        notifications: notifications,
        totalPages: totalPages,
      );
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return NotificationResponse(notifications: [], totalPages: 0);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final session = await ApiSessionStorage.getSession();
      print(
          '📝 Marking notification $notificationId as read for user ${session.userId}');

      await ServiceLocator().api.put(
        '/notification/user/${session.userId}/notification/$notificationId',
        {'read': true},
      );
      print('✅ Successfully marked notification as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Deleting notification $notificationId');
      await ServiceLocator().api.delete('/notification/$notificationId');
      print('✅ Successfully deleted notification');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }
}
