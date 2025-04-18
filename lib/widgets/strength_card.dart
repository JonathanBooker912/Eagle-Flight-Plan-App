import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StrengthCard extends StatelessWidget {
  final Map<String, dynamic> strength;

  const StrengthCard({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E), // backgroundDarken
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strength['name'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strength['description'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 