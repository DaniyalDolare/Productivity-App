import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/note.dart';
import 'package:productivity_app/models/todo.dart';

class DatabaseService {
  DatabaseService._();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> saveNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    var docReference =
        firestore.collection(user.uid).doc('data').collection('notes').doc();
    docReference.set(note.toMap()
      ..remove("id")
      ..addAll({"time": FieldValue.serverTimestamp()}));
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
          ..addAll({"time": FieldValue.serverTimestamp()}))
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
          ..addAll({"time": FieldValue.serverTimestamp()}));
    return id.then((value) => value.id);
  }

  static void updateTodo(Todo todo) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap()
          ..remove("id")
          ..addAll({"time": FieldValue.serverTimestamp()}))
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
}
