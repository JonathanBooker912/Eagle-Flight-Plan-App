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

  Future<EventResponse> getAllEvents({int page = 1, int pageSize = 1000}) async {
    try {
      final response = await ServiceLocator().api.get(
        '/event?page=$page&pageSize=$pageSize&sortBy=date&sortOrder=asc',
      );
      
      if (response == null) {
        return EventResponse(events: [], totalPages: 0);
      }

      final List<dynamic> eventsJson = response['events'] ?? [];
      final total = response['total'] ?? 0;
      final totalPages = (total / pageSize).ceil();
      
      return EventResponse(
        events: eventsJson.map((json) => EventModel.fromJson(json)).toList(),
        totalPages: totalPages,
      );
    } catch (e) {
      return EventResponse(events: [], totalPages: 0);
    }
  }

  Future<EventModel> getEventById(int eventId) async {
    try {
      final response = await ServiceLocator().api.get('/event/$eventId');
      return EventModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerForEvent(int eventId, int userId) async {
    try {
      await ServiceLocator().api.post(
        '/event/$eventId/register',
        {'studentIds': [userId]},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unregisterFromEvent(int eventId, int userId) async {
    try {
      await ServiceLocator().api.delete(
        '/event/$eventId/unregister?studentIds=$userId',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAttendance(int eventId, int userId) async {
    try {
      await ServiceLocator().api.post(
        '/event/$eventId/attend',
        {'studentIds': [userId]},
      );
    } catch (e) {
      rethrow;
    }
  }
} 