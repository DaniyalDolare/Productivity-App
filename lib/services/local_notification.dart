import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:productivity_app/firebase_options.dart';
import 'package:productivity_app/models/dismissed_habit.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/utils/extensions.dart';
import 'package:timezone/data/latest.dart' as t;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _reminderNotificationChannelId =
      "com.daniyal.productivity_app/reminder";
  static const String _reminderNotificationChannelName = "Reminder";
  static const String _reminderNotificationChannelDescription = "Reminder";
  static const String _habitNotificationChannelId =
      "com.daniyal.productivity_app/habit";
  static const String _habitNotificationChannelName = "Habit";
  static const String _habitNotificationChannelDescription = "Habit";

  static Future<void> initializeNotificationSettings() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    final isInitialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveNotificationResponse);
    debugPrint("isInitialized: $isInitialized");

    // Ask for permission on Android 13 and above
    final androidPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    debugPrint("Android permission granted: $androidPermission");

    final androidExactAlarmPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    debugPrint(
        "Android Exact Alarm permission granted: $androidExactAlarmPermission");

    // Ask for permission on iOS
    final bool? iOSPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    debugPrint("iOS permission granted: $iOSPermission");

    await createNotificationChannel();
  }

  static Future<void> createNotificationChannel() async {
    // Create Android Notification Channel
    const reminderNotificationChannel = AndroidNotificationChannel(
        _reminderNotificationChannelId, _reminderNotificationChannelName,
        description: _reminderNotificationChannelDescription,
        playSound: true,
        showBadge: true,
        enableLights: true,
        enableVibration: true,
        importance: Importance.max);

    const habitNotificationChannel = AndroidNotificationChannel(
        _habitNotificationChannelId, _habitNotificationChannelName,
        description: _habitNotificationChannelDescription,
        playSound: true,
        showBadge: true,
        enableLights: true,
        enableVibration: true,
        importance: Importance.max);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderNotificationChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(habitNotificationChannel);
  }

  static Future<void> setHabitNotification(Habit habit,
      {bool scheduleOnly = false}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            _habitNotificationChannelId, _habitNotificationChannelName,
            channelDescription: _habitNotificationChannelDescription,
            actions: [
              AndroidNotificationAction(
                "0",
                "Done",
                showsUserInterface: false,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                "1",
                "Dismiss",
                showsUserInterface: false,
                cancelNotification: true,
              )
            ],
            importance: Importance.max,
            priority: Priority.max,
            autoCancel: false,
            ongoing: true);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    t.initializeTimeZones();

    //get current local timezone name
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    //get timezone location
    final location = tz.getLocation(currentTimeZone);

    var date = habit.startDate!.toDateOnly();
    var now = DateTime.now();

    // If start date is same or before and time is same or before, show notification directly
    if (!scheduleOnly &&
        !date.isAfter(now) &&
        ((habit.time == null) ||
            (habit.time != null &&
                !habit.time!
                    .isAfter(TimeOfDay(hour: now.hour, minute: now.minute))))) {
      await flutterLocalNotificationsPlugin.show(
          habit.id.hashCode, "Habit", habit.title, notificationDetails,
          payload: habit.notificationPayload());
    }
    if (habit.time != null) {
      date = date
          .add(Duration(hours: habit.time!.hour, minutes: habit.time!.minute));
    }

    //TZDateTime format of DateTime
    final scheduledDate = tz.TZDateTime.from(date, location);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      habit.id.hashCode,
      "Habit",
      habit.title,
      scheduledDate,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      notificationDetails,
      payload: habit.notificationPayload(),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static void reschedulePendingNotifications() {
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((notifications) {
      for (var notification in notifications) {
        if (notification.payload != null) {
          setHabitNotification(Habit.fromJson(notification.payload!)).then(
              (onValue) => debugPrint(
                  "Notification rescheduled ${notification.id},${notification.title}"));
        }
      }
    });
  }

  static Future<void> rescheduleHabitNotifications(
      Stream<List<Habit>> habitsStream) async {
    await Future.wait([
      LocalNotification.flutterLocalNotificationsPlugin
          .getActiveNotifications(),
      habitsStream.first,
      DatabaseService.getDismissedHabits()
    ]).then((result) {
      final List<ActiveNotification> activeNotifications =
          result[0] as List<ActiveNotification>;
      final List<Habit> habits = result[1] as List<Habit>;
      final List<DismissedHabit> dismissedHabits =
          result[2] as List<DismissedHabit>;
      final activeNotificationIds =
          activeNotifications.map((notification) => notification.id!).toSet();
      final dismissedHabitsIds = dismissedHabits
          .where((dismissedHabit) => dismissedHabit.date!
              .toDateOnly()
              .isAtSameMomentAs(DateTime.now().toDateOnly()))
          .map((dismissedHabit) => dismissedHabit.id!)
          .toSet();
      for (var habit in habits) {
        final isNotActive = !activeNotificationIds.contains(habit.id.hashCode);
        final isNotDismissed = !dismissedHabitsIds.contains(habit.id);
        final isStartingFromToday = habit.completedDate == null &&
            habit.startDate!
                .toDateOnly()
                .isAtSameMomentAs(DateTime.now().toDateOnly());
        final isNotCompletedForToday = habit.completedDate != null
            ? !habit.completedDate!
                .toDateOnly()
                .isAtSameMomentAs(DateTime.now().toDateOnly())
            : true;
        if (isNotActive &&
            isNotDismissed &&
            (isStartingFromToday || isNotCompletedForToday)) {
          setHabitNotification(habit);
        } else if (!isNotCompletedForToday &&
            activeNotificationIds.contains(habit.id.hashCode)) {
          flutterLocalNotificationsPlugin.cancel(habit.id.hashCode);
          setHabitNotification(habit, scheduleOnly: true);
        }
      }
    });
  }
}

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("onDidReceiveNotificationResponse");
  switch (notificationResponse.notificationResponseType) {
    case NotificationResponseType.selectedNotificationAction:
      var payload = notificationResponse.payload;
      if (payload != null) {
        final habit = Habit.fromJson(payload);
        if (notificationResponse.actionId == "0") {
          debugPrint(payload);
          await LocalNotification.flutterLocalNotificationsPlugin
              .cancel(habit.id!.hashCode);
          await LocalNotification.setHabitNotification(habit,
              scheduleOnly: true);
          DatabaseService.addHabitHistory(habit, null);
        } else if (notificationResponse.actionId == "1") {
          DatabaseService.addDismissedHabit(
                  DismissedHabit(id: habit.id!, date: DateTime.now()))
              .then(
            (value) {
              debugPrint("Habit dismissed");
            },
          );
        }
      }

      break;
    default:
      debugPrint("notification tap");
  }
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
}
