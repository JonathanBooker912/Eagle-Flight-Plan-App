import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  final int userId;

  const NotificationPage({
    Key? key,
    required this.userId,
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
  final int _pageSize = 14;
  int _totalPages = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _selectedNotifications = {};

  @override
  void initState() {
    super.initState();
    print('NotificationPage initState - userId: ${widget.userId}');
    _notificationService = NotificationService();
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    if (!notification.read) {
      _markAsRead(notification);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    notification.header,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${notification.user['fullName']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sent: ${_formatDate(notification.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          notification.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building NotificationPage - isLoading: $_isLoading, notifications count: ${_notifications.length}');
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Inbox',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
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
                            return Dismissible(
                              key: Key(notification.id.toString()),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: const Color(0xFF2784BB),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.mark_email_read,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                _markAsRead(notification);
                                return false;
                              },
                              child: InkWell(
                                onTap: () => _showNotificationDetails(notification),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              notification.user['fullName'] ?? 'System',
                                              style: TextStyle(
                                                fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _formatDate(notification.createdAt),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          notification.header,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 