import 'dart:convert';
import '../services/api_session_storage.dart';

import '../models/strength.dart';
import 'service_locator.dart';
import 'api_service.dart';

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

class StrengthService extends ApiService {
  StrengthService({required super.baseUrl});

  Future<StrengthResponse> getStrengthsForUser(
      {int page = 1, int pageSize = 5}) async {
    final userId = (await ApiSessionStorage.getSession()).userId;

    try {
      print(
          '🔍 Fetching strengths for user $userId (page $page, size $pageSize)');

      final response = await get(
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
      final List<dynamic> strengthsJson;
      if (response is Map<String, dynamic>) {
        // If response is a Map, try to get the strengths array from the 'data' key
        strengthsJson = (response['data'] as List<dynamic>?) ?? [];
      } else {
        // If response is already a List, use it directly
        strengthsJson = (response as List<dynamic>?) ?? [];
      }

      print('📊 Response Stats:');
      print('   - Number of strengths: ${strengthsJson.length}');

      final strengths =
          strengthsJson.map((json) => StrengthModel.fromJson(json)).toList();

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
