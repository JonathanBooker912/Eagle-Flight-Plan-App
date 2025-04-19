class EventModel {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool isRegistered;
  final bool isAttending;
  final Map<String, dynamic>? user;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.isRegistered,
    required this.isAttending,
    this.user,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      isRegistered: json['isRegistered'] as bool? ?? false,
      isAttending: json['isAttending'] as bool? ?? false,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
} 