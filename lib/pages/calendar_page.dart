import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../services/api_session_storage.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    Key? key,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late int _userId;
  late EventService _eventService;
  List<EventModel> _events = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<EventModel>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _eventService = EventService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _userId = (await ApiSessionStorage.getSession()).userId;
    print('CalendarPage initState - userId: ${_userId}');
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final session = await ApiSessionStorage.getSession();
      print('Current session: ${session.toJsonString()}');
      print('Using userId: ${_userId}');
      _loadEvents();
    } catch (e) {
      print('Error checking session: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Unable to load session. Please try again later.');
    }
  }

  Future<void> _loadEvents() async {
    print('Loading events for user: ${_userId}');
    try {
      final response = await _eventService.getEventsForUser(_userId);
      print('Received response: ${response.events.length} events');
      setState(() {
        _events = response.events;
        _eventsByDate = _groupEventsByDate(_events);
        _isLoading = false;
      });
      print('Events grouped by date: ${_eventsByDate.length} dates');
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Unable to load events. Please try again later.');
    }
  }

  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
    print('Grouping ${events.length} events by date');
    final Map<DateTime, List<EventModel>> eventsByDate = {};
    for (var event in events) {
      // Convert UTC to CST (GMT-6)
      final cstDate = event.date.subtract(const Duration(hours: 5));
      final date = DateTime.utc(cstDate.year, cstDate.month, cstDate.day);
      if (!eventsByDate.containsKey(date)) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]!.add(event);
      print('Event added: ${event.name} on ${date.toString()}');
    }
    return eventsByDate;
  }

  void _showError(String message) {
    print('Showing error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showEventDetails(EventModel event) {
    print('Showing details for event: ${event.name}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.location_on, event.location),
                    _buildDetailRow(
                      Icons.access_time,
                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    if (!event.isRegistered)
                      ElevatedButton(
                        onPressed: () => _registerForEvent(event),
                        child: const Text('Register for Event'),
                      )
                    else if (!event.isAttended)
                      ElevatedButton(
                        onPressed: () => _unregisterFromEvent(event),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Unregister from Event'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    // Convert UTC to CST (GMT-6)
    final cstTime = time.subtract(const Duration(hours: 6));
    return '${cstTime.hour.toString().padLeft(2, '0')}:${cstTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _registerForEvent(EventModel event) async {
    print('Registering for event: ${event.name}');
    try {
      await _eventService.registerForEvent(_userId, event.id);
      setState(() {
        _events = _events.map((e) {
          if (e.id == event.id) {
            return EventModel(
              id: e.id,
              name: e.name,
              description: e.description,
              date: e.date,
              startTime: e.startTime,
              endTime: e.endTime,
              location: e.location,
              isRegistered: true,
              isAttended: e.isAttended,
            );
          }
          return e;
        }).toList();
        _eventsByDate = _groupEventsByDate(_events);
      });
      print('Successfully registered for event');
      Navigator.pop(context);
    } catch (e) {
      print('Error registering for event: $e');
      _showError('Unable to register for event. Please try again.');
    }
  }

  Future<void> _unregisterFromEvent(EventModel event) async {
    print('Unregistering from event: ${event.name}');
    try {
      await _eventService.unregisterFromEvent(_userId, event.id);
      setState(() {
        _events = _events.map((e) {
          if (e.id == event.id) {
            return EventModel(
              id: e.id,
              name: e.name,
              description: e.description,
              date: e.date,
              startTime: e.startTime,
              endTime: e.endTime,
              location: e.location,
              isRegistered: false,
              isAttended: e.isAttended,
            );
          }
          return e;
        }).toList();
        _eventsByDate = _groupEventsByDate(_events);
      });
      print('Successfully unregistered from event');
      Navigator.pop(context);
    } catch (e) {
      print('Error unregistering from event: $e');
      _showError('Unable to unregister from event. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building calendar page - isLoading: $_isLoading, events: ${_events.length}');
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    'Calendar',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppTheme.backgroundDarken,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        print('Calendar format changed to: $format');
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        print('Day selected: $selectedDay');
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(color: Colors.white),
                        defaultTextStyle: TextStyle(color: Colors.white),
                        selectedDecoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        cellPadding: EdgeInsets.only(bottom: 8),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final eventsForDate = _eventsByDate[DateTime.utc(
                                  date.year, date.month, date.day)] ??
                              [];
                          if (eventsForDate.isEmpty) return null;
                          print(
                              'Adding marker for date: $date with ${eventsForDate.length} events');
                          return Positioned(
                            bottom: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _eventsByDate[DateTime.utc(_selectedDay.year,
                                  _selectedDay.month, _selectedDay.day)]
                              ?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final event = _eventsByDate[DateTime.utc(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day)]![index];
                        print('Building event card for: ${event.name}');
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: AppTheme.surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              event.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Icon(
                              event.isRegistered
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: event.isRegistered
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                            ),
                            onTap: () => _showEventDetails(event),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
