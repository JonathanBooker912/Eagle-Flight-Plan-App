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
      id: json['id'],
      header: json['header'],
      description: json['description'],
      actionLink: json['actionLink'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'],
    );
  }
} 