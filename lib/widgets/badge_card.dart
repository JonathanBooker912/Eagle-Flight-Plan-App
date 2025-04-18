import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E), // backgroundDarken
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(
                _getIconCode(badge['icon']),
                fontFamily: 'MaterialIcons',
              ),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getIconCode(String iconName) {
    switch (iconName) {
      case 'flight':
        return 0xe539; // Icons.flight
      case 'group':
        return 0xe7ef; // Icons.group
      case 'alarm':
        return 0xe855; // Icons.alarm
      default:
        return 0xe87c; // Icons.help_outline
    }
  }
} 