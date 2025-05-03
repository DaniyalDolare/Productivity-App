import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DismissedHabit {
  String? id;
  DateTime? date;

  DismissedHabit({this.id, this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date != null ? Timestamp.fromDate(date!) : null};
  }

  factory DismissedHabit.fromMap(Map<String, dynamic> map) {
    return DismissedHabit(id: map['id'], date: map['date']?.toDate());
  }

  String toJson() => json.encode(
        toMap(),
        toEncodable: (object) {
          return object.toString();
        },
      );

  factory DismissedHabit.fromJson(String source) =>
      DismissedHabit.fromMap(json.decode(
        source,
        reviver: (key, value) {
          if (key == "date" && value != null) {
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

  DismissedHabit copyWith({String? id, DateTime? date}) {
    return DismissedHabit(id: id ?? this.id, date: date ?? this.date);
  }

  @override
  String toString() {
    return 'Habit(id: $id, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DismissedHabit && other.id == id && other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ date.hashCode;
  }
}
