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
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 365));
    _lastDay = DateTime.now().add(const Duration(days: 365));
    _events = {};
    _selectedEvents = [];
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final result = await ServiceLocator().api.getAllEvents(1, 1000);
      setState(() {
        _events = _groupEventsByDate(result['data'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar Card
            Card(
              color: Theme.of(context).cardColor,
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
                          child: const Text(
                            'Today',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    TableCalendar(
                      firstDay: _firstDay,
                      lastDay: _lastDay,
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) => _getEventsForDay(day),
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.white),
                        holidayTextStyle: const TextStyle(color: Colors.white),
                        selectedTextStyle: const TextStyle(color: Colors.black),
                        todayTextStyle: const TextStyle(color: Colors.white),
                        disabledTextStyle: const TextStyle(color: Colors.grey),
                        markerDecoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        titleTextStyle: TextStyle(color: Colors.white),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      onDaySelected: _onDaySelected,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description Block
            Expanded(
              child: Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events for ${DateFormat('MMMM d, y').format(_selectedDay)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _selectedEvents.isEmpty
                            ? const Center(
                                child: Text(
                                  'No events for this date',
                                  style: TextStyle(color: Colors.white),
                                ),
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