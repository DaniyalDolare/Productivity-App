import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/notification.dart';
import 'firebase_options.dart';
import 'screens/home_screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Settings
  await LocalNotification.initializeNotificationSettings();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Home());
}
