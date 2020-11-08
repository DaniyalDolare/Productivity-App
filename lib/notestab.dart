import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'database.dart';
import 'note.dart';

class NotesTab extends StatefulWidget {
  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin<NotesTab> {
  List<Note> notes = [];

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    fetchNotes();
    //FirebaseDatabase.instance.goOnline();
  }

  void fetchNotes() async {
    List<Note> fetchedNotes = await getNotes();
    fetchedNotes.sort((a, b) {
      return DateTime.parse(b.time).compareTo(DateTime.parse(a.time));
    });
    this.notes = fetchedNotes;
    setState(() {});
  }

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
          if (result[0] != '' || result[1] != '') {
            //save note to database and get the uid from databse and save uid to note.id
            Note note =
                new Note(title: result[0], note: result[1], time: result[2]);
            note.setId(saveNote(note));
            //this.notes.add(note);
            this.notes.insert(0, note);
          }
          setState(() {});
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: notes.isEmpty
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
                itemBuilder: (context, index) => _drawNoteCard(notes[index]),
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
            ),
    );
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
            if (result != null) {
              Note editedNote =
                  new Note(title: result[0], note: result[1], time: result[2]);
              updateNote(editedNote, note.id);
              editedNote.setId(note.id);
              int index = notes.indexWhere((element) => element.id == note.id);
              notes[index] = editedNote;
            } else {
              notes.remove(note);
            }
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              //shape: BoxShape.rectangle,
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  textScaleFactor: 1.5,
                ),
                Text(
                  note.note,
                  maxLines: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddNote extends StatefulWidget {
  final Note note;
  AddNote({this.note});
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController titleController;
  TextEditingController noteController;
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    noteController = TextEditingController(text: widget.note.note);
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, [
          titleController.text,
          noteController.text,
          DateTime.now().toString()
        ]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, [
                titleController.text,
                noteController.text,
                DateTime.now().toString()
              ]);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteNote(widget.note);
                Navigator.pop(context);
              },
            ),
          ],
          backgroundColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Column(
          children: [
            TextField(
              controller: titleController,
              cursorColor: Colors.red[200],
              style: TextStyle(fontSize: 25),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
            Expanded(
              child: TextField(
                controller: noteController,
                cursorColor: Colors.red[200],
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Note",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
