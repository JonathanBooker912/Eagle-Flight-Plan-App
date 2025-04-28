import 'task.dart';
import 'experience.dart';

class FlightPlanItem {
  final int id;
  final String flightPlanItemType;
  final String status;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    required this.name,
    this.createdAt,
    this.updatedAt,
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
      name: json['name'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      flightPlanId: json['flightPlanId'] as int,
      taskId: json['taskId'] as int?,
      eventId: json['eventId'] as int?,
      experienceId: json['experienceId'] as int?,
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      experience: json['experience'] != null
          ? Experience.fromJson(json['experience'])
          : null,
      event: json['event'],
    );
  }
}
