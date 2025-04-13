import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String? id;
  DateTime? date;
  String? note;

  History({
    this.id,
    this.date,
    this.note,
  });

  History copyWith({
    String? id,
    DateTime? date,
    String? note,
  }) {
    return History(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'note': note,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      date: map['date']?.toDate(),
      note: map['note'],
    );
  }

  String toJson() => json.encode(
        toMap(),
        toEncodable: (object) {
          return object.toString();
        },
      );

  factory History.fromJson(String source) => History.fromMap(json.decode(
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

  @override
  String toString() => 'History(id: $id, date: $date, note: $note)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is History &&
        other.id == id &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode => id.hashCode ^ date.hashCode ^ note.hashCode;
}
