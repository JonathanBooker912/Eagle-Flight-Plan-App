import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../theme/app_theme.dart';
import '../pages/flight_plan_page.dart';
<<<<<<< HEAD
import '../pages/profile_page.dart';
import '../pages/calendar_page.dart';
=======
>>>>>>> a9b969c (Did some things)
import '../pages/check_in_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final String currentRoute;
  final bool stackNavigationBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    required this.currentRoute,
    this.stackNavigationBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar:
          stackNavigationBar ? null : NavigationBar(currentRoute: currentRoute),
      body: stackNavigationBar
          ? Stack(
              children: [
                body,
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: NavigationBar(currentRoute: currentRoute),
                ),
              ],
            )
          : body,
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

  void _navigateTo(BuildContext context, String route) {
    Widget page;
    switch (route) {
      case '/home':
        page = FlightPlanPage();
        break;
      case '/calendar':
        page = CalendarPage();
        break;
      case '/qr':
        page = const EventCheckInPage();
        break;
      case '/notifications':
        page = Center(child: Text('Notifications Page'));
        break;
      case '/profile':
        page = Center(child: Text('Profile Page'));
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
          stackNavigationBar: route == '/qr',
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: AppTheme.secondaryColor,
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _navigateTo(context, '/home'),
                icon: Icon(
                  MdiIcons.bird,
                  size: 32,
                  color: _getIconColor('/home'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/calendar'),
                icon: Icon(
                  Icons.event,
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
