import 'package:flutter/material.dart';
import 'package:productivity_app/services/notification.dart';
import '../../../models/reminder.dart';
import '../../../models/todo.dart';
import '../../../services/database.dart';
import '../../add todo/addtodo.dart';

class TodoTab extends StatefulWidget {
  final String searchText;
  final bool isCurrent;
  const TodoTab({Key? key, required this.searchText, required this.isCurrent})
      : super(key: key);
  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> with AutomaticKeepAliveClientMixin {
  List<Todo> _todos = [];
  final List<Todo> _searchResult = [];
  late Future<List<Todo>> getTodos;
  late bool searching;

  List<Todo> get todos => searching ? _searchResult : _todos;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getTodos = DatabaseService.getTodos();
    searching = widget.isCurrent && widget.searchText.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    searching = widget.isCurrent && widget.searchText.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          Map<String, dynamic>? result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTodo()));
          if (result != null) {
            if (result["title"] != '') {
              //if todo title is not empty then create todo
              Todo todo = Todo(
                  title: result["title"],
                  isChecked: false,
                  time: result["time"]);
              if (result["reminder"] != null) {
                todo.reminder = result["reminder"];
                todo.reminder!.title = todo.title;
                addReminder(todo.reminder!);
              }
              DatabaseService.saveTodo(todo).then((value) => todo.setId(value));
              _todos.insert(0, todo);
              setState(() {});
            }
          }
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: FutureBuilder(
        future: getTodos,
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasData) {
            _todos = snapshot.data!;
            if (searching) {
              search();
            }
            return todos.isEmpty
                ? const Center(
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
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const Center(child: Text("Connection time out"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget drawTodo(Todo todo, int index) {
    bool checked = todo.isChecked!;
    TextStyle style = TextStyle(
        fontSize: 18,
        color: checked ? Colors.grey : Colors.white,
        decoration: checked ? TextDecoration.lineThrough : TextDecoration.none);
    return Container(
      margin: const EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
      child: Row(
        children: [
          Checkbox(
              activeColor: Colors.redAccent,
              value: checked,
              onChanged: (bool? check) {
                setState(() {
                  checked = check!;
                  todo.isChecked = check;
                  DatabaseService.updateTodo(todo);
                  if (checked) {
                    _todos.remove(todo);
                    int checkedIndex =
                        _todos.indexWhere((todo) => todo.isChecked!);
                    if (checkedIndex == -1) {
                      _todos.add(todo);
                    } else {
                      _todos.insert(checkedIndex, todo);
                    }
                  } else {
                    _todos.remove(todo);
                    _todos.insert(0, todo);
                  }
                });
              }),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    todo.title!,
                    overflow: TextOverflow.fade,
                    style: style,
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      DatabaseService.deleteTodo(todo);
                      if (todo.reminder != null) {
                        await LocalNotification.flutterLocalNotificationsPlugin
                            .cancel(todo.reminder!.date!.microsecond);
                      }
                      _todos.remove(todo);
                      setState(() {});
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  void search() {
    _searchResult.clear();
    for (var todo in _todos) {
      if (todo.title!.toLowerCase().contains(widget.searchText.toLowerCase())) {
        _searchResult.add(todo);
      }
    }
  }

  Widget liststs() => CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => const Text("hi"),
                childCount: 5),
          ),
          const Text("THis is seperation"),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => const Text("by"),
                childCount: 5),
          ),
        ],
      );
}
