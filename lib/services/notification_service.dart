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
      final session = await ApiSessionStorage.getSession();

      if (session.userId == -1) {
        return NotificationResponse(notifications: [], totalPages: 0);
      }

      final response = await ServiceLocator().api.get(
            '/notification/user/${session.userId}?page=$page&pageSize=$pageSize&sortBy=createdAt&sortOrder=desc',
          );

      final List<dynamic> notificationsJson = response['notifications'] ?? [];
      final total = response['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();

      final notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return NotificationResponse(
        notifications: notifications,
        totalPages: totalPages,
      );
    } catch (e) {
      return NotificationResponse(notifications: [], totalPages: 0);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final session = await ApiSessionStorage.getSession();

      await ServiceLocator().api.put(
        '/notification/user/${session.userId}/notification/$notificationId',
        {'read': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await ServiceLocator().api.delete('/notification/$notificationId');
    } catch (e) {
      rethrow;
    }
  }
}
