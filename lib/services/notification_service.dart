import 'dart:convert';
import '../services/service_locator.dart';

class NotificationService {
  final ServiceLocator _serviceLocator;
  final String baseUrl;

  NotificationService(this._serviceLocator, this.baseUrl);

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _serviceLocator.api.get('/notification/user/$userId');
      return List<Map<String, dynamic>>.from(response['notifications']);
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _serviceLocator.api.put(
        '/notification/user/$userId/notification/$notificationId',
        {'read': true},
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
} 