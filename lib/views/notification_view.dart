import 'package:flutter/material.dart';
import '../services/notification_service.dart' as notification_service;
import 'package:intl/intl.dart';

class NotificationView extends StatefulWidget {
  final String userId;
  final bool isAdmin;

  const NotificationView({
    Key? key,
    required this.userId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final notification_service.NotificationService _notificationService = notification_service.NotificationService();
  
  List<notification_service.Notification> _notifications = [];
  notification_service.Notification? _selectedNotification;
  bool _showSidebar = false;
  bool _noNotifications = false;
  int _currentPage = 1;
  final int _pageSize = 14;
  int _totalPages = 1;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _notificationService.getAllNotificationsForUser(
        widget.userId,
        _currentPage,
        _pageSize,
      );

      if (mounted) {
        setState(() {
          _notifications = result['notifications'];
          _totalPages = (result['total'] / _pageSize).ceil();
          _noNotifications = _notifications.isEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markNotificationAsRead(notification_service.Notification notification) async {
    try {
      await _notificationService.markNotificationAsRead(
        widget.userId,
        notification.id,
      );
      
      setState(() {
        _selectedNotification = notification;
        _showSidebar = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating notification: $e')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Row(
                    children: [
                      // Main content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_noNotifications)
                                const Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No Notifications!',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Complete some flight plan items to be notified!',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = _notifications[index];
                                      return Card(
                                        color: notification.read ? Colors.grey[200] : Colors.white,
                                        child: ListTile(
                                          title: Text(notification.header),
                                          subtitle: Text(_formatDateTime(notification.dateTime)),
                                          onTap: () => _markNotificationAsRead(notification),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Sidebar
                      if (_showSidebar && _selectedNotification != null)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedNotification!.header,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(() => _showSidebar = false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sent By: ${_selectedNotification!.user.fName} ${_selectedNotification!.user.lName}',
                              ),
                              Text(
                                'Sent On: ${_formatDateTime(_selectedNotification!.createdAt)}',
                              ),
                              const Divider(),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(_selectedNotification!.description),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: _noNotifications || _isLoading || _error != null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadNotifications();
                          }
                        : null,
                  ),
                  Text('Page $_currentPage of $_totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
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
    );
  }
} 