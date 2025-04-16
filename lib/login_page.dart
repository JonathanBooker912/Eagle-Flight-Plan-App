import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _writeTokenToFile(String token) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/firebase_token.txt');
      await file.writeAsString(token);
      print('Token written to: ${file.path}');
    } catch (e) {
      print('Error writing token to file: $e');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      // Get the Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential from Google token
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Get the Firebase ID token (✅ this is what the backend needs)
      final String? firebaseIdToken = await userCredential.user?.getIdToken(
        true,
      );

      if (firebaseIdToken == null) return null;

      // Write the token to a file
      await _writeTokenToFile(firebaseIdToken);

      // Optionally return the Firebase user and ID token
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Eagle Flight Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final UserCredential? userCredential =
                    await _signInWithGoogle();
                if (userCredential != null) {
                  // Navigate to home page or perform other actions
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                }
              },
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
