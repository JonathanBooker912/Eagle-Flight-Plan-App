import 'package:eagle_flight_plan/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../services/api_session_storage.dart';
import '../widgets/event_card.dart';
import '../widgets/event_list.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_loader.dart';
import '../widgets/shimmer.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    Key? key,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late int _userId;
  late ServiceLocator _serviceLocator = ServiceLocator();
  List<Event> _events = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
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
      final response = await _serviceLocator.event.getEventsForUser(_userId);
      print('Received response: ${response} events');
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

  int _getEventCountForMonth(DateTime month) {
    return _events.where((event) {
      final eventDate = event.startTime;
      return eventDate.year == month.year && eventDate.month == month.month;
    }).length;
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
      await _serviceLocator.event.registerForEvent(_userId, event.id);
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
      await _serviceLocator.event.unregisterFromEvent(_userId, event.id);
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
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const CalendarLoader(),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorScheme.background.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        colorScheme.background.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(9),
                                      bottomLeft: Radius.circular(9),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: colorScheme.background
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colorScheme.background
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 60,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color:
                                        colorScheme.background.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TableCalendar<Event>(
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
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.secondary,
                            width: 1,
                          ),
                        ),
                        markerDecoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 6,
                        cellMargin: const EdgeInsets.all(4),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: false,
                        titleTextStyle: textTheme.titleLarge!,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurface,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface,
                        ),
                        titleTextFormatter: (date, locale) {
                          final eventCount = _getEventCountForMonth(date);
                          return '${date.year} ${_getMonthName(date.month)}';
                        },
                        leftChevronMargin: const EdgeInsets.only(left: 8),
                        rightChevronMargin: const EdgeInsets.only(right: 8),
                        leftChevronPadding: const EdgeInsets.all(8),
                        rightChevronPadding: const EdgeInsets.all(8),
                      ),
                      calendarBuilders: CalendarBuilders(
                        headerTitleBuilder: (context, date) {
                          final eventCount = _getEventCountForMonth(date);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getMonthName(date.month)} ${date.year}',
                                style: textTheme.titleLarge,
                              ),
                              Chip(
                                label: Text(
                                  '${eventCount > 0 ? eventCount : 'No'} Events',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor: colorScheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                side: BorderSide.none,
                              ),
                            ],
                          );
                        },
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
                      availableGestures: AvailableGestures.horizontalSwipe,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CalendarHeader(
                    date: _selectedDay,
                    eventCount: _eventsByDate[DateTime.utc(_selectedDay.year,
                                _selectedDay.month, _selectedDay.day)]
                            ?.length ??
                        0,
                    getMonthName: _getMonthName,
                  ),
                  Expanded(
                    child: EventList(
                      events: _eventsByDate[DateTime.utc(_selectedDay.year,
                                  _selectedDay.month, _selectedDay.day)]
                              ?.toList() ??
                          [],
                      onEventTap: _showEventDetails,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}
