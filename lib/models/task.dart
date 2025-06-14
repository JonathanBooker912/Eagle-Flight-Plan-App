class Task {
  final int id;
  final String category;
  final String schedulingType;
  final String name;
  final String description;
  final String rationale;
  final int semestersFromGrad;
  final String submissionType;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.category,
    required this.schedulingType,
    required this.name,
    required this.description,
    required this.rationale,
    required this.semestersFromGrad,
    required this.submissionType,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      category: json['category'] as String,
      schedulingType: json['schedulingType'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rationale: json['rationale'] as String,
      semestersFromGrad: json['semestersFromGrad'] as int,
      submissionType: json['submissionType'] as String,
      points: json['points'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
