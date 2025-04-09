import 'api_service.dart';
import 'auth.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final String baseUrl;
  late final ApiService _apiService;
  late final Auth _auth;

  void initialize({required String baseUrl}) {
    this.baseUrl = baseUrl;
    _apiService = ApiService(baseUrl: baseUrl);
    _auth = Auth(baseUrl: baseUrl);
  }

  ApiService get api => _apiService;
  Auth get auth => _auth;

  void dispose() {
    _apiService.dispose();
  }
}
