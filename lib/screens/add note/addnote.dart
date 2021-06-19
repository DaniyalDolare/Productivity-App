import 'package:example/models/note.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  final Note note;
  AddNote({this.note});
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController titleController;
  TextEditingController noteController;
  bool pinned;

  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    noteController = TextEditingController(text: widget.note.note);
    pinned = this.widget.note.isPinned ?? false;
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
          DateTime.now().toString(),
          pinned
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
                DateTime.now().toString(),
                pinned
              ]);
            },
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.pin_drop,
                    color: pinned ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () {
                    pinned = !pinned;
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // deleteNoteFromFirestore(widget.note);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
          backgroundColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Container(
          padding: EdgeInsets.all(5.0),
          child: Column(
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
              Padding(padding: EdgeInsets.all(4.0)),
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
      ),
    );
  }
}
