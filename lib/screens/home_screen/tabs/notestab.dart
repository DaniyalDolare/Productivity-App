import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:productivity_app/models/note.dart';
import 'package:productivity_app/screens/note/note_page.dart';
import 'package:productivity_app/services/database.dart';

class NotesTab extends StatefulWidget {
  final String searchText;
  final bool isCurrent;
  const NotesTab({Key? key, required this.searchText, required this.isCurrent})
      : super(key: key);
  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin<NotesTab> {
  late Stream<List<Note>> fetchedNotes;
  late bool searching;
  List<Note> _notes = [];
  final List<Note> _searchResult = [];

  List<Note> get notes => searching ? _searchResult : _notes;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchedNotes = DatabaseService.getNotes();
    searching = widget.isCurrent && widget.searchText.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    searching = widget.isCurrent && widget.searchText.isNotEmpty;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: StreamBuilder<List<Note>>(
        stream: fetchedNotes,
        builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
          if (snapshot.hasData) {
            _notes = snapshot.data!;
            if (searching) {
              search();
            }
            return notes.isEmpty
                ? Center(
                    child: Text(
                      searching ? "No match found" : "Add a note",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MasonryGridView.count(
                      itemCount: notes.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      itemBuilder: (context, index) => NoteCard(
                          note: notes[index],
                          index: index,
                          updateNote: _updateNote),
                    ),
                  );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void addNote() async {
    Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotePage(
                  note: Note(),
                )));
    if (result != null) {
      if (result["title"] != '' || result["note"] != '') {
        //save note to database and get the uid from databse and save uid to note.id
        Note note = Note(
            title: result["title"],
            note: result["note"],
            time: result["time"],
            isPinned: result["isPinned"]);
        DatabaseService.saveNote(note).then((value) {
          note.setId(value);
        });
      }
    }
  }

  void _updateNote(Map<String, dynamic>? result, Note note, int index) async {
    if (result != null) {
      if (result["title"] != '' || result["note"] != '') {
        // if note title and note has not been cleared
        if (result["title"] != note.title ||
            result["note"] != note.note ||
            result["isPinned"] != note.isPinned) {
          // if note is updated
          note
            ..title = result["title"]
            ..note = result["note"]
            ..time = result["time"]
            ..isPinned = result["isPinned"];
          DatabaseService.updateNote(note);
        }
      } else {
        DatabaseService.deleteNote(note);
      }
    } else {
      DatabaseService.deleteNote(note);
    }
  }

  void search() {
    _searchResult.clear();
    for (var note in _notes) {
      if (note.title!.toLowerCase().contains(widget.searchText.toLowerCase())) {
        _searchResult.add(note);
      } else if (note.note!
          .toLowerCase()
          .contains(widget.searchText.toLowerCase())) {
        _searchResult.add(note);
      }
    }
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard(
      {super.key,
      required this.note,
      required this.index,
      required this.updateNote});

  final Note note;
  final int index;
  final void Function(Map<String, dynamic>?, Note, int) updateNote;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Theme.of(context).colorScheme.primary,
          onTap: () async {
            Map<String, dynamic>? result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotePage(
                          note: note,
                        )));
            updateNote(result, note, index);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title!,
                  style: const TextStyle(
                      fontSize: 21.0, fontWeight: FontWeight.w500),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Padding(padding: EdgeInsets.all(4.0)),
                Text(
                  note.note!,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[800]
                          : Colors.grey[400]),
                  maxLines: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
