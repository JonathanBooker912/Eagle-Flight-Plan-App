import 'dart:convert';
import '../models/strength.dart';
import 'service_locator.dart';

class StrengthResponse {
  final List<StrengthModel> strengths;
  final int totalPages;
  final String? errorMessage;

  StrengthResponse({
    required this.strengths,
    required this.totalPages,
    this.errorMessage,
  });
}

class StrengthService {
  StrengthService();

  Future<StrengthResponse> getStrengthsForUser(int userId, {int page = 1, int pageSize = 5}) async {
    try {
      print('🔍 Fetching strengths for user $userId (page $page, size $pageSize)');
      
      final response = await ServiceLocator().api.get(
        '/strengths/student/$userId',
      );
      
      print('📦 Raw API Response: $response');
      
      if (response == null) {
        print('❌ No response received from API');
        return StrengthResponse(
          strengths: [],
          totalPages: 0,
          errorMessage: 'No response received from server',
        );
      }

      // Check if response is an error message
      if (response is Map<String, dynamic> && response.containsKey('error')) {
        print('❌ Backend error: ${response['error']}');
        return StrengthResponse(
          strengths: [],
          totalPages: 0,
          errorMessage: 'Backend error: ${response['error']}',
        );
      }

      // The backend returns an array of strengths directly
      final List<dynamic> strengthsJson = (response as List<dynamic>?) ?? [];
      
      print('📊 Response Stats:');
      print('   - Number of strengths: ${strengthsJson.length}');
      
      final strengths = strengthsJson.map((json) => StrengthModel.fromJson(json)).toList();
      
      print('🎯 Parsed Strengths:');
      for (var strength in strengths) {
        print('   - ${strength.name} (Domain: ${strength.domain})');
      }
      
      return StrengthResponse(
        strengths: strengths,
        totalPages: 1, // Since the backend doesn't paginate
      );
    } catch (e) {
      print('❌ Error fetching strengths: $e');
      return StrengthResponse(
        strengths: [],
        totalPages: 0,
        errorMessage: 'Error fetching strengths: $e',
      );
    }
  }
} 