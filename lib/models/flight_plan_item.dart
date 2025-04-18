import 'task.dart';
import 'experience.dart';

class FlightPlanItem {
  final int id;
  final String flightPlanItemType;
  final String status;
  final DateTime dueDate;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int flightPlanId;
  final int? taskId;
  final int? eventId;
  final int? experienceId;
  final Task? task;
  final Experience? experience;
  final dynamic event; // Can be null

  FlightPlanItem({
    required this.id,
    required this.flightPlanItemType,
    required this.status,
    required this.dueDate,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.flightPlanId,
    this.taskId,
    this.eventId,
    this.experienceId,
    this.task,
    this.experience,
    this.event,
  });

  factory FlightPlanItem.fromJson(Map<String, dynamic> json) {
    return FlightPlanItem(
      id: json['id'] as int,
      flightPlanItemType: json['flightPlanItemType'] as String,
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flightPlanId: json['flightPlanId'] as int,
      taskId: json['taskId'] as int?,
      eventId: json['eventId'] as int?,
      experienceId: json['experienceId'] as int?,
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      experience:
          json['experience'] != null
              ? Experience.fromJson(json['experience'])
              : null,
      event: json['event'],
    );
  }
}
