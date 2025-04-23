import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarLoader extends StatefulWidget {
  const CalendarLoader({Key? key}) : super(key: key);

  @override
  State<CalendarLoader> createState() => _CalendarLoaderState();
}

class _CalendarLoaderState extends State<CalendarLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.background
                            .withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.background
                            .withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 33, // 6 rows * 7 days
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.background
                            .withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
