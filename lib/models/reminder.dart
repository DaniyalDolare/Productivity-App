import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Reminder {
  String title;
  DateTime date;
  TimeOfDay time;

  Reminder({this.title, this.time, this.date});

  void addReminder(Reminder reminder) async {
    var scheduleNotificationDateTime = reminder.date.add(
        Duration(hours: reminder.time.hour, minutes: reminder.time.minute));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'reminder', 'reminder', 'Channel for reminder notification',
        icon: 'app_icon', largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, "Reminder",
        "Remider for working reminder", platformChannelSpecifics);
  }
}
