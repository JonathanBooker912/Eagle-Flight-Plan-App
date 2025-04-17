import 'dart:convert';
import '../services/service_locator.dart';

class NotificationService {
  final ServiceLocator _serviceLocator;
  final String baseUrl;

  NotificationService(this._serviceLocator, this.baseUrl);

  Future<Map<String, dynamic>> getAllNotificationsForUser(String userId, {int page = 1, int pageSize = 14}) async {
    try {
      print('=== Notification Service Debug ===');
      print('User ID: $userId');
      print('Page: $page');
      print('Page Size: $pageSize');
      print('Base URL: $baseUrl');
      print('Full endpoint: $baseUrl/notification/user/$userId');
      
      final response = await _serviceLocator.api.get(
        '/notification/user/$userId',
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
        },
      );
      
      print('Response received:');
      print('Response body: ${json.encode(response)}');
      
      if (response['notifications'] == null) {
        print('Warning: No notifications field in response');
        print('Response keys: ${response.keys.join(', ')}');
        return {
          'notifications': [],
          'total': 0,
          'currentPage': page,
          'totalPages': 0,
        };
      }
      
      final notifications = List<Map<String, dynamic>>.from(response['notifications']);
      final total = response['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();
      
      print('Successfully parsed ${notifications.length} notifications');
      print('Total notifications: $total');
      print('Total pages: $totalPages');
      
      if (notifications.isNotEmpty) {
        print('First notification sample:');
        print('ID: ${notifications.first['id']}');
        print('Header: ${notifications.first['header']}');
        print('Description: ${notifications.first['description']}');
        print('Read status: ${notifications.first['read']}');
        print('Created at: ${notifications.first['createdAt']}');
      }
      
      return {
        'notifications': notifications,
        'total': total,
        'currentPage': page,
        'totalPages': totalPages,
      };
    } catch (e) {
      print('=== Error in Notification Service ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      print('=== Marking Notification as Read ===');
      print('User ID: $userId');
      print('Notification ID: $notificationId');
      print('Full endpoint: $baseUrl/notification/user/$userId/notification/$notificationId');
      
      await _serviceLocator.api.put(
        '/notification/user/$userId/notification/$notificationId',
        {'read': true},
      );
      
      print('Successfully marked notification as read');
    } catch (e) {
      print('=== Error Marking Notification as Read ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
} 