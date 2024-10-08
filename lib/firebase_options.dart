// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXG4J3ok1NuSxKWROTeTuAOlrQQa9cKyQ',
    appId: '1:34420096376:web:c63b3e20e1b60100bf5c8d',
    messagingSenderId: '34420096376',
    projectId: 'productivity-app-e63c8',
    authDomain: 'productivity-app-e63c8.firebaseapp.com',
    databaseURL: 'https://productivity-app-e63c8.firebaseio.com',
    storageBucket: 'productivity-app-e63c8.appspot.com',
    measurementId: 'G-29SB6C7JWV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAI4PvDgMumQ5dRjCWtJWziLMEwdm9r6fo',
    appId: '1:34420096376:android:219e0027736c9ac0bf5c8d',
    messagingSenderId: '34420096376',
    projectId: 'productivity-app-e63c8',
    databaseURL: 'https://productivity-app-e63c8.firebaseio.com',
    storageBucket: 'productivity-app-e63c8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDWaAhYmLfdefG3xN1d6uM53TW2NWwr75o',
    appId: '1:34420096376:ios:afc5dd5db9f40568bf5c8d',
    messagingSenderId: '34420096376',
    projectId: 'productivity-app-e63c8',
    databaseURL: 'https://productivity-app-e63c8.firebaseio.com',
    storageBucket: 'productivity-app-e63c8.appspot.com',
    androidClientId: '34420096376-0p3cnhjaknbfjsq7odicrd0gc9jka060.apps.googleusercontent.com',
    iosClientId: '34420096376-rtb1dnareopcpe2a8v7ij4goetglas7k.apps.googleusercontent.com',
    iosBundleId: 'com.example.productivityApp',
  );

}