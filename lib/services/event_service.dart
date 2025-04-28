import 'api_service.dart';
import '../models/event.dart';
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
      final response = await get(
        '/event?page=$page&pageSize=$pageSize',
      );

      final List<dynamic> eventsJson = response['events'] ?? [];
      const totalPages = 1; // Since we're getting all events at once

      return EventResponse(
        events: eventsJson.map((json) => Event.fromJson(json)).toList(),
        totalPages: totalPages,
      );
    } catch (e) {
      return EventResponse(events: [], totalPages: 0);
    }
  }

  Future<void> registerForEvent(int userId, int eventId) async {
    try {
      await post(
        '/event/$eventId/register',
        {
          'studentIds': [userId]
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unregisterFromEvent(int eventId) async {
    final studentId = (await ApiSessionStorage.getSession()).studentId;
    try {
      await delete(
        '/event/$eventId/unregister',
        body: {
          'studentIds': [studentId.toString()]
        },
      );
    } catch (e) {
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
      eventData.setFulfillableItemsFromJson(
          flightPlanItems['fulfillableFlightPlanItems'] as List);
    } catch (e) {
      rethrow;
    }
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
