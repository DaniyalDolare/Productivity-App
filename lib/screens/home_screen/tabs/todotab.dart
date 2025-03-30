import 'package:flutter/material.dart';
import 'package:productivity_app/models/reminder.dart';
import 'package:productivity_app/models/todo.dart';
import 'package:productivity_app/screens/todo/todo_page.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/notification.dart';
import 'package:productivity_app/widgets/stream_animated_list_builder.dart';

class TodoTab extends StatefulWidget {
  final bool isCurrent;
  final TextEditingController searchController;
  const TodoTab(
      {super.key, required this.isCurrent, required this.searchController});
  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> with AutomaticKeepAliveClientMixin {
  late Stream<List<Todo>> getTodos;
  late bool searching;

  late final GlobalObjectKey<AnimatedListState> _listKey =
      GlobalObjectKey<AnimatedListState>(this);
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getTodos = DatabaseService.getTodos();
    searching = widget.isCurrent && widget.searchController.text.isNotEmpty;
    widget.searchController.addListener(() {
      searching = widget.isCurrent && widget.searchController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    searching = widget.isCurrent && widget.searchController.text.isNotEmpty;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: addTodo,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: StreamAnimatedListBuilder(
        listKey: _listKey,
        searchController: widget.searchController,
        stream: getTodos,
        build: (context, item, animation) {
          return TodoItem(
              todo: item,
              onTodoUpdate: updateTodo,
              onTodoDelete: deleteTodo,
              index: 0,
              animation: animation);
        },
        compareEquals: (p0, p1) => p0.id == p1.id,
        compareUpdated: (p0, p1) => p0.isUpdated(p1),
        onEmpty: Center(
          child: searching
              ? const Text("No match found")
              : const Text("Add a todo"),
        ),
        onError: const Center(child: Text("Connection time out")),
        duration: const Duration(milliseconds: 100),
        filterData: search,
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
      }
    }
  }

  void deleteTodo(Todo todo) async {
    if (todo.reminder != null) {
      await LocalNotification.flutterLocalNotificationsPlugin
          .cancel(todo.reminder!.date!.microsecond);
    }
    DatabaseService.deleteTodo(todo);
  }

  void updateTodo(Todo todo, bool? check) {
    DatabaseService.updateTodo(todo.copyWith(isChecked: check));
  }

  List<Todo> search(List<Todo> todos) {
    return todos
        .where((todo) => todo.title!
            .toLowerCase()
            .contains(widget.searchController.text.toLowerCase()))
        .toList();
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem(
      {super.key,
      required this.todo,
      required this.onTodoUpdate,
      required this.onTodoDelete,
      required this.index,
      required this.animation});

  final Todo todo;
  final int index;
  final Animation<double> animation;
  final void Function(Todo, bool?) onTodoUpdate;
  final void Function(Todo) onTodoDelete;

  @override
  Widget build(BuildContext context) {
    bool checked = todo.isChecked!;
    TextStyle style = TextStyle(
        fontSize: 18,
        color: checked
            ? Colors.grey
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : null,
        decoration: checked ? TextDecoration.lineThrough : TextDecoration.none);
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
        child: Row(
          children: [
            Checkbox(
                activeColor: Theme.of(context).colorScheme.primary,
                value: checked,
                onChanged: (check) => onTodoUpdate(todo, check)),
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
                      onPressed: () => onTodoDelete(todo))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
