import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension Date on DateTime {
  /// Removes the time part from DateTime and return a DateTime with date only
  DateTime toDateOnly() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return DateTime.parse(formatter.format(this));
  }
}

extension Time on TimeOfDay {
  /// Returns true if [time] is greater than current time
  bool isAfter(TimeOfDay time) {
    return hour > time.hour || (hour == time.hour && minute > time.minute);
  }
}
