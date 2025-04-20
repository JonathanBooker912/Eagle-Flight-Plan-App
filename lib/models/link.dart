class LinkModel {
  final int id;
  final String websiteName;
  final String link;
  final DateTime createdAt;
  final DateTime updatedAt;

  LinkModel({
    required this.id,
    required this.websiteName,
    required this.link,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      id: json['id'] as int,
      websiteName: json['websiteName'] as String,
      link: json['link'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
} 