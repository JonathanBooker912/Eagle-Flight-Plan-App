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