import 'package:intl/intl.dart';

extension Date on DateTime {
  /// Removes the time part from DateTime and return a DateTime with date only
  DateTime toDateOnly() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return DateTime.parse(formatter.format(this));
  }
}
