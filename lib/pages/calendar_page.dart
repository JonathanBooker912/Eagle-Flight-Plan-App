import 'package:eagle_flight_plan/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/api_session_storage.dart';
import '../widgets/event_list.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_loader.dart';
import '../widgets/event_details_modal.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    Key? key,
  }) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  late int _userId;
  final ServiceLocator _serviceLocator = ServiceLocator();
  List<Event> _events = [];
  Set<int> _registeredEventIds = {};
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> _eventsByDate = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_isDisposed) return;
    _userId = (await ApiSessionStorage.getSession()).userId;

    _checkSession();
  }

  Future<void> _checkSession() async {
    if (_isDisposed) return;
    try {
      _loadEvents();
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
        _showError('Unable to load session. Please try again later.');
      }
    }
  }

  Future<void> _loadEvents() async {
    if (_isDisposed) return;

    try {
      // Get all available events
      final allEventsResponse =
          await _serviceLocator.event.getEventsForUser(_userId);
      if (_isDisposed) return;

      // Get registered events
      final registeredEvents =
          await _serviceLocator.event.getRegisteredEvents(_userId, 0);
      if (_isDisposed) return;

      if (!_isDisposed) {
        setState(() {
          _events = allEventsResponse.events;
          _registeredEventIds = registeredEvents.map((e) => e.id).toSet();
          _eventsByDate = _groupEventsByDate(_events);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
        _showError('Unable to load events. Please try again later.');
      }
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> eventsByDate = {};
    for (var event in events) {
      // Convert UTC to CST (GMT-6)
      final cstDate = event.startTime.subtract(const Duration(hours: 5));
      final date = DateTime.utc(cstDate.year, cstDate.month, cstDate.day);
      if (!eventsByDate.containsKey(date)) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]!.add(event);
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: EventDetailsModal(
          event: event,
          checkInError: null,
          isCheckingIn: false,
          onCheckIn: () {
            Navigator.pop(context);
          },
          onRegister: () => _registerForEvent(event),
          onUnregister: () => _unregisterFromEvent(event),
          isRegistered: _registeredEventIds.contains(event.id),
          modalType: EventModalType.register,
        ),
      ),
    );
  }

  Future<void> _registerForEvent(Event event) async {
    if (_isDisposed) return;

    try {
      await _serviceLocator.event.registerForEvent(_userId, event.id);
      if (_isDisposed) return;
      // Refresh the list of registered events
      final registeredEvents =
          await _serviceLocator.event.getRegisteredEvents(_userId, 0);
      if (!_isDisposed) {
        setState(() {
          _registeredEventIds = registeredEvents.map((e) => e.id).toSet();
          _eventsByDate = _groupEventsByDate(_events);
        });
      }

      if (!_isDisposed) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Unable to register for event. Please try again.');
      }
    }
  }

  Future<void> _unregisterFromEvent(Event event) async {
    if (_isDisposed) return;

    try {
      await _serviceLocator.event.unregisterFromEvent(event.id);
      if (_isDisposed) return;
      // Refresh the list of registered events
      final registeredEvents =
          await _serviceLocator.event.getRegisteredEvents(_userId, 0);
      if (!_isDisposed) {
        setState(() {
          _registeredEventIds = registeredEvents.map((e) => e.id).toSet();
          _eventsByDate = _groupEventsByDate(_events);
        });
      }

      if (!_isDisposed) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Unable to unregister from event. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const CalendarLoader(),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.onSurface,
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
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
                          color: colorScheme.onSurface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
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
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
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
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
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
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.onSurface,
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
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      daysOfWeekHeight: 32,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: textTheme.bodyMedium!.copyWith(),
                        weekendStyle: textTheme.bodyMedium!.copyWith(),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: textTheme.bodyLarge!.copyWith(),
                        defaultTextStyle: textTheme.bodyLarge!.copyWith(),
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
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: false,
                        titleTextStyle: textTheme.titleLarge!,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: colorScheme.secondary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: colorScheme.secondary,
                        ),
                        titleTextFormatter: (date, locale) {
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
                                style: textTheme.titleMedium,
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
