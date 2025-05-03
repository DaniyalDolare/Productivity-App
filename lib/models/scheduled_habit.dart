import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduledHabit {
  String? id;
  String? userId;
  String? habitId;
  String? title;
  int? currentStreak;
  int? highestStreak;
  DateTime? completedDate;
  DateTime? startDate;
  TimeOfDay? time;

  ScheduledHabit(
      {this.id,
      this.userId,
      this.habitId,
      this.title,
      this.currentStreak,
      this.highestStreak,
      this.startDate,
      this.time,
      this.completedDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'habitId': habitId,
      'title': title,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'time': time != null ? "${time!.hour}:${time!.minute}" : null,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null
    };
  }

  factory ScheduledHabit.fromMap(Map<String, dynamic> map) {
    TimeOfDay? time;
    if (map["time"] != null) {
      var [hour, minute] = map["time"].split(":");
      time = TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
    }
    return ScheduledHabit(
        id: map['id'],
        userId: map['userId'],
        habitId: map['habitId'],
        title: map['title'],
        currentStreak: map['currentStreak'],
        highestStreak: map['highestStreak'],
        startDate: map['startDate']?.toDate(),
        time: time,
        completedDate: map['completedDate']?.toDate());
  }

  String toJson() => json.encode(
        toMap(),
        toEncodable: (object) {
          return object.toString();
        },
      );

  factory ScheduledHabit.fromJson(String source) =>
      ScheduledHabit.fromMap(json.decode(
        source,
        reviver: (key, value) {
          if ((key == "startDate" || key == "completedDate") && value != null) {
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

  ScheduledHabit copyWith(
      {String? id,
      String? userId,
      String? habitId,
      String? title,
      int? currentStreak,
      int? highestStreak,
      DateTime? startDate,
      TimeOfDay? time,
      DateTime? completedDate}) {
    return ScheduledHabit(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        habitId: habitId ?? this.habitId,
        title: title ?? this.title,
        currentStreak: currentStreak ?? this.currentStreak,
        highestStreak: highestStreak ?? this.highestStreak,
        startDate: startDate ?? this.startDate,
        time: time ?? this.time,
        completedDate: completedDate ?? this.completedDate);
  }

  @override
  String toString() {
    return 'Habit(id: $id,userId: $userId,habitId: $habitId,title: $title,currentStreak: $currentStreak,highestStreak: $highestStreak,startDate: $startDate,time: $time, completedDate: $completedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScheduledHabit &&
        other.id == id &&
        other.userId == userId &&
        other.habitId == habitId &&
        other.title == title &&
        other.currentStreak == currentStreak &&
        other.highestStreak == highestStreak &&
        other.startDate == startDate &&
        other.time == time &&
        other.completedDate == completedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        habitId.hashCode ^
        title.hashCode ^
        currentStreak.hashCode ^
        highestStreak.hashCode ^
        startDate.hashCode ^
        time.hashCode ^
        completedDate.hashCode;
  }
}
