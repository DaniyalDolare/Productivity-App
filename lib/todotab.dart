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
  List<Todo> checkedTodos = [];

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
    for (Todo todo in fetchedTodos) {
      if (todo.isChecked == true) {
        checkedTodos.add(todo);
      } else {
        todos.add(todo);
      }
    }
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
            todos.insert(0, todo);
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
      body: todos.isEmpty && checkedTodos.isEmpty
          ? Center(
              child: Text(
                "Add a todo",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Container(
              // color: Colors.white,
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: todos.length,
                      itemBuilder: (BuildContext context, int index) =>
                          drawTodo(todos[index], index),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    color:
                        checkedTodos.isEmpty ? Colors.transparent : Colors.grey,
                  ),
                  Flexible(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: checkedTodos.length,
                        itemBuilder: (BuildContext context, int index) =>
                            drawTodo(checkedTodos[index], index)),
                  )
                ],
              ),
            ),
    );
  }

  Widget drawTodo(Todo todo, int index) {
    checked = todo.isChecked;
    Color color = checked ? Colors.grey : Colors.white;
    TextDecoration cutText =
        checked ? TextDecoration.lineThrough : TextDecoration.none;
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
                  todo.isChecked = check;
                  updateTodo(todo);
                  if (checked == true) {
                    todos.removeAt(index);
                    checkedTodos.insert(0, todo);
                  }
                  if (checked == false) {
                    todos.add(todo);
                    checkedTodos.removeAt(index);
                  }
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
                      fontSize: 20,
                      color: color,
                      decoration: cutText,
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await deleteTodo(todo);
                      if (todo.isChecked == true) {
                        checkedTodos.removeAt(index);
                      } else {
                        todos.removeAt(index);
                      }
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
