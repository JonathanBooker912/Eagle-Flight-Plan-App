import 'api_service.dart';
import '../models/event.dart';
import '../models/flight_plan_item.dart';
import '../services/api_session_storage.dart';

class EventResponse {
  final List<Event> events;
  final int totalPages;

  EventResponse({
    required this.events,
    required this.totalPages,
  });
}

class EventService extends ApiService {
  EventService({required super.baseUrl});

  Future<EventResponse> getEventsForUser(int userId,
      {int page = 1, int pageSize = 1000}) async {
    try {
      print('Making API call to get events');
      final response = await get(
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

      print(
          'Parsed events: ${eventsJson.length}, total: $total, totalPages: $totalPages');

      return EventResponse(
        events: eventsJson.map((json) => Event.fromJson(json)).toList(),
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
      await post(
        '/event/$eventId/register',
        {
          'studentIds': [userId]
        },
      );
      print('Registration successful');
    } catch (e) {
      print('Error registering for event: $e');
      rethrow;
    }
  }

  Future<void> unregisterFromEvent(int eventId) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    try {
      print('Unregistering student $studentId from event $eventId');
      await delete(
        '/event/$eventId/unregister',
        body: {
          'studentIds': [studentId.toString()]
        },
      );
      print('Unregistration successful');
    } catch (e) {
      print('Error unregistering from event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getRegisteredEvents(int userId, int eventId) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    final response = await get(
      '/event/student/$studentId/registered-events',
    );
    final List<dynamic> data = response['data'];
    return data.map((json) => Event.fromJson(json)).toList();
  }

  Future<Event> lookupEvent(String checkInCode) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    final response = await get('/event/token/$checkInCode');
    final eventData = Event.fromJson(response);
    try {
      final flightPlanItems = await get(
          '/event/${eventData.id}/fulfillableFlightPlanItems/$studentId');
      print(flightPlanItems);
      eventData.setFulfillableItemsFromJson(
          flightPlanItems['fulfillableFlightPlanItems'] as List);
    } catch (e) {
      print(e);
    }
    print(eventData.fulfillableItems);
    return eventData;
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
