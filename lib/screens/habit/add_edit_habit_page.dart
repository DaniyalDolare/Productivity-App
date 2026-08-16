import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/local_notification.dart';

class AddEditHabitPage extends StatefulWidget {
  const AddEditHabitPage(
      {required this.isEditMode, super.key, required this.habit});
  final bool isEditMode;
  final Habit habit;
  @override
  State<AddEditHabitPage> createState() => _AddEditHabitPageState();
}

class _AddEditHabitPageState extends State<AddEditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime? startDate, endDate;
  TimeOfDay? time;

  void saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (widget.isEditMode) {
        String oldTimeSlot = DatabaseService.getTimeSlot(widget.habit);
        widget.habit
          ..title = titleController.text
          ..description = descController.text
          ..startDate = startDate
          ..endDate = endDate
          ..time = time;
        DatabaseService.updateHabit(widget.habit, oldTimeSlot)
            .then((value) async {
          await LocalNotification.flutterLocalNotificationsPlugin
              .cancel(id: widget.habit.id.hashCode);
          LocalNotification.setHabitNotification(widget.habit);
        });

        Navigator.pop(context);
      } else {
        final habit = Habit(
            title: titleController.text,
            description: descController.text,
            currentStreak: 0,
            highestStreak: 0,
            startDate: startDate,
            endDate: endDate,
            time: time);
        DatabaseService.saveHabit(habit).then((value) {
          habit.id = value;
          LocalNotification.setHabitNotification(habit);
        });
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode) {
      titleController.text = widget.habit.title ?? "";
      descController.text = widget.habit.description ?? "";
      startDate = widget.habit.startDate;
      startDateController.text =
          startDate != null ? DateFormat.yMd().format(startDate!) : "";
      endDate = widget.habit.endDate;
      endDateController.text =
          endDate != null ? DateFormat.yMd().format(endDate!) : "Never";
      time = widget.habit.time;
      timeController.text = time != null ? time!.format(context) : "";
    }
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
          TextButton(
            onPressed: saveHabit,
            child: const Text("Save"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  validator: (value) => titleController.text.isEmpty
                      ? "Title should not be empty!"
                      : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Title",
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: descController,
                  validator: (value) => descController.text.isEmpty
                      ? "Description should not be empty!"
                      : null,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      startDate = date;
                      startDateController.text = DateFormat.yMd().format(date);
                    }
                  },
                  validator: (value) => startDate == null
                      ? "Start date should not be empty!"
                      : null,
                  readOnly: true,
                  controller: startDateController,
                  decoration: InputDecoration(
                    suffixIcon: TextButton(
                      onPressed: () {
                        startDate = DateTime.now();
                        startDateController.text =
                            DateFormat.yMd().format(DateTime.now());
                      },
                      child: const Text("Today"),
                    ),
                    labelText: "Start Date",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: time ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      time = selectedTime;
                      timeController.text = time!.format(context);
                    }
                  },
                  readOnly: true,
                  controller: timeController,
                  decoration: InputDecoration(
                    suffixIcon: TextButton(
                      onPressed: () {
                        time = const TimeOfDay(hour: 0, minute: 0);
                        timeController.text = time!.format(context);
                      },
                      child: const Text("Clear"),
                    ),
                    labelText: "Time (Optional)",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: (startDate ?? DateTime.now())
                          .add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      endDate = date;
                      endDateController.text = DateFormat.yMd().format(date);
                    }
                  },
                  readOnly: true,
                  controller: endDateController,
                  validator: (value) {
                    if (startDate != null &&
                        endDate != null &&
                        endDate!.isBefore(startDate!)) {
                      return "End date should not be before start date!";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "End Date",
                    border: const OutlineInputBorder(),
                    suffixIcon: TextButton(
                      onPressed: () {
                        endDateController.text = "Never";
                      },
                      child: const Text("Never"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
