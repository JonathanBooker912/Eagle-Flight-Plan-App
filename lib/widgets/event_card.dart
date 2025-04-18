import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final dynamic event;
  final bool isAdmin;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(event['startTime']).toLocal();
    final endTime = DateTime.parse(event['endTime']).toLocal();
    final dateFormat = DateFormat('h:mm a');
    final timeRange = '${dateFormat.format(startTime)} - ${dateFormat.format(endTime)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAdmin)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          onPressed: () {
                            // Handle QR code generation
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.people, color: Colors.white),
                          onPressed: () {
                            // Handle attendance
                          },
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                timeRange,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (event['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  event['description'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isAdmin)
                    ElevatedButton(
                      onPressed: () {
                        // Handle registration
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Register'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 