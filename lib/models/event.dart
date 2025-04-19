<<<<<<< HEAD
class EventModel {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool isRegistered;
  final bool isAttended;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.isRegistered,
    required this.isAttended,
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
      isAttended: json['isAttended'] as bool? ?? false,
    );
  }
} 
=======
import 'package:intl/intl.dart';
import 'flight_plan_item.dart';
import 'experience.dart';

class EventNotFoundException implements Exception {
  final String message;
  EventNotFoundException(this.message);

  @override
  String toString() => message;
}

class Event {
  final int id;
  final String name;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  late List<FlightPlanItem> fulfillableItems;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.fulfillableItems = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] ?? '',
      startTime:
          DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime:
          DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
    );
  }

  String get formattedDate {
    final formatter = DateFormat('EEEE, MMMM d, y');
    return formatter.format(startTime);
  }

  String get formattedTimeRange {
    final timeFormatter = DateFormat('h:mm a');
    return '${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}';
  }

  void setFulfillableItemsFromJson(List<dynamic> jsonItems) {
    fulfillableItems = jsonItems
        .map((item) => FlightPlanItem(
              id: item['id'] as int,
              flightPlanItemType: 'experience',
              status: item['status'] as String,
              dueDate: DateTime.parse(item['dueDate'] as String),
              name: item['name'] as String,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              flightPlanId: 0,
              experienceId:
                  (item['experience'] as Map<String, dynamic>?)?['id'] as int?,
              experience: item['experience'] != null
                  ? Experience(
                      id: item['experience']['id'] as int,
                      category: 'Event',
                      experienceType: 'Automatic',
                      reflectionRequired: false,
                      schedulingType: 'special event',
                      semestersFromGrad: 0,
                      description: item['experience']['description'] as String,
                      name: item['experience']['name'] as String,
                      rationale: 'Event check-in',
                      points: item['experience']['points'] as int,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    )
                  : null,
            ))
        .toList();
  }
}
>>>>>>> a9b969c (Did some things)
