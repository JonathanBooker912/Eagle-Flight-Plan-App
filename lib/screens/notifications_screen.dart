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
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalNotifications = 0;

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
      final response = await _notificationService.getAllNotificationsForUser(
        widget.userId,
        page: _currentPage,
      );
      print('Received response from service');
      
      setState(() {
        // Cast the notifications list to the correct type
        final List<dynamic> rawNotifications = response['notifications'] ?? [];
        _notifications = rawNotifications.map((notification) {
          print('Processing notification: ${json.encode(notification)}');
          // Parse the date string into a DateTime object
          final date = DateTime.parse(notification['createdAt']);
          final processedNotification = {
            ...notification as Map<String, dynamic>,
            'createdAt': date,
          };
          // Log the processed notification without the DateTime object
          print('Processed notification header: ${processedNotification['header']}');
          print('Processed notification description: ${processedNotification['description']}');
          print('Processed notification date: ${date.toString()}');
          return processedNotification;
        }).toList();
        _totalNotifications = response['total'] ?? 0;
        _totalPages = response['totalPages'] ?? 1;
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Metadata row
                    Row(
                      children: [
                        Icon(Icons.person_outline, 
                          size: 16, 
                          color: AppTheme.textPrimary.withOpacity(0.7)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sent by: ${notification['user']?['fullName'] ?? 'System'}',
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, 
                          size: 16, 
                          color: AppTheme.textPrimary.withOpacity(0.7)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sent on: ${_formatDate(notification['createdAt'])}',
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Divider
                    Divider(color: AppTheme.textPrimary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      notification['description'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
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

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Notifications!',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete some flight plan items to be notified!',
                        style: TextStyle(
                          color: AppTheme.textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return ListTile(
                            title: Text(
                              notification['header'],
                              style: TextStyle(
                                fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              notification['description'],
                              style: TextStyle(
                                color: AppTheme.textPrimary.withOpacity(0.7),
                              ),
                            ),
                            trailing: Text(
                              _formatDate(notification['createdAt']),
                              style: TextStyle(
                                color: AppTheme.textPrimary.withOpacity(0.7),
                              ),
                            ),
                            onTap: () {
                              _markAsRead(notification);
                              _showNotificationDetails(notification);
                            },
                          );
                        },
                      ),
                    ),
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() => _currentPage--);
                                      _loadNotifications();
                                    }
                                  : null,
                            ),
                            Text(
                              'Page $_currentPage of $_totalPages',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                              onPressed: _currentPage < _totalPages
                                  ? () {
                                      setState(() => _currentPage++);
                                      _loadNotifications();
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
} 