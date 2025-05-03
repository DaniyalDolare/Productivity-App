import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/dismissed_habit.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/models/history.dart';
import 'package:productivity_app/models/note.dart';
import 'package:productivity_app/models/scheduled_habit.dart';
import 'package:productivity_app/models/todo.dart';
import 'package:productivity_app/utils/extensions.dart';

class DatabaseService {
  DatabaseService._();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> saveNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    var docReference =
        firestore.collection(user.uid).doc('data').collection('notes').doc();
    await docReference.set(note.toMap()
      ..remove("id")
      ..addAll({"time": Timestamp.fromDate(note.time ?? DateTime.now())}));
    return docReference.id;
  }

  static Stream<List<Note>> getNotes() {
    final User user = FirebaseAuth.instance.currentUser!;
    return firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .orderBy('isPinned', descending: true)
        .orderBy('time', descending: true)
        .snapshots()
        .map<List<Note>>((event) => event.docs.map((e) {
              final data = e.data();
              data.update("time", (value) {
                if (value is Timestamp) {
                  return value.toDate();
                } else {
                  return DateTime.parse(value);
                }
              });
              return Note.fromMap(data..addAll({"id": e.id}));
            }).toList());
  }

  static Future<void> updateNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .doc(note.id)
        .update(note.toMap()
          ..remove("id")
          ..addAll({"time": Timestamp.fromDate(note.time ?? DateTime.now())}))
        .catchError((error) => debugPrint('this is the error: $error'));
  }

  static Future<bool> deleteNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .doc(note.id)
        .delete();
    return true;
  }

  static Future<String> saveTodo(Todo todo) async {
    // Avoid use await while saving due to offline persistance
    final User user = FirebaseAuth.instance.currentUser!;
    var id = firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .add(todo.toMap()
          ..remove("id")
          ..addAll({"time": Timestamp.fromDate(todo.time ?? DateTime.now())}));
    return id.then((value) => value.id);
  }

  static Future<void> updateTodo(Todo todo) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap()
          ..remove("id")
          ..addAll({"time": Timestamp.fromDate(todo.time ?? DateTime.now())}))
        .catchError((error) => debugPrint('this is the error: $error'));
  }

  static Future<void> deleteTodo(Todo todo) async {
    final User user = FirebaseAuth.instance.currentUser!;
    firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .doc(todo.id)
        .delete()
        .catchError((error) => debugPrint('this is the error: $error'));
  }

  static Stream<List<Todo>> getTodos() {
    final User user = FirebaseAuth.instance.currentUser!;
    return firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .orderBy('isChecked')
        .orderBy('time', descending: true)
        .snapshots()
        .map<List<Todo>>((event) => event.docs.map((e) {
              final data = e.data();
              data.update("time", (value) {
                if (value is Timestamp) {
                  return value.toDate();
                } else {
                  return DateTime.parse(value);
                }
              });
              return Todo.fromMap(data..addAll({"id": e.id}));
            }).toList());
  }

  static Future<String> saveHabit(Habit habit) async {
    final User user = FirebaseAuth.instance.currentUser!;
    var docReference =
        firestore.collection(user.uid).doc('data').collection('habits').doc();
    await docReference.set(habit.toMap()
      ..remove("id")
      ..remove("history"));

    String timeSlot = DatabaseService.getTimeSlot(habit);

    var scheduledHabitDocReference = firestore
        .collection("scheduledHabits")
        .doc(timeSlot)
        .collection("scheduledHabits")
        .doc("${user.uid}-${docReference.id}");
    await scheduledHabitDocReference.set(ScheduledHabit(
            userId: user.uid,
            habitId: docReference.id,
            title: habit.title,
            currentStreak: habit.currentStreak,
            highestStreak: habit.highestStreak,
            startDate: habit.startDate,
            time: habit.time)
        .toMap()
      ..remove("id"));
    return docReference.id;
  }

  static Future<void> updateHabit(Habit habit, String oldTimeSlot) async {
    final User user = FirebaseAuth.instance.currentUser!;
    var docReference = firestore
        .collection(user.uid)
        .doc('data')
        .collection('habits')
        .doc(habit.id);
    await docReference.update(habit.toMap()
      ..remove("id")
      ..remove("history"));

    await firestore
        .collection("scheduledHabits")
        .doc(oldTimeSlot)
        .collection("scheduledHabits")
        .doc("${user.uid}-${habit.id}")
        .delete();

    String timeSlot = DatabaseService.getTimeSlot(habit);

    var scheduledHabitDocReference = firestore
        .collection("scheduledHabits")
        .doc(timeSlot)
        .collection("scheduledHabits")
        .doc("${user.uid}-${docReference.id}");
    await scheduledHabitDocReference.set(ScheduledHabit(
            userId: user.uid,
            habitId: habit.id,
            title: habit.title,
            currentStreak: habit.currentStreak,
            highestStreak: habit.highestStreak,
            startDate: habit.startDate,
            time: habit.time)
        .toMap()
      ..remove("id"));
  }

  static Stream<List<Habit>> getHabits() {
    final User user = FirebaseAuth.instance.currentUser!;
    final habitsColectionRef =
        firestore.collection(user.uid).doc('data').collection('habits');
    return habitsColectionRef
        .snapshots(includeMetadataChanges: true)
        .asyncMap<List<Habit>>((event) async {
      List<Habit> habits = [];

      // Fetch the latest history for each habit
      for (var e in event.docs) {
        final data = e.data();
        final history = data["lastHistory"] != null
            ? History.fromMap(data["lastHistory"])
            : null;

        if (history != null) {
          final isBeforeOneDay = history.date!.toDateOnly().isBefore(
              DateTime.now().subtract(const Duration(days: 1)).toDateOnly());
          // If last history was before one day, set currentStreak to 0
          if (isBeforeOneDay && data["currentStreak"] != 0) {
            habitsColectionRef.doc(e.id).update({"currentStreak": 0});
            data.update("currentStreak", (value) => 0);
          }
        }

        final habit = Habit.fromMap(data)..id = e.id;
        habits.add(habit);
      }
      return habits;
    });
  }

  static Future<List<History>> getHabitHistory(Habit habit) async {
    final User user = FirebaseAuth.instance.currentUser!;
    final habitsColectionRef =
        firestore.collection(user.uid).doc('data').collection('habits');
    final historyQuerySnapshot = await habitsColectionRef
        .doc(habit.id)
        .collection("history")
        .orderBy("date", descending: true)
        .get();
    return historyQuerySnapshot.docs.map(
      (history) {
        return History.fromMap(history.data());
      },
    ).toList();
  }

  static Future<void> addHabitHistory(Habit habit, String? note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    final habitReference = firestore
        .collection(user.uid)
        .doc('data')
        .collection('habits')
        .doc(habit.id);

    int currentStreak = habit.currentStreak!,
        highestStreak = habit.highestStreak!;
    final today = DateTime.now();
    final previousDay = habit.lastHistory?.date;

    if (previousDay == null) {
      currentStreak = 1;
      highestStreak = max(currentStreak, highestStreak);
    } else if (previousDay.add(const Duration(days: 1)).day == today.day &&
        previousDay.add(const Duration(days: 1)).month == today.month &&
        previousDay.add(const Duration(days: 1)).year == today.year) {
      highestStreak = highestStreak + (currentStreak == highestStreak ? 1 : 0);
      currentStreak++;
    } else {
      currentStreak = 1;
      highestStreak = max(currentStreak, highestStreak);
    }

    // Add habit history and update the currentStreak, highestStreak and lastHistory
    final latestHistoryRef = habitReference.collection("history").doc();
    latestHistoryRef.set({"date": Timestamp.fromDate(today), "note": note});
    habitReference.update({
      "currentStreak": currentStreak,
      "highestStreak": highestStreak,
      "lastHistory": {
        "id": latestHistoryRef.id,
        "date": Timestamp.fromDate(today),
        "note": note
      }
    });

    // Update the completed date property of scheduledHabit
    String timeSlot = DatabaseService.getTimeSlot(habit);
    firestore
        .collection("scheduledHabits")
        .doc(timeSlot)
        .collection('scheduledHabits')
        .doc("${user.uid}-${habit.id}")
        .update({"completedDate": Timestamp.fromDate(today)});
  }

  static Future<void> addDismissedHabit(DismissedHabit dismissedHabit) {
    final User user = FirebaseAuth.instance.currentUser!;
    return firestore
        .collection(user.uid)
        .doc('data')
        .collection('dismissedHabits')
        .doc(dismissedHabit.id)
        .set({"date": Timestamp.fromDate(dismissedHabit.date!)});
  }

  static Future<List<DismissedHabit>> getDismissedHabits() {
    final User user = FirebaseAuth.instance.currentUser!;
    return firestore
        .collection(user.uid)
        .doc('data')
        .collection('dismissedHabits')
        .get()
        .then(
      (querySnapshot) {
        return querySnapshot.docs.map(
          (queryDocumentSnapshot) {
            final data = queryDocumentSnapshot.data();
            return DismissedHabit.fromMap(data)..id = queryDocumentSnapshot.id;
          },
        ).toList();
      },
    );
  }

  /// Get UTC time slot for habit scheduling
  static String getTimeSlot(Habit habit) {
    DateTime timeslotDateTime = habit.startDate!.toDateOnly();
    if (habit.time != null) {
      timeslotDateTime = timeslotDateTime
          .add(Duration(hours: habit.time!.hour, minutes: habit.time!.minute));
    }
    timeslotDateTime = timeslotDateTime.toUtc();
    String hour = timeslotDateTime.hour.toString();
    String minute = timeslotDateTime.minute < 10
        ? (timeslotDateTime.minute ~/ 5).toString()
        : timeslotDateTime.minute % 10 < 5
            ? "${timeslotDateTime.minute ~/ 10}0"
            : "${timeslotDateTime.minute ~/ 10}5";
    return "$hour:$minute";
  }

  static Future<void> deleteHabit(Habit habit) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection("scheduledHabits")
        .doc(getTimeSlot(habit))
        .collection("scheduledHabits")
        .doc("${user.uid}-${habit.id}")
        .delete();
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('dismissedHabits')
        .doc(habit.id)
        .delete();
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('habits')
        .doc(habit.id)
        .delete();
  }
}
