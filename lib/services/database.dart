import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/todo.dart';

class DatabaseService {
  DatabaseService._();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> saveNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    var docReference = firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .add(note.toMap()..remove("id"));

    return docReference.then((value) => value.id);
  }

  static Future<List<Note>> getNotes() async {
    final User user = FirebaseAuth.instance.currentUser!;
    QuerySnapshot dataSnapshot = await firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .orderBy('time', descending: true)
        .get(const GetOptions(source: Source.serverAndCache));

    List<Note> notes = [];
    List<Note> fetchedNotes = [];

    if (dataSnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot values in dataSnapshot.docs) {
        final id = values.id;
        final data = values.data() as Map<String, dynamic>;
        Note note = Note.fromMap(data);
        note.setId(id.toString());
        fetchedNotes.add(note);
      }

      List<Note> pinnedNotes = [];
      for (Note note in fetchedNotes) {
        if (note.isPinned == true) {
          pinnedNotes.add(note);
        } else {
          notes.add(note);
        }
      }
      notes.insertAll(0, pinnedNotes);
    }
    return notes;
  }

  static Future<void> updateNote(Note note) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('notes')
        .doc(note.id)
        .update(note.toMap()..remove("id"))
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
        .add(todo.toMap()..remove("id"))
        .catchError((error) {
      debugPrint('this is the error: $error');
    });
    return id.then((value) => value.id);
  }

  static void updateTodo(Todo todo) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap()..remove("id"))
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

  static Future<List<Todo>> getTodos() async {
    final User user = FirebaseAuth.instance.currentUser!;
    QuerySnapshot querySnapshot = await firestore
        .collection(user.uid)
        .doc('data')
        .collection('todos')
        .orderBy('isChecked')
        .orderBy('time', descending: true)
        .get(const GetOptions(source: Source.serverAndCache));

    List<Todo> todos = [];

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot values in querySnapshot.docs) {
        var id = values.id;
        var data = values.data() as Map<String, dynamic>;
        Todo todo = Todo.fromMap(data);
        todo.id = id.toString();
        todos.add(todo);
      }
    } else {
      debugPrint('no data');
    }
    return todos;
  }
}
