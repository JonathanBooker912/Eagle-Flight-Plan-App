import 'api_service.dart';
import 'auth.dart';
import 'flight_plan.dart';
import 'event_service.dart';
import 'strength_service.dart';
import 'link_service.dart';
import 'user_service.dart';
import 'badge_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final String baseUrl;
  late final ApiService _apiService;
  late final Auth _auth;
  late final FlightPlanService _flightPlan;
  late final EventService _event;
  late final StrengthService _strength;
  late final LinkService _link;
  late final UserService _user;
  late final BadgeService _badge;

  void initialize({required String baseUrl}) {
    this.baseUrl = baseUrl;
    _apiService = ApiService(baseUrl: baseUrl);
    _auth = Auth(baseUrl: baseUrl);
    _flightPlan = FlightPlanService(baseUrl: baseUrl);
    _event = EventService(baseUrl: baseUrl);
    _strength = StrengthService(baseUrl: baseUrl);
    _link = LinkService(baseUrl: baseUrl);
    _user = UserService(baseUrl: baseUrl);
    _badge = BadgeService(baseUrl: baseUrl);
  }

  ApiService get api => _apiService;
  Auth get auth => _auth;
  FlightPlanService get flightPlan => _flightPlan;
  EventService get event => _event;
  StrengthService get strength => _strength;
  LinkService get link => _link;
  UserService get user => _user;
  BadgeService get badge => _badge;

  void dispose() {
    _apiService.dispose();
  }
}
