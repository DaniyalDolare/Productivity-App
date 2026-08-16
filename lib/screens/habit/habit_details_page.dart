import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/models/history.dart';
import 'package:productivity_app/screens/habit/add_edit_habit_page.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/local_notification.dart';
import 'package:productivity_app/utils/extensions.dart';

class HabitDetailsPage extends StatefulWidget {
  const HabitDetailsPage({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime? startDate, endDate;
  TimeOfDay? time;
  late Future<List<History>> getHistories;

  @override
  void initState() {
    super.initState();
    getHistories = DatabaseService.getHabitHistory(widget.habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditHabitPage(habit: widget.habit, isEditMode: true),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final cancelNotification = LocalNotification
                  .flutterLocalNotificationsPlugin
                  .cancel(id: widget.habit.id.hashCode);
              final deleteHabit = DatabaseService.deleteHabit(widget.habit);
              await Future.wait([cancelNotification, deleteHabit]);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<History>>(
          future: getHistories,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final histories = snapshot.data;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: widget.habit.title,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Title",
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        initialValue: widget.habit.description,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        initialValue: DateFormat.yMd()
                            .format(widget.habit.startDate!.toDateOnly()),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Start Date",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        initialValue: widget.habit.time?.format(context),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Time",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        initialValue: widget.habit.endDate != null
                            ? DateFormat.yMd()
                                .format(widget.habit.endDate!.toDateOnly())
                            : "",
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "End Date",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "History",
                            style: TextStyle(fontSize: 24.0),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Calendar(histories: histories ?? [], habit: widget.habit)
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class Calendar extends StatelessWidget {
  const Calendar({super.key, required this.histories, required this.habit});

  final List<History> histories;
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toDateOnly();
    final currentMonthHistory = histories
        .where((element) =>
            element.date!.month == now.month && element.date!.year == now.year)
        .map((e) => e.date!.toDateOnly())
        .toSet();
    var curr = now.subtract(Duration(days: now.day - 1));
    List<TableRow> weeks = [];
    for (var i = 0; i < 6; i++) {
      List<Widget> week = [];
      for (var j = 1; j < 8; j++) {
        if (j == curr.weekday && curr.month == now.month) {
          final isCompleted = currentMonthHistory.contains(curr);
          final isToday = curr.isAtSameMomentAs(now);
          week.add(Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: isToday ? Colors.grey[700] : null),
            child: Column(
              children: [
                Text(
                  "${curr.day}",
                  textAlign: TextAlign.center,
                ),
                isCompleted
                    ? const CircleAvatar(
                        radius: 2.0,
                        backgroundColor: Colors.green,
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ));
          curr = curr.add(const Duration(days: 1));
        } else {
          week.add(const Text(""));
        }
      }
      weeks.add(TableRow(children: week));
      if (curr.month != now.month) {
        break;
      }
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat.yMMM().format(now),
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
        Table(
          children: [
            TableRow(
              children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                  .map((e) => Text(
                        e,
                        textAlign: TextAlign.center,
                      ))
                  .toList(),
            ),
            ...weeks
          ],
        ),
      ],
    );
  }
}
