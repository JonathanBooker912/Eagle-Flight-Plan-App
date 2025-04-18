# Eagle Flight Plan App

A mobile app version of Career Service's Eagle Flight Plan system to provide students with a limited functionality or "view only" set of services.

## Setup Instructions

1. Clone the repository
2. Make sure you have been added to the firebase project
3. Run `flutter pub get` to install dependencies
4. Add the google-services.json from the [Firebase Console](https://console.firebase.google.com/u/1/project/eagleflightplanapp/settings/general/android:com.example.eagle_flight_plan_app) under /android/app
5. Add your SHA-1 fingerprint to the Firebase console:

#### For Windows:

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### For macOS/Linux:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

5. Run the app with `flutter run`

## Flutter Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
