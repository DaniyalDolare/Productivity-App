import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/local_notification.dart';
import 'package:productivity_app/utils/extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:productivity_app/firebase_options.dart';

class FCMNotificiation {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await messaging.requestPermission(provisional: true);

    messaging.getInitialMessage().then(
          (initialMessage) {},
        );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {},
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        scheduleHabitFromFCMMessage(message);
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> subsribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeToTopic() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await messaging.unsubscribeFromTopic(user.uid);
    }
  }

  static Future<void> scheduleHabitFromFCMMessage(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      final data = jsonDecode(
        message.data["data"],
        reviver: (key, value) {
          if (value == null) {
            return value;
          }
          if (key == "startDate" || key == "completedDate") {
            final timestamp = value as Map<String, dynamic>;
            return Timestamp(timestamp["_seconds"], timestamp["_nanoseconds"])
                .toDate();
          } else if (key == "time") {
            final [hour, minute] = value.toString().split(":");
            return TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
          }
          return value;
        },
      );
      final String habitId = data["habitId"];
      final String title = data["title"];
      final int currentStreak = data["currentStreak"];
      final int highestStreak = data["highestStreak"];
      final DateTime startDate = data["startDate"];
      final DateTime? completedDate = data["completedDate"];
      final TimeOfDay time = data["time"];

      final activeNotifications = await LocalNotification
          .flutterLocalNotificationsPlugin
          .getActiveNotifications();
      bool isActive = false;
      for (var activeNotification in activeNotifications) {
        if (activeNotification.id == habitId.hashCode) {
          isActive = true; // Notification is already active
          break;
        }
      }

      Habit habit = Habit(
          id: habitId,
          title: title,
          currentStreak: currentStreak,
          highestStreak: highestStreak,
          startDate: startDate,
          time: time);

      // Show/schedule notification if not completed today
      if (!isActive &&
          (completedDate == null ||
              !completedDate
                  .toDateOnly()
                  .isAtSameMomentAs(DateTime.now().toDateOnly()))) {
        await LocalNotification.setHabitNotification(habit);
      }
    }
    // Reschedule habit notifications which might have been missed/dismissed by system
    await LocalNotification.rescheduleHabitNotifications(
        DatabaseService.getHabits());
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FCMNotificiation.scheduleHabitFromFCMMessage(message);
}
