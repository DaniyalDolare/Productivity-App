import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as t;
import 'package:timezone/timezone.dart' as tz;
import '../services/notification.dart';

class Reminder {
  String? title;
  DateTime? date;
  Reminder({
    this.title,
    this.date,
  });

  Reminder copyWith({
    String? title,
    DateTime? date,
  }) {
    return Reminder(
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date?.millisecondsSinceEpoch,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) =>
      Reminder.fromMap(json.decode(source));

  @override
  String toString() => 'Reminder(title: $title, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reminder && other.title == title && other.date == date;
  }

  @override
  int get hashCode => title.hashCode ^ date.hashCode;
}

Future<void> addReminder(Reminder reminder) async {
  var dateTime = reminder.date!;

  //initialize time zones

  t.initializeTimeZones();

  //get current local timezone name
  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

  //get timezone location
  final location = tz.getLocation(currentTimeZone);

  //TZDateTime format of DateTime
  final scheduledDate = tz.TZDateTime.from(dateTime, location);

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'com.example.productivity_app/reminder', 'reminder',
      channelDescription: 'Channel for reminder notification',
      icon: 'app_icon',
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      importance: Importance.high,
      priority: Priority.high);

  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);

  var notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  //id for each reminder should be different
  await LocalNotification.flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.date!.microsecond,
      "Todo",
      reminder.title,
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
