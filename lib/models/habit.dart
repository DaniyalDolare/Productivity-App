import 'dart:convert';
import 'package:flutter/foundation.dart';

class Habit {
  String? id;
  String? title;
  String? description;
  List<History>? history;
  int? currentStreak;
  int? highestStreak;
  String? category;
  DateTime? startDate;
  DateTime? endDate;
  History? lastCompletionHistory;

  Habit({
    this.id,
    this.title,
    this.description,
    this.history,
    this.currentStreak,
    this.highestStreak,
    this.category,
    this.startDate,
    this.endDate,
    this.lastCompletionHistory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'history': history,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'category': category,
      'startDate': startDate,
      'endDate': endDate,
      'lastCompletionHistory': lastCompletionHistory,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      history: map['history'],
      currentStreak: map['currentStreak'],
      highestStreak: map['highestStreak'],
      category: map['category'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      lastCompletionHistory: map['lastCompletionHistory'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<History>? history,
    int? currentStreak,
    int? highestStreak,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    History? lastCompletionHistory,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      history: history ?? this.history,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastCompletionHistory:
          lastCompletionHistory ?? this.lastCompletionHistory,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, description: $description, history: $history, currentStreak: $currentStreak, highestStreak: $highestStreak, category: $category, startDate: $startDate, endDate: $endDate, lastCompletionHistory: $lastCompletionHistory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        listEquals(other.history, history) &&
        other.currentStreak == currentStreak &&
        other.highestStreak == highestStreak &&
        other.category == category &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.lastCompletionHistory == lastCompletionHistory;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        history.hashCode ^
        currentStreak.hashCode ^
        highestStreak.hashCode ^
        category.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        lastCompletionHistory.hashCode;
  }
}

class History {
  String? id;
  DateTime? time;
  String? note;

  History({
    this.id,
    this.time,
    this.note,
  });

  History copyWith({
    String? id,
    DateTime? time,
    String? note,
  }) {
    return History(
      id: id ?? this.id,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'note': note,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      time: map['time'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());

  factory History.fromJson(String source) =>
      History.fromMap(json.decode(source));

  @override
  String toString() => 'History(id: $id, time: $time, note: $note)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is History &&
        other.id == id &&
        other.time == time &&
        other.note == note;
  }

  @override
  int get hashCode => id.hashCode ^ time.hashCode ^ note.hashCode;
}
