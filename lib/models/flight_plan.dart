import 'semester.dart';
import 'flight_plan_item.dart';

class FlightPlan {
  final int id;
  final int semestersFromGrad;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int semesterId;
  final int studentId;
  final Semester semester;
  final List<FlightPlanItem> flightPlanItems;

  FlightPlan({
    required this.id,
    required this.semestersFromGrad,
    required this.createdAt,
    required this.updatedAt,
    required this.semesterId,
    required this.studentId,
    required this.semester,
    required this.flightPlanItems,
  });

  factory FlightPlan.fromJson(Map<String, dynamic> json) {
    return FlightPlan(
      id: json['id'] as int,
      semestersFromGrad: json['semestersFromGrad'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      semesterId: json['semesterId'] as int,
      studentId: json['studentId'] as int,
      semester: Semester.fromJson(json['semester'] as Map<String, dynamic>),
      flightPlanItems:
          (json['flightPlanItems'] as List)
              .map(
                (item) => FlightPlanItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  String get semesterDisplayName => semester.displayName;
}


// {
//         "id": 1,
//         "semestersFromGrad": 8,
//         "createdAt": "2025-04-09T15:05:18.000Z",
//         "updatedAt": "2025-04-09T15:05:18.000Z",
//         "semesterId": 1,
//         "studentId": 1,
//         "semester": {
//             "id": 1,
//             "term": "fall",
//             "year": "2024",
//             "startDate": "2024-08-01T01:00:00.000Z",
//             "endDate": "2024-12-15T01:00:00.000Z",
//             "createdAt": "2025-04-09T15:05:18.000Z",
//             "updatedAt": "2025-04-09T15:05:18.000Z"
//         },
//         "flightPlanItems": [
//             {
//                 "id": 1,
//                 "flightPlanItemType": "Task",
//                 "status": "Complete",
//                 "dueDate": "2024-09-15T00:00:00.000Z",
//                 "name": "Capstone",
//                 "createdAt": "2025-04-09T15:05:18.000Z",
//                 "updatedAt": "2025-04-09T15:05:18.000Z",
//                 "flightPlanId": 1,
//                 "taskId": 1,
//                 "eventId": null,
//                 "experienceId": null,
//                 "task": {
//                     "id": 1,
//                     "category": "Academic",
//                     "taskType": "Automatic",
//                     "reflectionRequired": true,
//                     "schedulingType": "every semester",
//                     "name": "Capstone Prep",
//                     "description": "Prepare for final project",
//                     "rationale": "Essential for graduation",
//                     "semestersFromGrad": 8,
//                     "completionType": "confirmed",
//                     "points": 50,
//                     "createdAt": "2025-04-09T15:05:18.000Z",
//                     "updatedAt": "2025-04-09T15:05:18.000Z"
//                 },
//                 "experience": null,
//                 "event": null
//             },
//         ]
// }

// "experience": {
//                 "id": 56,
//                 "category": "Mentoring",
//                 "experienceType": "Automatic",
//                 "reflectionRequired": true,
//                 "schedulingType": "special event",
//                 "semestersFromGrad": 6,
//                 "description": "Talk with mentor",
//                 "name": "Mentor Talk",
//                 "rationale": "Career planning",
//                 "points": 20,
//                 "createdAt": "2025-04-09T20:31:04.000Z",
//                 "updatedAt": "2025-04-09T20:31:04.000Z"
//             },