import 'api_service.dart';
import 'auth.dart';
import 'flight_plan.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final String baseUrl;
  late final ApiService _apiService;
  late final Auth _auth;
  late final FlightPlanService _flightPlan;
  void initialize({required String baseUrl}) {
    this.baseUrl = baseUrl;
    _apiService = ApiService(baseUrl: baseUrl);
    _auth = Auth(baseUrl: baseUrl);
    _flightPlan = FlightPlanService(baseUrl: baseUrl);
  }

  ApiService get api => _apiService;
  Auth get auth => _auth;
  FlightPlanService get flightPlan => _flightPlan;
  void dispose() {
    _apiService.dispose();
  }
}
