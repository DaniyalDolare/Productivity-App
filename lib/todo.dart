class Todo {
  String title;
  String data;
  bool isChecked;
  List<Todo> subTodo = [];
  String id;
  Todo({this.title, this.isChecked});

  Map<String, dynamic> toJson() {
    return {'title': this.title, 'isChecked': this.isChecked};
  }
}
