import 'api_service.dart';
import '../models/flight_plan.dart';
import '../services/api_session_storage.dart';

class FlightPlanService extends ApiService {
  FlightPlanService({required super.baseUrl});

  Future<List<FlightPlan>> getFlightPlans() async {
    final session = await ApiSessionStorage.getSession();
    final response = await get('/flightPlan/student/${session.studentId}');
    final List<dynamic> data = response['data'];
    return data.map((json) => FlightPlan.fromJson(json)).toList();
  }
}
