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
  List<Event> _events = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _eventService = EventService(
        baseUrl:
            'https://api.example.com'); // Replace with your actual API base URL
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

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    print('Grouping ${events.length} events by date');
    final Map<DateTime, List<Event>> eventsByDate = {};
    for (var event in events) {
      // Convert UTC to CST (GMT-6)
      final cstDate = event.startTime.subtract(const Duration(hours: 5));
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

  void _showEventDetails(Event event) {
    print('Showing details for event: ${event.name}');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
                    style: textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurface),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Divider(color: colorScheme.outline),
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
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _registerForEvent(event),
                      child: const Text('Register for Event'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Text(
            text,
            style: textTheme.bodyLarge,
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

  Future<void> _registerForEvent(Event event) async {
    print('Registering for event: ${event.name}');
    try {
      await _eventService.registerForEvent(_userId, event.id);
      setState(() {
        _events = _events.map((e) {
          if (e.id == event.id) {
            return Event(
              id: e.id,
              name: e.name,
              description: e.description,
              startTime: e.startTime,
              endTime: e.endTime,
              location: e.location,
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

  Future<void> _unregisterFromEvent(Event event) async {
    print('Unregistering from event: ${event.name}');
    try {
      await _eventService.unregisterFromEvent(_userId, event.id);
      setState(() {
        _events = _events.map((e) {
          if (e.id == event.id) {
            return Event(
              id: e.id,
              name: e.name,
              description: e.description,
              startTime: e.startTime,
              endTime: e.endTime,
              location: e.location,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    'Calendar',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TableCalendar<EventModel>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      eventLoader: (day) => _eventsByDate[day] ?? [],
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        defaultTextStyle: textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        cellMargin: const EdgeInsets.all(4),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: textTheme.titleLarge!,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurface,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
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
                            trailing: const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
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
