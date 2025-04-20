import 'dart:convert';
import '../models/link.dart';
import 'service_locator.dart';

class LinkService {
  LinkService();

  Future<List<LinkModel>> getLinksForUser(int userId) async {
    try {
      print('🔍 Fetching links for user $userId');
      
      final response = await ServiceLocator().api.get(
        '/link/user/$userId',
      );
      
      print('📦 Raw API Response: $response');
      
      if (response == null) {
        print('❌ No response received from API');
        return [];
      }

      // The backend returns a map with a data field containing the links array
      final List<dynamic> linksJson = (response['data'] as List<dynamic>?) ?? [];
      
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