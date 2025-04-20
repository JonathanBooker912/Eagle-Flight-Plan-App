import 'dart:convert';
import 'service_locator.dart';

class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BadgeResponse {
  final List<BadgeModel> badges;
  final int total;

  BadgeResponse({
    required this.badges,
    required this.total,
  });
}

class BadgeService {
  BadgeService();

  Future<BadgeResponse> getBadgesForStudent(int studentId, {int page = 1, int pageSize = 6}) async {
    try {
      final response = await ServiceLocator().api.get(
        '/flight-plan-t1/badge/student/$studentId?page=$page&pageSize=$pageSize',
      );
      
      if (response == null) {
        return BadgeResponse(badges: [], total: 0);
      }

      final List<dynamic> badgesJson = response['badges'] ?? [];
      final total = response['total'] ?? 0;
      
      return BadgeResponse(
        badges: badgesJson.map((json) => BadgeModel.fromJson(json)).toList(),
        total: total,
      );
    } catch (e) {
      print('Error fetching badges: $e');
      return BadgeResponse(badges: [], total: 0);
    }
  }
} 