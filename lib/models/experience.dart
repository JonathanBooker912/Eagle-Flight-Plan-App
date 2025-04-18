class Experience {
  final int id;
  final String category;
  final String experienceType;
  final bool reflectionRequired;
  final String schedulingType;
  final int semestersFromGrad;
  final String description;
  final String name;
  final String rationale;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;

  Experience({
    required this.id,
    required this.category,
    required this.experienceType,
    required this.reflectionRequired,
    required this.schedulingType,
    required this.semestersFromGrad,
    required this.description,
    required this.name,
    required this.rationale,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as int,
      category: json['category'] as String,
      experienceType: json['experienceType'] as String,
      reflectionRequired: json['reflectionRequired'] as bool,
      schedulingType: json['schedulingType'] as String,
      semestersFromGrad: json['semestersFromGrad'] as int,
      description: json['description'] as String,
      name: json['name'] as String,
      rationale: json['rationale'] as String,
      points: json['points'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'experienceType': experienceType,
      'reflectionRequired': reflectionRequired,
      'schedulingType': schedulingType,
      'semestersFromGrad': semestersFromGrad,
      'description': description,
      'name': name,
      'rationale': rationale,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
