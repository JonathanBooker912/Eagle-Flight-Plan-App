import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/notification_page.dart';
import '../services/api_token_service.dart';
import '../pages/flight_plan_page.dart';
import '../pages/profile_page.dart';
import '../pages/calendar_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final String currentRoute;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: NavigationBar(currentRoute: currentRoute),
      body: body,
    );
  }
}

class NavigationBar extends StatelessWidget {
  final String currentRoute;

  const NavigationBar({super.key, required this.currentRoute});

  Color _getIconColor(String route) {
    return currentRoute == route
        ? AppTheme.primaryColor
        : AppTheme.backgroundColor;
  }

  Future<Map<String, dynamic>> _getAuthData() async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    // TODO: Get user ID from your user service or shared preferences
    return {
      'token': token,
      'userId': 1, // Replace with actual user ID
    };
  }

  void _navigateTo(BuildContext context, String route) async {
    Widget page;
    switch (route) {
      case '/home':
        page = FlightPlanPage();
        break;
      case '/calendar':
        try {
          final authData = await _getAuthData();
          page = CalendarPage(
            userId: authData['userId'],
          );
        } catch (e) {
          print('Error navigating to calendar: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please log in to view calendar'),
              action: SnackBarAction(
                label: 'Login',
                onPressed: () {
                  // TODO: Navigate to login page
                },
              ),
            ),
          );
          return;
        }
        break;
      case '/qr':
        page = Center(child: Text('QR Code Page'));
        break;
      case '/notifications':
        try {
          final authData = await _getAuthData();
          page = NotificationPage(
            userId: authData['userId'],
          );
        } catch (e) {
          print('Error navigating to notifications: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please log in to view notifications'),
              action: SnackBarAction(
                label: 'Login',
                onPressed: () {
                  // TODO: Navigate to login page
                },
              ),
            ),
          );
          return;
        }
        break;
      case '/profile':
        page = ProfilePage();
        break;
      default:
        page = FlightPlanPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppScaffold(
          title: route.substring(1).toUpperCase(),
          body: page,
          currentRoute: route,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: AppTheme.secondaryColor,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _navigateTo(context, '/home'),
                icon: Icon(
                  Icons.flight,
                  size: 32,
                  color: _getIconColor('/home'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/calendar'),
                icon: Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: _getIconColor('/calendar'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/qr'),
                icon: Icon(
                  Icons.qr_code_2,
                  size: 32,
                  color: _getIconColor('/qr'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/notifications'),
                icon: Icon(
                  Icons.notifications,
                  size: 32,
                  color: _getIconColor('/notifications'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/profile'),
                icon: Icon(
                  Icons.person,
                  size: 32,
                  color: _getIconColor('/profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
