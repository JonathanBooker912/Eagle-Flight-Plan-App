import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ServiceLocator _serviceLocator = ServiceLocator();
  late final NotificationService _notificationService;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(_serviceLocator, 'http://localhost:3000');
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);
      final notifications = await _notificationService.getUserNotifications(widget.userId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    try {
      await _notificationService.markNotificationAsRead(
        widget.userId,
        notification['id'],
      );
      setState(() {
        _notifications = _notifications.map((n) {
          if (n['id'] == notification['id']) {
            return {
              ...n,
              'read': true,
            };
          }
          return n;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n['read']))
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_notifications.where((n) => !n['read']).length} unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications yet'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: ListTile(
                            title: Text(
                              notification['header'],
                              style: TextStyle(
                                fontWeight: notification['read']
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification['description']),
                                const SizedBox(height: 4),
                                Text(
                                  '${notification['createdAt'].day}/${notification['createdAt'].month}/${notification['createdAt'].year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: !notification['read']
                                ? IconButton(
                                    icon: const Icon(Icons.check_circle_outline),
                                    onPressed: () => _markAsRead(notification),
                                  )
                                : null,
                            onTap: notification['actionLink'] != null
                                ? () {
                                    // Handle action link navigation
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
} 