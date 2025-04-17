class AppNotification {
  final int id;
  final String header;
  final String description;
  final String? actionLink;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.header,
    required this.description,
    this.actionLink,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      header: json['header'],
      description: json['description'],
      actionLink: json['actionLink'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 