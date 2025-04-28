import '../services/api_session_storage.dart';

import '../models/strength.dart';
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
      final response = await get(
        '/strengths/student/$userId',
      );

      // Check if response is an error message
      if (response.containsKey('error')) {
        return StrengthResponse(
          strengths: [],
          totalPages: 0,
          errorMessage: 'Backend error: ${response['error']}',
        );
      }

      // The backend returns an array of strengths directly
      final List<dynamic> strengthsJson;
      // If response is a Map, try to get the strengths array from the 'data' key
      strengthsJson = (response['data'] as List<dynamic>?) ?? [];

      final strengths =
          strengthsJson.map((json) => StrengthModel.fromJson(json)).toList();

      return StrengthResponse(
        strengths: strengths,
        totalPages: 1, // Since the backend doesn't paginate
      );
    } catch (e) {
      return StrengthResponse(
        strengths: [],
        totalPages: 0,
        errorMessage: 'Error fetching strengths: $e',
      );
    }
  }
}
