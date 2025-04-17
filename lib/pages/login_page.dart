import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import '../services/api_token_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _serviceLocator = ServiceLocator();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled sign-in
      }

      // Get the Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google ID Token: ${googleAuth.idToken}');
      print('Google Access Token: ${googleAuth.accessToken}');

      final response = await _serviceLocator.auth.loginWithGoogle(
        googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      print('Backend login response: ${response}');
      
      if (response['token'] == null) {
        throw Exception('No token received from backend');
      }
      
      if (response['userId'] == null) {
        throw Exception('No user ID received from backend');
      }
      
      // Save the token and user ID from our backend
      await TokenService.saveToken(response['token']);
      await TokenService.saveUserId(response['userId']);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/notifications');
      }
    } catch (e) {
      print('Error during Google sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
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
                            onPressed: _signInWithGoogle,
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
//                       ),