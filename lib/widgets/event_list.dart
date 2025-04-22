import 'package:flutter/material.dart';
import '../models/event.dart';
import 'event_card.dart';

class EventList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;

  const EventList({
    Key? key,
    required this.events,
    required this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () => onEventTap(event),
            );
          },
        ),
      ],
    );
  }
}
