class Note {
  final String title;
  final String note;
  final String time;
  bool isPinned = false;
  String id;

  Note({this.title, this.note, this.time, this.isPinned});

  void setId(String id) {
    this.id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'note': this.note,
      'time': this.time.toString(),
      'isPinned': this.isPinned
    };
  }
}
