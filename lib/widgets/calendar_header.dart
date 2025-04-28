import 'package:flutter/material.dart';

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
      color: colorScheme.onSurface,
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
