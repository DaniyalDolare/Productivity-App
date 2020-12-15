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

  // @override
  // void initState() {
  //   super.initState();
  //   fetchTodo();
  // }

  // void fetchTodo() async {
  //   List<Todo> fetchedTodos = await getTodosFromFirestore();
  //   for (Todo todo in fetchedTodos) {
  //     if (todo.isChecked == true) {
  //       checkedTodos.add(todo);
  //     } else {
  //       todos.add(todo);
  //     }
  //   }
  //   for (Todo todo in checkedTodos) {
  //     todos.add(todo);
  //   }
  //   // for (Todo todo in todos) {
  //   //   saveTodoToFirestore(todo);
  //   // }
  //   setState(() {});
  // }

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
            Todo todo =
                Todo(title: result[0], isChecked: false, time: result[1]);
            todo.id = await saveTodoToFirestore(todo);
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
      body: FutureBuilder(
        future: getTodosFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasData) {
            print('todes fetched');
            print(todos.length);
            todos = [];
            checkedTodos = [];
            for (Todo todo in snapshot.data) {
              if (todo.isChecked == true) {
                checkedTodos.add(todo);
              } else {
                todos.add(todo);
              }
            }
            for (Todo todo in checkedTodos) {
              todos.add(todo);
            }
            return this.todos.isEmpty
                ? Center(
                    child: Text(
                      "Add a todo",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (BuildContext context, int index) =>
                        drawTodo(todos[index], index),
                  );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      // body: this.todos.isEmpty
      //     ? Center(
      //         child: CircularProgressIndicator(),
      //         // child: Text(
      //         //   "Add a todo",
      //         //   style: TextStyle(color: Colors.grey),
      //         // ),
      //       )
      //     : ListView.builder(
      //         itemCount: todos.length,
      //         itemBuilder: (BuildContext context, int index) =>
      //             drawTodo(todos[index], index),
      //       ),
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
                  updateTodoToFirestore(todo);
                  if (checked == true) {
                    todos.removeAt(index);
                    todos.insert(todos.length - checkedTodos.length, todo);
                    checkedTodos.add(todo);
                  }
                  if (checked == false) {
                    todos.removeAt(index);
                    todos.insert(0, todo);
                    checkedTodos.remove(todo);
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
                      fontSize: 18,
                      color: color,
                      decoration: cutText,
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await deleteTodoFromFirestore(todo);
                      if (todo.isChecked == true) {
                        checkedTodos.remove(todo);
                      }
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
  bool remind = false;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, [titleController.text, DateTime.now().toString()]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                  context, [titleController.text, DateTime.now().toString()]);
            },
          ),
          backgroundColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  InputDecoration(hintText: "Title", border: InputBorder.none),
              style: TextStyle(fontSize: 23),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reminder', style: TextStyle(fontSize: 18.0)),
                Switch(
                    activeColor: Colors.redAccent,
                    value: remind,
                    onChanged: (value) {
                      remind = value;
                      setState(() {});
                    })
              ],
            ),
            remind
                ? Container(
                    child: Text('when?'),
                  )
                : Text(''),
          ]),
        ),
      ),
    );
  }
}
