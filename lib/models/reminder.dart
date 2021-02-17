import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as t;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class Reminder {
  String title;
  DateTime date;
  TimeOfDay time;

  Reminder({this.title, this.time, this.date});
}

void addReminder(Reminder reminder) async {
  var dateTime = reminder.date
      .add(Duration(hours: reminder.time.hour, minutes: reminder.time.minute));

  //initialize time zones
  t.initializeTimeZones();

  //get current local timezone name
  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  print(currentTimeZone);

  //get timezone location
  final location = tz.getLocation(currentTimeZone);

  //TZDateTime format of DateTime
  final scheduledDate = tz.TZDateTime.from(dateTime, location);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminder', 'reminder', 'Channel for reminder notification',
      icon: 'app_icon', largeIcon: DrawableResourceAndroidBitmap('app_icon'));

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
      0, "Todo", reminder.title, scheduledDate, platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
