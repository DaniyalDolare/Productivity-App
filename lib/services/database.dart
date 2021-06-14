import 'package:example/models/todo.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import '../models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// final databaseReference = FirebaseDatabase.instance.reference();
final user = FirebaseAuth.instance.currentUser.uid;

// String saveNote(Note note) {
//   var id = databaseReference.child(user).child("notes/").push();
//   id.set(note.toJson());
//   print(id.key);
//   return id.key;
// }

// void updateNote(Note note, String id) {
//   databaseReference.child(user).child("notes/" + id).update(note.toJson());
// }

// Future<List<Note>> getNotes() async {
//   DataSnapshot dataSnapshot =
//       await databaseReference.child(user).child('notes/').once();
//   List<Note> notes = [];

//   if (dataSnapshot.value != null) {
//     Map<dynamic, dynamic> values = dataSnapshot.value;
//     values.forEach((key, value) {
//       Note note =
//           Note(title: value['title'], note: value['note'], time: value['time']);
//       note.setId(key.toString());
//       notes.add(note);
//     });
//   } else {
//     print('No data');
//   }
//   return notes;
// }

// Future<bool> deleteNote(Note note) async {
//   await databaseReference.child(user).child('notes/').child(note.id).remove();
//   return true;
// }

// String saveTodo(Todo todo) {
//   var id = databaseReference.child(user).child('todos/').push();
//   id.set(todo.toJson());
//   return id.key;
// }

// void updateTodo(Todo todo) {
//   databaseReference.child(user + '/todos').child(todo.id).update(todo.toJson());
// }

// Future<void> deleteTodo(Todo todo) async {
//   await databaseReference.child(user).child('todos/').child(todo.id).remove();
// }

// Future<List<Todo>> getTodos() async {
//   DataSnapshot dataSnapshot =
//       await databaseReference.child(user + '/todos').once();

//   List<Todo> todos = [];
//   if (dataSnapshot.value != null) {
//     Map<dynamic, dynamic> values = dataSnapshot.value;
//     values.forEach((key, value) {
//       Todo todo = Todo(title: value['title'], isChecked: value['isChecked']);
//       todo.id = key.toString();
//       todos.add(todo);
//     });
//   }
//   return todos;
// }

FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<String> saveNoteToFirestore(Note note) async {
  var id = await firestore
      .collection(user)
      .doc('data')
      .collection('notes')
      .add(note.toJson());
  // .catchError((error) => print('this is the error: $error'));

  return id.id;
  //then((value) => value.id);
}

Future<List<Note>> getNotesFromFirestore() async {
  QuerySnapshot dataSnapshot = await firestore
      .collection(user)
      .doc('data')
      .collection('notes')
      .get(GetOptions(source: Source.serverAndCache));

  List<Note> notes = [];
  List<Note> fetchedNotes = [];

  if (dataSnapshot.docs.isNotEmpty) {
    print(dataSnapshot.docs);
    for (QueryDocumentSnapshot values in dataSnapshot.docs) {
      var id = values.id;
      var data = values.data() as Map;
      Note note = Note(
          title: data['title'],
          note: data['note'],
          time: data['time'],
          isPinned: data['isPinned'] ?? false);
      note.setId(id.toString());
      fetchedNotes.add(note);
    }

    fetchedNotes.sort((a, b) {
      return DateTime.parse(b.time).compareTo(DateTime.parse(a.time));
    });
    List<Note> pinnedNotes = [];
    for (Note note in fetchedNotes) {
      if (note.isPinned == true) {
        pinnedNotes.add(note);
        print('true');
      } else {
        notes.add(note);
      }
    }
    notes.insertAll(0, pinnedNotes);
  } else {
    print('No data');
  }
  return notes;
}

Future<void> updateNoteToFirestore(Note note, String id) async {
  await firestore
      .collection(user)
      .doc('data')
      .collection('notes')
      .doc(id)
      .update(note.toJson())
      .catchError((error) => print('this is yhe error: $error'));
}

Future<bool> deleteNoteFromFirestore(Note note) async {
  await firestore
      .collection(user)
      .doc('data')
      .collection('notes')
      .doc(note.id)
      .delete();
  return true;
}

Future<String> saveTodoToFirestore(Todo todo) async {
  var id = firestore
      .collection(user)
      .doc('data')
      .collection('todos')
      .add(todo.toJson())
      .catchError((error) {
    print('this is the error: $error');
  });
  return await id.then((value) => value.id);
}

void updateTodoToFirestore(Todo todo) async {
  await firestore
      .collection(user)
      .doc('data')
      .collection('todos')
      .doc(todo.id)
      .update(todo.toJson())
      .catchError((error) => print('this is the error: $error'));
}

Future<void> deleteTodoFromFirestore(Todo todo) async {
  await firestore
      .collection(user)
      .doc('data')
      .collection('todos')
      .doc(todo.id)
      .delete()
      .catchError((error) => print('this is the error: $error'));
}

Future<List<Todo>> getTodosFromFirestore() async {
  QuerySnapshot querySnapshot = await firestore
      .collection(user)
      .doc('data')
      .collection('todos')
      .get(GetOptions(source: Source.serverAndCache));

  List<Todo> todos = [];
  if (querySnapshot.docs.isNotEmpty) {
    for (QueryDocumentSnapshot values in querySnapshot.docs) {
      var id = values.id;
      var data = values.data() as Map;
      Todo todo = Todo(
          title: data['title'],
          isChecked: data['isChecked'],
          time: data['time'] ?? DateTime.now().toString());
      todo.id = id.toString();
      todos.add(todo);
    }
    todos.sort(
        (a, b) => DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
  } else {
    print('no data');
  }

  return todos;
}
