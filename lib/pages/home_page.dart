import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../services/api_token_service.dart';

class HomePage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  HomePage({super.key});

  Future<void> _handleSignOut() async {
    await TokenService.clearToken();
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
          print('ontoken refresh fcmTOken: ${fcmToken}');
          // TODO: If necessary send token to application server.

          // Note: This callback is fired at each app startup and whenever a new
          // token is generated.
        })
        .onError((err) {
          // Error getting token.
        });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Eagle Flight Plan'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _handleSignOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Welcome to Eagle Flight Plan',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 24),
            ),

            ElevatedButton(onPressed: getFCMToken, child: Text('Get FCM')),
          ],
        ),
      ),
    );
  }

  Future<void> getFCMToken() async {
    // TODO Move this somewhere better.
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // Send this token to your server or save it
      } else {
        print('Unable to get FCM token.');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}
