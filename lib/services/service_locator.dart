import 'api_service.dart';
import 'auth.dart';
import 'flight_plan.dart';
import 'event_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final String baseUrl;
  late final ApiService _apiService;
  late final Auth _auth;
  late final FlightPlanService _flightPlan;
  late final EventService _event;
  void initialize({required String baseUrl}) {
    this.baseUrl = baseUrl;
    _apiService = ApiService(baseUrl: baseUrl);
    _auth = Auth(baseUrl: baseUrl);
    _flightPlan = FlightPlanService(baseUrl: baseUrl);
    _event = EventService(baseUrl: baseUrl);
  }

  ApiService get api => _apiService;
  Auth get auth => _auth;
  FlightPlanService get flightPlan => _flightPlan;
  EventService get event => _event;
  void dispose() {
    _apiService.dispose();
  }
}
