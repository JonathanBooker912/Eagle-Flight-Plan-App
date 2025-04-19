<<<<<<< HEAD
import 'dart:convert';
import '../models/event.dart';
import 'service_locator.dart';

class EventResponse {
  final List<EventModel> events;
  final int totalPages;

  EventResponse({
    required this.events,
    required this.totalPages,
  });
}

class EventService {
  EventService();

  Future<EventResponse> getEventsForUser(int userId, {int page = 1, int pageSize = 1000}) async {
    try {
      print('Making API call to get events');
      final response = await ServiceLocator().api.get(
        '/event?page=$page&pageSize=$pageSize',
      );
      
      print('Raw API response: $response');
      
      if (response == null) {
        print('API response is null');
        return EventResponse(events: [], totalPages: 0);
      }

      final List<dynamic> eventsJson = response['events'] ?? [];
      final total = eventsJson.length;
      final totalPages = 1; // Since we're getting all events at once
      
      print('Parsed events: ${eventsJson.length}, total: $total, totalPages: $totalPages');
      
      return EventResponse(
        events: eventsJson.map((json) => EventModel.fromJson(json)).toList(),
        totalPages: totalPages,
      );
    } catch (e) {
      print('Error in getEventsForUser: $e');
      return EventResponse(events: [], totalPages: 0);
    }
  }

  Future<void> registerForEvent(int userId, int eventId) async {
    try {
      print('Registering user $userId for event $eventId');
      await ServiceLocator().api.post(
        '/event/$eventId/register',
        {'studentIds': [userId]},
      );
      print('Registration successful');
    } catch (e) {
      print('Error registering for event: $e');
      rethrow;
    }
  }

  Future<void> unregisterFromEvent(int userId, int eventId) async {
    try {
      print('Unregistering user $userId from event $eventId');
      await ServiceLocator().api.delete(
        '/event/$eventId/unregister?studentIds=$userId',
      );
      print('Unregistration successful');
    } catch (e) {
      print('Error unregistering from event: $e');
      rethrow;
    }
  }
} 
=======
import 'api_service.dart';
import '../models/event.dart';
import '../services/api_session_storage.dart';

class EventService extends ApiService {
  EventService({required super.baseUrl});

  Future<Event> lookupEvent(String checkInCode) async {
    final response = await get('/event/token/$checkInCode');
    return Event.fromJson(response);
  }

  Future<void> checkIn(int eventId, String checkInCode) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    final response = await post(
        '/event/$eventId/check-in/$studentId', {"token": checkInCode});

    if (response['error'] != null) {
      if (response['error']
          .toString()
          .toLowerCase()
          .contains('already checked in')) {
        throw Exception('You have already checked in to this event');
      }
      throw Exception(response['error']);
    }
  }
}
>>>>>>> a9b969c (Did some things)
