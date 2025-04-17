import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/home_page.dart';
import '../screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      body: Padding(padding: EdgeInsets.all(24), child: body),
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
        page = HomePage();
        break;
      case '/events':
        page = Center(child: Text('Events Page'));
        break;
      case '/qr':
        page = Center(child: Text('QR Code Page'));
        break;
      case '/notifications':
        page = NotificationsScreen(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        );
        break;
      case '/profile':
        page = Center(child: Text('Profile Page'));
        break;
      default:
        page = HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => AppScaffold(
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
                  Icons.flight,
                  size: 32,
                  color: _getIconColor('/home'),
                ),
              ),
              IconButton(
                onPressed: () => _navigateTo(context, '/events'),
                icon: Icon(
                  Icons.event,
                  size: 32,
                  color: _getIconColor('/events'),
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
