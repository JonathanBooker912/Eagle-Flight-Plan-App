import 'dart:convert';
import '../models/link.dart';
import 'service_locator.dart';
import 'api_service.dart';
import '../services/api_session_storage.dart';

class LinkService extends ApiService {
  LinkService({required super.baseUrl});

  Future<List<LinkModel>> getLinksForUser() async {
    final userId = (await ApiSessionStorage.getSession()).userId;
    try {
      print('🔍 Fetching links for user $userId');

      final response = await get(
        '/link/user/$userId',
      );

      print('📦 Raw API Response: $response');

      if (response == null) {
        print('❌ No response received from API');
        return [];
      }

      // The backend returns a map with a data field containing the links array
      final List<dynamic> linksJson =
          (response['data'] as List<dynamic>?) ?? [];

      print('📊 Response Stats:');
      print('   - Number of links: ${linksJson.length}');

      final links = linksJson.map((json) => LinkModel.fromJson(json)).toList();

      print('🎯 Parsed Links:');
      for (var link in links) {
        print('   - ${link.websiteName}: ${link.link}');
      }

      return links;
    } catch (e) {
      print('❌ Error fetching links: $e');
      return [];
    }
  }
}
