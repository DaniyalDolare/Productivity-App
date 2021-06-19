import 'package:example/screens/add%20note/addnote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../services/database.dart';
import '../../../models/note.dart';

class NotesTab extends StatefulWidget {
  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin<NotesTab> {
  List<Note> notes = [];

  @override
  bool get wantKeepAlive => true;

  // void initState() {
  //   super.initState();
  //   fetchNotes();
  //   // FirebaseDatabase.instance.goOnline();
  // }

  // Future<List<Note>> fetchNotes() async {
  //   List<Note> fetchedNotes = await getNotes();
  //   fetchedNotes.sort((a, b) {
  //     return DateTime.parse(b.time).compareTo(DateTime.parse(a.time));
  //   });
  //   this.notes = fetchedNotes;
  //   return fetchedNotes;
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () async {
          List result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddNote(
                        note: Note(),
                      )));
          if (result != null) {
            if (result[0] != '' || result[1] != '') {
              //save note to database and get the uid from databse and save uid to note.id
              Note note = new Note(
                  title: result[0],
                  note: result[1],
                  time: result[2],
                  isPinned: result[3]);

              print('saving to firestore');
              note.setId(await saveNoteToFirestore(note));
              print('id of saved note is ${note.id}');
              setState(() {
                this.notes.insert(0, note);
              });
            }
          }
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: getNotesFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
          if (snapshot.hasData) {
            this.notes = snapshot.data;
            //List<Note> fetchedNotes = snapshot.data;
            // fetchedNotes.sort((a, b) {
            //   return DateTime.parse(b.time).compareTo(DateTime.parse(a.time));
            // });
            // List<Note> pinnedNotes = [];
            // for (Note note in fetchedNotes) {
            //   if (note.isPinned == true) {
            //     pinnedNotes.add(note);
            //     print('true');
            //   } else {
            //     notes.add(note);
            //   }
            // }
            // notes.insertAll(0, pinnedNotes);

            // this.notes = fetchedNotes;

            print('\n\nnotes fetched\n\n');
            // for (Note note in fetchedNotes) {
            //   // print(note.isPinned);
            //   saveNoteToFirestore(note);
            // }
            return this.notes.isEmpty
                ? Center(
                    child: Text(
                      "Add a note",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.all(8),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: notes.length,
                      itemBuilder: (context, index) =>
                          _drawNoteCard(notes[index]),
                      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                  );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _processResult(List result, Note note) async {
    if (result != null) {
      if (result[0] != '' || result[1] != '') {
        print('level 1');
        print('old ${note.isPinned} , new ${result[3]}');
        if (result[0] != note.title ||
            result[1] != note.note ||
            result[3] != note.isPinned) {
          print('level 2');
          print('updating');
          Note editedNote = new Note(
              title: result[0],
              note: result[1],
              time: result[2],
              isPinned: result[3]);
          updateNoteToFirestore(editedNote, note.id);
          editedNote.setId(note.id);
          //search the updated note and interchange with updated one in the list
          int index = notes.indexWhere((element) => element.id == note.id);
          notes[index] = editedNote;
          setState(() {});
        }
      } else {
        await deleteNoteFromFirestore(note);
        notes.remove(note);
        setState(() {});
      }
    } else {
      await deleteNoteFromFirestore(note);
      notes.remove(note);
      setState(() {});
    }
  }

  Widget _drawNoteCard(Note note) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.redAccent,
          onTap: () async {
            List result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddNote(
                          note: note,
                        )));
            _processResult(result, note);
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(fontSize: 21.0),
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Text(
                  note.note,
                  style: TextStyle(color: Colors.grey[300]),
                  maxLines: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
