import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController titleController = TextEditingController();
  bool remind = false;
  Reminder? reminder;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _popScreen(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _popScreen(context),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: "Title", border: InputBorder.none),
                style: const TextStyle(fontSize: 23),
                maxLines: null,
              ),
              const SizedBox(
                height: 10.0,
              ),
              reminder == null
                  ? GestureDetector(
                      onTap: () async {
                        Map<String, dynamic>? result = await showDialog(
                            context: context,
                            builder: (context) => const AddReminderDailog());

                        if (result != null) {
                          DateTime date = result["date"];
                          TimeOfDay time = result["time"];
                          reminder = Reminder(
                              date: date.add(Duration(
                                  hours: time.hour, minutes: time.minute)));
                          setState(() {});
                        }
                      },
                      child: const Text(
                        'Add Reminder +',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat("MMMM dd, hh:mm a")
                              .format(reminder!.date!)),
                          GestureDetector(
                            onTap: () {
                              reminder = null;
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.close,
                              size: 17.5,
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _popScreen(BuildContext context) {
    Navigator.pop(context, {
      "title": titleController.text,
      "time": DateTime.now().toString(),
      "reminder": reminder,
    });
  }
}

class AddReminderDailog extends StatefulWidget {
  const AddReminderDailog({
    super.key,
  });

  @override
  State<AddReminderDailog> createState() => _AddReminderDailogState();
}

class _AddReminderDailogState extends State<AddReminderDailog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TimeOfDay time = TimeOfDay.now();
  DateTime date = DateTime.now();
  final weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final days = List.generate(31, (index) => index + 1);
  bool doNotRepeat = false;
  String repeat = "Weekly";
  String until = "Forever";
  String monthlyRepeatFor = "Same Day";
  Set<int> selectedWeeks = {DateTime.now().weekday - 1};
  Set<int> selectedDays = {DateTime.now().day};

  ///Function to format TimeOfDay to hh:mm AM/PM string format
  String _formatTime(TimeOfDay time) {
    return "${time.hourOfPeriod.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")} ${time.period == DayPeriod.am ? "AM" : "PM"}";
  }

  void _showTimePicker() async {
    TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: time);
    if (pickedTime != null) {
      time = pickedTime;
      timeController.text = _formatTime(pickedTime);
    }
  }

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 36500)));

    if (pickedDate != null) {
      date = pickedDate;
      dateController.text = DateFormat("MMMM dd").format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double minDialogWidth = 200.0;
    double maxDialogWidth = 400.0;
    if (screenWidth < minDialogWidth) {
      minDialogWidth = screenWidth;
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: Container(
            constraints: BoxConstraints(
              minWidth: minDialogWidth,
              maxWidth: maxDialogWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    'When to remind?',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                TimeDateField(
                    onTap: _showTimePicker,
                    initialText: "Time",
                    controller: timeController,
                    icon: Icons.timer),
                const SizedBox(
                  height: 10.0,
                ),
                TimeDateField(
                    onTap: _showDatePicker,
                    initialText: "Date",
                    controller: dateController,
                    icon: Icons.calendar_today),
                Row(
                  children: [
                    Checkbox(
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: doNotRepeat,
                        onChanged: (value) {
                          setState(() {
                            doNotRepeat = value!;
                          });
                        }),
                    const Text("Do not repeat"),
                  ],
                ),
                if (!doNotRepeat) ...[
                  DropdownButtonFormField<String>(
                      decoration: const InputDecoration(label: Text("Repeat")),
                      value: repeat,
                      onChanged: (value) {
                        repeat = value!;
                        setState(() {});
                      },
                      items: ["Daily", "Weekly", "Monthly", "Yearly"]
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList()),
                  if (repeat == "Weekly") ...[
                    const SizedBox(
                      height: 10.0,
                    ),
                    GridView.builder(
                      itemCount: weekDays.length,
                      itemBuilder: (context, index) => ClipOval(
                        child: Material(
                          color: selectedWeeks.contains(index)
                              ? Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[300]
                                  : Colors.grey[700]
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (selectedWeeks.contains(index)) {
                                selectedWeeks.remove(index);
                              } else {
                                selectedWeeks.add(index);
                              }
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey)),
                              alignment: Alignment.center,
                              child: Text(
                                weekDays[index],
                                style: TextStyle(
                                    fontWeight: selectedWeeks.contains(index)
                                        ? FontWeight.w500
                                        : FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10.0,
                        crossAxisCount: 5,
                        crossAxisSpacing: 10.0,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                  if (repeat == "Monthly") ...[
                    const SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        monthlyRepeatFor = "Same Day";
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<String>(
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -4),
                            value: "Same Day",
                            groupValue: monthlyRepeatFor,
                            onChanged: (value) {
                              monthlyRepeatFor = value!;
                              setState(() {});
                            },
                          ),
                          const Text("Repeat for same day")
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        monthlyRepeatFor = "Selected Days";
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<String>(
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -4),
                            value: "Selected Days",
                            groupValue: monthlyRepeatFor,
                            onChanged: (value) {
                              monthlyRepeatFor = value!;
                              setState(() {});
                            },
                          ),
                          const Text("Repeat for selected days")
                        ],
                      ),
                    ),
                    if (monthlyRepeatFor == "Selected Days")
                      GridView.builder(
                        itemCount: days.length,
                        itemBuilder: (context, index) => ClipOval(
                          child: Material(
                            color: selectedDays.contains(index + 1)
                                ? Colors.grey
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (selectedDays.contains(index + 1)) {
                                  selectedDays.remove(index + 1);
                                } else {
                                  selectedDays.add(index + 1);
                                }
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey)),
                                alignment: Alignment.center,
                                child: Text(days[index].toString()),
                              ),
                            ),
                          ),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 10.0,
                          crossAxisCount: 7,
                          crossAxisSpacing: 10.0,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                  ],
                  DropdownButtonFormField<String>(
                      decoration: const InputDecoration(label: Text("Until")),
                      value: until,
                      onChanged: (value) {
                        until = value!;
                      },
                      items: ["Forever", "A date", "Number of times"]
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList()),
                ],
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                          timeController.clear();
                          dateController.clear();
                        },
                        child: const Text("Cancel")),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, {"date": date, "time": time});
                        timeController.clear();
                        dateController.clear();
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: const Text("Save"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeDateField extends StatelessWidget {
  const TimeDateField({
    Key? key,
    this.onTap,
    this.initialText,
    this.controller,
    this.icon,
  }) : super(key: key);

  final void Function()? onTap;
  final String? initialText;
  final TextEditingController? controller;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[300]
              : Colors.grey[700],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                onTap: onTap,
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white),
                    hintText: initialText),
              ),
            ),
            Icon(icon)
          ],
        ),
      ),
    );
  }
}
