import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId:
        '655672457375-vissmkjabikc0nc3h7i0l31mo1ama6f4.apps.googleusercontent.com',
  );
  final _serviceLocator = ServiceLocator();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serviceLocator.initialize(
      baseUrl: 'https://flightplan.eaglesoftwareteam.com/flight-plan-t1',
    );
  }

  @override
  void dispose() {
    _serviceLocator.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Starting Google Sign-In process...');

      // First, try to sign out to clear any existing sessions
      await _googleSignIn.signOut();

      // Then sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User cancelled the sign-in process');
        return;
      }

      print('Google Sign-In successful, getting authentication...');

      // Get the authentication details
      final GoogleSignInAuthentication auth = await googleUser.authentication;
      print('Auth details:');
      print('ID Token: ${auth.idToken}');

      if (auth.idToken == null) {
        throw Exception(
          'ID token is null. Please check Google Sign-In configuration.',
        );
      }

      print('Sending to API...');
      final response = await _serviceLocator.auth.loginWithGoogle(auth);
      print('API login successful: $response');

      // Save the token
      if (response['token'] != null) {
        await AuthService.saveToken(response["token"]!);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      print('Error during sign-in: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppTheme.surfaceColor,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Career Services:',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.normal,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              'Eagle \nFlight Plan',
                              style: Theme.of(context).textTheme.displayLarge,
                              textAlign: TextAlign.left,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Image(
                                image: const AssetImage('assets/Birb.png'),
                                width: 225,
                                height: 225,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: AppTheme.surfaceColor,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Please sign in to continue",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _handleGoogleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                const Flexible(
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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



// ElevatedButton(
//                         onPressed: _handleGoogleSignIn,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.secondaryColor,
//                           foregroundColor: AppTheme.textSecondary,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset('assets/google_logo.png', height: 24),
//                             const SizedBox(width: 10),
//                             const Flexible(
//                               child: Text(
//                                 'Sign in with Google',
//                                 style: TextStyle(fontSize: 16),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),