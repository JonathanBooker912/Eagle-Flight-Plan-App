import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/service_locator.dart';
import '../widgets/event_card.dart';

class CalendarPage extends StatefulWidget {
  final bool isAdmin;

  const CalendarPage({super.key, this.isAdmin = false});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ServiceLocator _serviceLocator;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late CalendarFormat _calendarFormat;
  late List<DateTime> _selectedDates;
  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _serviceLocator = ServiceLocator();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 365));
    _lastDay = DateTime.now().add(const Duration(days: 365));
    _calendarFormat = CalendarFormat.month;
    _selectedDates = [_selectedDay];
    _events = {};
    _selectedEvents = [];
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final result = await _serviceLocator.api.getAllEvents(1, 1000);
      setState(() {
        _events = _groupEventsByDate(result.data.events);
        _selectedEvents = _getEventsForDay(_selectedDay);
      });
    } catch (error) {
      debugPrint('Failed to load events: $error');
    }
  }

  Map<DateTime, List<dynamic>> _groupEventsByDate(List<dynamic> events) {
    final Map<DateTime, List<dynamic>> groupedEvents = {};
    for (var event in events) {
      final date = DateTime.parse(event['date']).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (!groupedEvents.containsKey(dateOnly)) {
        groupedEvents[dateOnly] = [];
      }
      groupedEvents[dateOnly]!.add(event);
    }
    return groupedEvents;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Card
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDay = DateTime.now();
                                _focusedDay = DateTime.now();
                                _selectedEvents = _getEventsForDay(_selectedDay);
                              });
                            },
                            child: const Text('Today'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _calendarFormat = _calendarFormat == CalendarFormat.month
                                    ? CalendarFormat.week
                                    : CalendarFormat.month;
                              });
                            },
                            child: Text(_calendarFormat == CalendarFormat.month ? 'Week' : 'Month'),
                          ),
                        ],
                      ),
                      TableCalendar(
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        eventLoader: (day) => _getEventsForDay(day),
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                        ),
                        onDaySelected: _onDaySelected,
                        onFormatChanged: _onFormatChanged,
                        onPageChanged: _onPageChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Events List
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events for ${DateFormat('MMMM d, y').format(_selectedDay)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _selectedEvents.isEmpty
                            ? const Center(
                                child: Text('No events for this date'),
                              )
                            : ListView.builder(
                                itemCount: _selectedEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _selectedEvents[index];
                                  return EventCard(
                                    event: event,
                                    isAdmin: widget.isAdmin,
                                    onTap: () {
                                      // Handle event tap
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 