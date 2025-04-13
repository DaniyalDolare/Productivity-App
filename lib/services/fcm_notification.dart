import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/services/local_notification.dart';

class FCMNotificiation {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    final notificationSettings =
        await messaging.requestPermission(provisional: true);
    print(
        "notificationSettings.authorizationStatus: ${notificationSettings.authorizationStatus}");

    // final fcmToken = await FirebaseMessaging.instance.getToken();
    // print("fcmToken: $fcmToken");

    // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    //   print("fcmToken: $fcmToken");
    //   // TODO: If necessary send token to application server.

    //   // Note: This callback is fired at each app startup and whenever a new
    //   // token is generated.
    // }).onError((err) {
    //   // Error getting token.
    //   print("err: $err");
    // });

    messaging.getInitialMessage().then(
      (initialMessage) {
        print("getInitialMessage ${DateTime.now()} ${initialMessage?.toMap()}");
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("onMessageOpenedApp ${DateTime.now()} ${message.toMap()}");
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        print("onMessage ${DateTime.now()} ${message.toMap()}");
        scheduleHabitFromFCMMessage(message);
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> subsribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
    print("Subscribed to topic $topic");
  }

  static Future<void> unsubscribeToTopic() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await messaging.unsubscribeFromTopic(user.uid);
    }
  }

  static void scheduleHabitFromFCMMessage(RemoteMessage message) {
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
      final habitId = data["habitId"];
      final title = data["title"];
      final currentStreak = data["currentStreak"];
      final highestStreak = data["highestStreak"];
      final startDate = data["startDate"];
      final completedDate = data["completedDate"];
      final time = data["time"];
      Habit habit = Habit(
          id: habitId,
          title: title,
          currentStreak: currentStreak,
          highestStreak: highestStreak,
          startDate: startDate,
          time: time);
      LocalNotification.setHabitNotification(habit);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("onBackgroundMessage: ${DateTime.now()} ${message.toMap()}");
  FCMNotificiation.scheduleHabitFromFCMMessage(message);
}
