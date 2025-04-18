import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  final String token;
  final String baseUrl;

  const NotificationPage({
    Key? key,
    required this.userId,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('NotificationPage initState - userId: ${widget.userId}');
    _notificationService = NotificationService(
      baseUrl: widget.baseUrl,
      token: widget.token,
    );
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMore && _currentPage < _totalPages) {
        print('Reached bottom, loading more notifications');
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    print('Loading initial notifications');
    try {
      final response = await _notificationService.getNotificationsForUser(
        widget.userId,
        page: _currentPage,
        pageSize: _pageSize,
      );
      print('Received ${response.notifications.length} notifications');
      setState(() {
        _notifications = response.notifications;
        _totalPages = response.totalPages;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Unable to load notifications. Please try again later.');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    print('Loading more notifications, page ${_currentPage + 1}');
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _notificationService.getNotificationsForUser(
        widget.userId,
        page: nextPage,
        pageSize: _pageSize,
      );

      print('Received ${response.notifications.length} more notifications');
      setState(() {
        _notifications.addAll(response.notifications);
        _currentPage = nextPage;
        _totalPages = response.totalPages;
        _hasMore = _currentPage < _totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading more notifications: $e');
      setState(() {
        _isLoadingMore = false;
      });
      _showError('Unable to load more notifications. Please try again later.');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    print('Marking notification ${notification.id} as read');
    try {
      await _notificationService.markAsRead(widget.userId, notification.id);
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notification.id) {
            return NotificationModel(
              id: n.id,
              header: n.header,
              description: n.description,
              actionLink: n.actionLink,
              read: true,
              createdAt: n.createdAt,
              user: n.user,
            );
          }
          return n;
        }).toList();
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      _showError('Unable to mark notification as read. Please try again.');
    }
  }

  void _showError(String message) {
    print('Showing error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building NotificationPage - isLoading: $_isLoading, notifications count: ${_notifications.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    print('Refreshing notifications');
                    setState(() {
                      _currentPage = 1;
                      _hasMore = true;
                    });
                    await _loadNotifications();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return _isLoadingMore
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final notification = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            notification.header,
                            style: TextStyle(
                              fontWeight: notification.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: notification.read
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From: ${notification.user['fullName']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: notification.read
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: notification.read
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!notification.read) {
                              _markAsRead(notification);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 