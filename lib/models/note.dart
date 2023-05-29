import 'dart:convert';

class Note {
  String? id;
  String? title;
  String? note;
  DateTime? time;
  bool? isPinned = false;

  Note({
    this.id,
    this.title,
    this.note,
    this.time,
    this.isPinned,
  });

  void setId(String? id) {
    this.id = id;
  }

  Note copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? time,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      time: time ?? this.time,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'time': time,
      'isPinned': isPinned,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      time: map['time'],
      isPinned: map['isPinned'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Note(id: $id, title: $title, note: $note, time: $time, isPinned: $isPinned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.note == note &&
        other.time == time &&
        other.isPinned == isPinned;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        note.hashCode ^
        time.hashCode ^
        isPinned.hashCode;
  }
}
