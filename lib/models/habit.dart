import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/history.dart';

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
  DateTime? completedDate;
  TimeOfDay? time;

  Habit(
      {this.id,
      this.title,
      this.description,
      this.history,
      this.currentStreak,
      this.highestStreak,
      this.category,
      this.startDate,
      this.endDate,
      this.completedDate,
      this.time});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'history': history,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'category': category,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'time': time != null ? "${time!.hour}:${time!.minute}" : null
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    TimeOfDay? time;
    if (map["time"] != null) {
      var [hour, minute] = map["time"].split(":");
      time = TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
    }
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      history: map['history'],
      currentStreak: map['currentStreak'],
      highestStreak: map['highestStreak'],
      category: map['category'],
      startDate: map['startDate']?.toDate(),
      endDate: map['endDate']?.toDate(),
      completedDate: map['completedDate']?.toDate(),
      time: time,
    );
  }

  String toJson() => json.encode(
        toMap(),
        toEncodable: (object) {
          return object.toString();
        },
      );

  String notificationPayload() {
    final habit = Habit(
        id: id,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        time: time,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        completedDate: completedDate);
    return habit.toJson();
  }

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(
        source,
        reviver: (key, value) {
          if ((key == "startDate" ||
                  key == "endDate" ||
                  key == "completedDate") &&
              value != null) {
            final regex =
                RegExp(r'Timestamp\(seconds=(\d+), nanoseconds=(\d+)\)');
            final match = regex.firstMatch(value as String);
            if (match != null) {
              final seconds = int.parse(match.group(1)!);
              final nanoseconds = int.parse(match.group(2)!);
              return Timestamp(seconds, nanoseconds);
            } else {
              return null;
            }
          }
          return value;
        },
      ));

  Habit copyWith(
      {String? id,
      String? title,
      String? description,
      List<History>? history,
      int? currentStreak,
      int? highestStreak,
      String? category,
      DateTime? startDate,
      DateTime? endDate,
      DateTime? completedDate,
      TimeOfDay? time}) {
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
        completedDate: completedDate ?? this.completedDate,
        time: time ?? this.time);
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, description: $description, history: $history, currentStreak: $currentStreak, highestStreak: $highestStreak, category: $category, startDate: $startDate, endDate: $endDate, completedDate: $completedDate, time: $time)';
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
        other.completedDate == completedDate &&
        other.time == time;
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
        completedDate.hashCode ^
        time.hashCode;
  }
}
