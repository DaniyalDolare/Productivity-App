import 'package:example/todo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'note.dart';

final databaseReference = FirebaseDatabase.instance.reference();
final user = FirebaseAuth.instance.currentUser.uid;

String saveNote(Note note) {
  var id = databaseReference.child(user).child("notes/").push();
  id.set(note.toJson());
  print(id.key);
  return id.key;
}

void updateNote(Note note, String id) {
  databaseReference.child(user).child("notes/" + id).update(note.toJson());
}

Future<List<Note>> getNotes() async {
  DataSnapshot dataSnapshot =
      await databaseReference.child(user).child('notes/').once();
  List<Note> notes = [];

  if (dataSnapshot.value != null) {
    Map<dynamic, dynamic> values = dataSnapshot.value;
    values.forEach((key, value) {
      Note note =
          Note(title: value['title'], note: value['note'], time: value['time']);
      note.setId(key.toString());
      notes.add(note);
    });
  } else {
    print('No data');
  }
  return notes;
}

Future<bool> deleteNote(Note note) async {
  await databaseReference.child(user).child('notes/').child(note.id).remove();
  return true;
}

String saveTodo(Todo todo) {
  var id = databaseReference.child(user).child('todos/').push();
  id.set(todo.toJson());
  return id.key;
}

void updateTodo(Todo todo) {
  databaseReference.child(user + '/todos').child(todo.id).update(todo.toJson());
}

Future<void> deleteTodo(Todo todo) async {
  await databaseReference.child(user).child('todos/').child(todo.id).remove();
}

Future<List<Todo>> getTodos() async {
  DataSnapshot dataSnapshot =
      await databaseReference.child(user + '/todos').once();

  List<Todo> todos = [];
  if (dataSnapshot.value != null) {
    Map<dynamic, dynamic> values = dataSnapshot.value;
    values.forEach((key, value) {
      Todo todo = Todo(title: value['title'], isChecked: value['isChecked']);
      todo.id = key.toString();
      todos.add(todo);
    });
  }
  return todos;
}
