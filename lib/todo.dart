class Todo {
  String title;
  bool isChecked;
  String time;
  String data;
  List<Todo> subTodo = [];
  String id;
  Todo({this.title, this.isChecked, this.time});

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'isChecked': this.isChecked,
      'time': this.time
    };
  }
}
