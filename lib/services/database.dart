import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/models/note.dart';
import 'package:productivity_app/models/todo.dart';

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
    Timestamp? startDate = Timestamp.fromDate(habit.startDate!);
    Timestamp? endDate =
        habit.endDate != null ? Timestamp.fromDate(habit.endDate!) : null;
    docReference.set(
      habit.toMap()
        ..remove("id")
        ..remove("history")
        ..addAll(
          {
            "startDate": startDate,
            "endDate": endDate,
          },
        ),
    );
    return docReference.id;
  }

  static Stream<List<Habit>> getHabits() {
    final User user = FirebaseAuth.instance.currentUser!;
    return firestore
        .collection(user.uid)
        .doc('data')
        .collection('habits')
        .snapshots()
        .map<List<Habit>>((event) => event.docs.map((e) {
              final data = e.data();
              data.update("startDate", (value) => value?.toDate());
              data.update("endDate", (value) => value?.toDate());

              final Map<String, dynamic>? lastHistory =
                  data["lastCompletionHistory"];
              if (lastHistory != null) {
                lastHistory.update("time", (value) => value?.toDate());
                data["lastCompletionHistory"] = History.fromMap(lastHistory);
              }
              return Habit.fromMap(data..addAll({"id": e.id}));
            }).toList());
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
    final previousDay = habit.lastCompletionHistory?.time;

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

    final latestHistoryRef = habitReference.collection("history").doc();
    await latestHistoryRef
        .set({"time": Timestamp.fromDate(DateTime.now()), "note": note});
    await latestHistoryRef.get().then((value) async {
      final historyData = value.data()?..addAll({"id": latestHistoryRef.id});
      await habitReference.update({
        "lastCompletionHistory": historyData,
        "currentStreak": currentStreak,
        "highestStreak": highestStreak
      });
    });
  }
}
