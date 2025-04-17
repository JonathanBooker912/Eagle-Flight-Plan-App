import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'dart:convert';

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
    _notificationService = NotificationService(_serviceLocator, _serviceLocator.baseUrl);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);
      print('Loading notifications for user ${widget.userId}');
      final notifications = await _notificationService.getUserNotifications(widget.userId);
      print('Received ${notifications.length} notifications from service');
      
      setState(() {
        _notifications = notifications.map((notification) {
          print('Processing notification: ${json.encode(notification)}');
          // Parse the date string into a DateTime object
          final date = DateTime.parse(notification['createdAt']);
          final processedNotification = {
            ...notification,
            'createdAt': date,
          };
          // Log the processed notification without the DateTime object
          print('Processed notification header: ${processedNotification['header']}');
          print('Processed notification description: ${processedNotification['description']}');
          print('Processed notification date: ${date.toString()}');
          return processedNotification;
        }).toList();
        print('Final notifications list length: ${_notifications.length}');
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadNotifications: $e');
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

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Notification content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification['header'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sender and Date
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppTheme.textPrimary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sent by ${notification['sender'] ?? 'System'}',
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textPrimary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sent on ${notification['createdAt'].toString().split(' ')[0]}',
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    Container(
                      height: 1,
                      color: AppTheme.textPrimary.withOpacity(0.1),
                    ),
                    const SizedBox(height: 24),
                    // Description
                    Text(
                      notification['description'],
                      style: TextStyle(
                        color: AppTheme.textPrimary.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_notifications.any((n) => !n['read']))
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              '${_notifications.where((n) => !n['read']).length} unread notifications',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _notifications.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final date = notification['createdAt'] as DateTime;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              color: AppTheme.surfaceColor,
                              child: ListTile(
                                title: Text(
                                  notification['header'],
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: notification['read']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification['description'],
                                      style: TextStyle(
                                        color: AppTheme.textPrimary.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${date.day}/${date.month}/${date.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textPrimary.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: !notification['read']
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: AppTheme.accentColor,
                                        ),
                                        onPressed: () => _markAsRead(notification),
                                      )
                                    : null,
                                onTap: () => _showNotificationDetails(notification),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
} 