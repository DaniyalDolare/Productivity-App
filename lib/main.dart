import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/firebase_options.dart';
import 'package:productivity_app/provider/theme_provider.dart';
import 'package:productivity_app/screens/home_screen/home.dart';
import 'package:productivity_app/services/fcm_notification.dart';
import 'package:productivity_app/services/local_notification.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Initialize Notification Settings
    await LocalNotification.initializeNotificationSettings();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FCMNotificiation.initialize();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userTheme = prefs.getInt("user_theme");
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(userTheme ?? 0),
      child: const Home(),
    ),
  );
}
