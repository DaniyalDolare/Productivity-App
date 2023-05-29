import 'package:flutter/material.dart';
import '../../models/note.dart';

class NotePage extends StatefulWidget {
  final Note note;
  const NotePage({Key? key, required this.note}) : super(key: key);
  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  TextEditingController? titleController;
  TextEditingController? noteController;
  bool? pinned;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    noteController = TextEditingController(text: widget.note.note);
    pinned = widget.note.isPinned ?? false;
  }

  @override
  void dispose() {
    super.dispose();
    titleController!.dispose();
    noteController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          "title": titleController!.text,
          "note": noteController!.text,
          "time": DateTime.now(),
          "isPinned": pinned
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {
                "title": titleController!.text,
                "note": noteController!.text,
                "time": DateTime.now(),
                "isPinned": pinned
              });
            },
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.pin_drop,
                    color:
                        pinned! ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: () {
                    pinned = !pinned!;
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w500),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4.0)),
                TextField(
                  controller: noteController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Note",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
