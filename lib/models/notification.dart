class NotificationModel {
  final int id;
  final String header;
  final String description;
  final String? actionLink;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic> user;

  NotificationModel({
    required this.id,
    required this.header,
    required this.description,
    this.actionLink,
    required this.read,
    required this.createdAt,
    required this.user,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      header: json['header'] as String,
      description: json['description'] as String,
      actionLink: json['actionLink'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] as Map<String, dynamic>? ?? {},
    );
  }
} 