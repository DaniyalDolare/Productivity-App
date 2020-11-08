import 'package:example/database.dart';
import 'package:example/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TodoTab extends StatefulWidget {
  @override
  _TodoTabState createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> with AutomaticKeepAliveClientMixin {
  List<Todo> todos = [];
  bool checked;
  TextDecoration cutText;
  Color color;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  void fetchTodo() async {
    List<Todo> fetchedTodos = await getTodos();
    todos = fetchedTodos;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          List result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTodo()));
          if (result[0] != '') {
            Todo todo = Todo(title: result[0], isChecked: false);
            todo.id = saveTodo(todo);
            todos.add(todo);
          }
          setState(() {});
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: todos.isEmpty
          ? Center(
              child: Text(
                "Add a todo",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Container(
              margin: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) =>
                    _drawTodo(todos[index], index),
              ),
            ),
    );
  }

  Widget _drawTodo(Todo todo, int index) {
    checked = todo.isChecked;
    cutText = checked ? TextDecoration.lineThrough : TextDecoration.none;
    color = checked ? Colors.grey : Colors.white;
    return Container(
      margin: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
      child: Row(
        children: [
          Checkbox(
              activeColor: Colors.redAccent,
              value: checked,
              onChanged: (bool check) {
                setState(() {
                  checked = check;
                  todos[index].isChecked = check;
                  updateTodo(todo);
                });
              }),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        decoration: cutText, fontSize: 20, color: color),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await deleteTodo(todo);
                      todos.removeAt(index);
                      setState(() {});
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, [
          titleController.text,
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
              ]);
            },
          ),
          backgroundColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Container(
          margin: EdgeInsets.all(10),
          child: TextField(
            controller: titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                InputDecoration(hintText: "Title", border: InputBorder.none),
            style: TextStyle(fontSize: 23),
          ),
        ),
      ),
    );
  }
}
