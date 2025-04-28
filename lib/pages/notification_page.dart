import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
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
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMore && _currentPage < _totalPages) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _notificationService.getNotificationsForUser(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _notifications = response.notifications;
        _totalPages = response.totalPages;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Unable to load notifications. Please try again later.');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _notificationService.getNotificationsForUser(
        page: nextPage,
        pageSize: _pageSize,
      );

      setState(() {
        _notifications.addAll(response.notifications);
        _currentPage = nextPage;
        _totalPages = response.totalPages;
        _hasMore = _currentPage < _totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showError('Unable to load more notifications. Please try again later.');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await _notificationService.markAsRead(notification.id);

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
      _showError('Unable to mark notification as read. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text(
          'Are you sure you want to delete ${_selectedNotifications.length} notification(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedNotifications();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    try {
      await Future.wait(
        _selectedNotifications
            .map((id) => _notificationService.deleteNotification(id)),
      );
      setState(() {
        _notifications
            .removeWhere((n) => _selectedNotifications.contains(n.id));
        _selectedNotifications.clear();
      });
      _showSuccess('Notifications deleted successfully');
    } catch (e) {
      _showError('Unable to delete notifications. Please try again.');
    }
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.outline),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${notification.user['fullName']}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sent: ${_formatDate(notification.createdAt)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          notification.description,
                          style: Theme.of(context).textTheme.bodyLarge,
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

  void _toggleNotificationSelection(NotificationModel notification) {
    if (_selectedNotifications.contains(notification.id)) {
      _selectedNotifications.remove(notification.id);
    } else {
      _selectedNotifications.add(notification.id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    double height = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      floatingActionButton: _selectedNotifications.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'markAsRead',
                  onPressed: _markSelectedAsRead,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.mark_email_read),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'delete',
                  onPressed: _showDeleteConfirmation,
                  backgroundColor: colorScheme.error,
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          : null,
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications available',
                    style: textTheme.bodyLarge,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, height + 6, 6, 6),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Notifications',
                            style: textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _currentPage = 1;
                            _hasMore = true;
                          });
                          await _loadNotifications();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
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
                              dismissThresholds: const {
                                DismissDirection.startToEnd: 0.15,
                              },
                              resizeDuration: const Duration(milliseconds: 150),
                              movementDuration:
                                  const Duration(milliseconds: 150),
                              behavior: HitTestBehavior.opaque,
                              background: Container(
                                color: colorScheme.primary,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.mark_email_read,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                _toggleNotificationSelection(notification);
                                return false;
                              },
                              child: InkWell(
                                onTap: () =>
                                    _showNotificationDetails(notification),
                                child: Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  color: _selectedNotifications
                                          .contains(notification.id)
                                      ? colorScheme.secondary
                                          .withValues(alpha: 0.2)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (!notification.read &&
                                            !_selectedNotifications
                                                .contains(notification.id))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0),
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        if (_selectedNotifications
                                            .contains(notification.id))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: colorScheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    notification
                                                            .user['fullName'] ??
                                                        'System',
                                                    style: textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontWeight: notification
                                                              .read
                                                          ? FontWeight.normal
                                                          : FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatDate(
                                                        notification.createdAt),
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                      fontWeight: notification
                                                              .read
                                                          ? FontWeight.normal
                                                          : FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                notification.header,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: notification.read
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                ),
                                              ),
                                            ],
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

  Future<void> _markSelectedAsRead() async {
    try {
      await Future.wait(
        _selectedNotifications.map((id) => _notificationService.markAsRead(id)),
      );
      setState(() {
        _notifications = _notifications.map((n) {
          if (_selectedNotifications.contains(n.id)) {
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
        _selectedNotifications.clear();
      });
      _showSuccess('Notifications marked as read');
    } catch (e) {
      _showError('Unable to mark notifications as read. Please try again.');
    }
  }
}
