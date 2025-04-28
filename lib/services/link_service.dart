import '../models/link.dart';
import 'api_service.dart';
import '../services/api_session_storage.dart';

class LinkService extends ApiService {
  LinkService({required super.baseUrl});

  Future<List<LinkModel>> getLinksForUser() async {
    final userId = (await ApiSessionStorage.getSession()).userId;
    try {
      final response = await get(
        '/link/user/$userId',
      );

      // The backend returns a map with a data field containing the links array
      final List<dynamic> linksJson =
          (response['data'] as List<dynamic>?) ?? [];

      final links = linksJson.map((json) => LinkModel.fromJson(json)).toList();

      return links;
    } catch (e) {
      return [];
    }
  }
}
