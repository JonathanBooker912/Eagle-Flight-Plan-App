import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime date;
  final int eventCount;
  final String Function(int) getMonthName;

  const CalendarHeader({
    Key? key,
    required this.date,
    required this.eventCount,
    required this.getMonthName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
            Text(
              'Events',
              style: textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
