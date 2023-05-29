import 'package:flutter/material.dart';
import 'package:productivity_app/models/reminder.dart';
import 'package:productivity_app/models/todo.dart';
import 'package:productivity_app/screens/todo/todo_page.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/notification.dart';

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
  late Stream<List<Todo>> getTodos;
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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: addTodo,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: StreamBuilder(
        stream: getTodos,
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasData) {
            _todos = snapshot.data!;
            if (searching) {
              search();
            }
            return todos.isEmpty
                ? Center(
                    child: Text(
                      searching ? "No match found" : "Add a todo",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (BuildContext context, int index) {
                      final todo = todos[index];
                      bool checked = todo.isChecked!;
                      TextStyle style = TextStyle(
                          fontSize: 18,
                          color: checked
                              ? Colors.grey
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : null,
                          decoration: checked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none);
                      return Container(
                        margin: const EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
                        child: Row(
                          children: [
                            Checkbox(
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                value: checked,
                                onChanged: (check) => updateTodo(todo, check)),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      onPressed: () => deleteTodo(todo))
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

  void addTodo() async {
    Map<String, dynamic>? result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const TodoPage()));
    if (result != null) {
      if (result["title"] != '') {
        //if todo title is not empty then create todo
        Todo todo = Todo(
            title: result["title"], isChecked: false, time: result["time"]);
        if (result["reminder"] != null) {
          todo.reminder = result["reminder"];
          todo.reminder!.title = todo.title;
          addReminder(todo.reminder!);
        }
        DatabaseService.saveTodo(todo).then((value) => todo.setId(value));
        _todos.insert(0, todo);
      }
    }
  }

  void deleteTodo(Todo todo) async {
    DatabaseService.deleteTodo(todo);
    if (todo.reminder != null) {
      await LocalNotification.flutterLocalNotificationsPlugin
          .cancel(todo.reminder!.date!.microsecond);
    }
    _todos.remove(todo);
  }

  void updateTodo(Todo todo, bool? check) {
    final checked = check!;
    todo.isChecked = check;
    DatabaseService.updateTodo(todo);
    if (checked) {
      _todos.remove(todo);
      int checkedIndex = _todos.indexWhere((todo) => todo.isChecked!);
      if (checkedIndex == -1) {
        _todos.add(todo);
      } else {
        _todos.insert(checkedIndex, todo);
      }
    } else {
      _todos.remove(todo);
      _todos.insert(0, todo);
    }
  }

  void search() {
    _searchResult.clear();
    for (var todo in _todos) {
      if (todo.title!.toLowerCase().contains(widget.searchText.toLowerCase())) {
        _searchResult.add(todo);
      }
    }
  }
}
