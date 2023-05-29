import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'reminder.dart';

class Todo {
  String? id;
  String? title;
  bool? isChecked;
  DateTime? time;
  Reminder? reminder;
  String? data;
  List<Todo>? subTodo;

  Todo({
    this.id,
    this.title,
    this.isChecked,
    this.time,
    this.reminder,
    this.data,
    this.subTodo,
  });

  void setId(String? id) {
    this.id = id;
  }

  Todo copyWith({
    String? id,
    String? title,
    bool? isChecked,
    DateTime? time,
    Reminder? reminder,
    String? data,
    List<Todo>? subTodo,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      time: time ?? this.time,
      reminder: reminder ?? this.reminder,
      data: data ?? this.data,
      subTodo: subTodo ?? this.subTodo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isChecked': isChecked,
      'time': time,
      'reminder': reminder?.toMap(),
      'data': data,
      'subTodo': subTodo?.map((x) => x.toMap()).toList(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isChecked: map['isChecked'],
      time: map['time'],
      reminder:
          map['reminder'] != null ? Reminder.fromMap(map['reminder']) : null,
      data: map['data'],
      subTodo: map['subTodo'] != null
          ? List<Todo>.from(map['subTodo']?.map((x) => Todo.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isChecked: $isChecked, time: $time, reminder: $reminder, data: $data, subTodo: $subTodo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.isChecked == isChecked &&
        other.time == time &&
        other.reminder == reminder &&
        other.data == data &&
        listEquals(other.subTodo, subTodo);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isChecked.hashCode ^
        time.hashCode ^
        reminder.hashCode ^
        data.hashCode ^
        subTodo.hashCode;
  }
}
