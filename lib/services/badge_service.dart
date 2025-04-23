import 'dart:convert';
import 'api_service.dart';
import '../services/api_session_storage.dart';

class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String badgeType;
  final int points;
  final String imageName;
  final String ruleType;
  final DateTime createdAt;
  final DateTime updatedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeType,
    required this.points,
    required this.imageName,
    required this.ruleType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      badgeType: json['badgeType'] as String,
      points: json['points'] as int,
      imageName: json['imageName'] as String,
      ruleType: json['ruleType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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

class BadgeService extends ApiService {
  BadgeService({required super.baseUrl});

  Future<BadgeResponse> getBadgesForStudent(
      {int page = 1, int pageSize = 6}) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    try {
      print(
          '🔍 Fetching badges for student $studentId (page: $page, pageSize: $pageSize)');

      final response = await get(
        '/badge/student/$studentId?page=$page&pageSize=$pageSize',
      );

      print('📦 Raw API Response: $response');

      if (response == null) {
        print('❌ No response received from API');
        return BadgeResponse(badges: [], total: 0);
      }

      // The response is a map with badges and total
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      final List<dynamic> badgesJson = responseMap['badges'] ?? [];
      final total = responseMap['total'] ?? 0;

      print('📊 Response Stats:');
      print('   - Number of badges: ${badgesJson.length}');
      print('   - Total badges: $total');

      final badges =
          badgesJson.map((json) => BadgeModel.fromJson(json)).toList();

      print('🎯 Parsed Badges:');
      for (var badge in badges) {
        print('   - ${badge.name} (${badge.description})');
      }

      return BadgeResponse(badges: badges, total: total);
    } catch (e) {
      print('❌ Error fetching badges: $e');
      return BadgeResponse(badges: [], total: 0);
    }
  }
}
