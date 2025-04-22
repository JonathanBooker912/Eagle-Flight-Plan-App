import 'package:flutter/material.dart';
import '../models/flight_plan_item.dart';
import '../theme/app_theme.dart';

class FlightPlanItemCard extends StatelessWidget {
  final FlightPlanItem item;

  const FlightPlanItemCard({Key? key, required this.item}) : super(key: key);

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'complete':
        return colorScheme.primary;
      case 'incomplete':
        return colorScheme.error;
      case 'pending':
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showDetailsModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Type: ${item.flightPlanItemType}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Due Date: ${_formatDate(item.dueDate)}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Points: ${item.task?.points ?? item.experience?.points ?? 0}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(item.createdAt)}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${_formatDate(item.updatedAt)}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showDetailsModal(context),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        color: colorScheme.surface,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, item.status),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.name,
                                  style: textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.status} ${item.flightPlanItemType}',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${item.task?.points ?? item.experience?.points ?? 0} pts',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
