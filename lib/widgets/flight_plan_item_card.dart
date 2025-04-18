import 'package:flutter/material.dart';
import '../models/flight_plan_item.dart';
import '../theme/app_theme.dart';

class FlightPlanItemCard extends StatelessWidget {
  final FlightPlanItem item;

  const FlightPlanItemCard({Key? key, required this.item}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return AppTheme.primaryColor;
      case 'incomplete':
        return AppTheme.errorColor;
      case 'pending':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Type: ${item.flightPlanItemType}',
                  style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Due Date: ${_formatDate(item.dueDate)}',
                  style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Points: ${item.task?.points ?? item.experience?.points ?? 0}',
                  style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(item.createdAt)}',
                  style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: ${_formatDate(item.updatedAt)}',
                  style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsModal(context),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        color: AppTheme.surfaceColor,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status),
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.status} ${item.flightPlanItemType}',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${item.task?.points ?? item.experience?.points ?? 0} pts',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
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
