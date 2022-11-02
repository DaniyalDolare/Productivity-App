import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool remind = false;
  TimeOfDay time = TimeOfDay.now();
  DateTime date = DateTime.now();
  Reminder? reminder;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    timeController.dispose();
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
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Container(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
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
                              builder: (context) {
                                final weekDays = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun"
                                ];
                                final days =
                                    List.generate(31, (index) => index + 1);
                                bool doNotRepeat = false;
                                String repeat = "Weekly";
                                String until = "Forever";
                                String monthlyRepeatFor = "Same Day";
                                Set<int> selectedWeeks = {date.weekday - 1};
                                Set<int> selectedDays = {date.day};

                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 15.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0,
                                                  top: 8.0,
                                                  bottom: 8.0),
                                              child: Text(
                                                'When to remind?',
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            ),
                                            _timeDateContainer(
                                                onTap: _showTimePicker,
                                                initialText: "Time",
                                                controller: timeController,
                                                icon: Icons.timer),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            _timeDateContainer(
                                                onTap: _showDatePicker,
                                                initialText: "Date",
                                                controller: dateController,
                                                icon: Icons.calendar_today),
                                            Row(
                                              children: [
                                                Checkbox(
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
                                                  decoration:
                                                      const InputDecoration(
                                                          label:
                                                              Text("Repeat")),
                                                  value: repeat,
                                                  onChanged: (value) {
                                                    repeat = value!;
                                                    setState(() {});
                                                  },
                                                  items: [
                                                    "Daily",
                                                    "Weekly",
                                                    "Monthly",
                                                    "Yearly"
                                                  ]
                                                      .map((item) =>
                                                          DropdownMenuItem(
                                                              value: item,
                                                              child:
                                                                  Text(item)))
                                                      .toList()),
                                              if (repeat == "Weekly") ...[
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                GridView.builder(
                                                  itemCount: weekDays.length,
                                                  itemBuilder:
                                                      (context, index) =>
                                                          ClipOval(
                                                    child: Material(
                                                      color: selectedWeeks
                                                              .contains(index)
                                                          ? Colors.grey
                                                          : Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (selectedWeeks
                                                              .contains(
                                                                  index)) {
                                                            selectedWeeks
                                                                .remove(index);
                                                          } else {
                                                            selectedWeeks
                                                                .add(index);
                                                          }
                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            weekDays[index],
                                                            style: TextStyle(
                                                                fontWeight: selectedWeeks
                                                                        .contains(
                                                                            index)
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal),
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
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                ),
                                              ],
                                              if (repeat == "Monthly") ...[
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    monthlyRepeatFor =
                                                        "Same Day";
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Radio<String>(
                                                        visualDensity:
                                                            const VisualDensity(
                                                                horizontal: -4,
                                                                vertical: -4),
                                                        value: "Same Day",
                                                        groupValue:
                                                            monthlyRepeatFor,
                                                        onChanged: (value) {
                                                          monthlyRepeatFor =
                                                              value!;
                                                          setState(() {});
                                                        },
                                                      ),
                                                      const Text(
                                                          "Repeat for same day")
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    monthlyRepeatFor =
                                                        "Selected Days";
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Radio<String>(
                                                        visualDensity:
                                                            const VisualDensity(
                                                                horizontal: -4,
                                                                vertical: -4),
                                                        value: "Selected Days",
                                                        groupValue:
                                                            monthlyRepeatFor,
                                                        onChanged: (value) {
                                                          monthlyRepeatFor =
                                                              value!;
                                                          setState(() {});
                                                        },
                                                      ),
                                                      const Text(
                                                          "Repeat for selected days")
                                                    ],
                                                  ),
                                                ),
                                                if (monthlyRepeatFor ==
                                                    "Selected Days")
                                                  GridView.builder(
                                                    itemCount: days.length,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            ClipOval(
                                                      child: Material(
                                                        color: selectedDays
                                                                .contains(
                                                                    index + 1)
                                                            ? Colors.grey
                                                            : Colors
                                                                .transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            if (selectedDays
                                                                .contains(
                                                                    index +
                                                                        1)) {
                                                              selectedDays
                                                                  .remove(
                                                                      index +
                                                                          1);
                                                            } else {
                                                              selectedDays.add(
                                                                  index + 1);
                                                            }
                                                            setState(() {});
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey)),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(days[
                                                                    index]
                                                                .toString()),
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
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                  ),
                                              ],
                                              DropdownButtonFormField<String>(
                                                  decoration:
                                                      const InputDecoration(
                                                          label: Text("Until")),
                                                  value: until,
                                                  onChanged: (value) {
                                                    until = value!;
                                                  },
                                                  items: [
                                                    "Forever",
                                                    "A date",
                                                    "Number of times"
                                                  ]
                                                      .map((item) =>
                                                          DropdownMenuItem(
                                                              value: item,
                                                              child:
                                                                  Text(item)))
                                                      .toList()),
                                            ],
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.white),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      timeController.clear();
                                                      dateController.clear();
                                                    },
                                                    child:
                                                        const Text("Cancel")),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, {
                                                      "date": date,
                                                      "time": time
                                                    });
                                                    timeController.clear();
                                                    dateController.clear();
                                                  },
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0)),
                                                      backgroundColor:
                                                          Colors.redAccent),
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
                                  );
                                });
                              });
                          if (result != null) {
                            DateTime date = result["date"];
                            TimeOfDay time = result["time"];
                            reminder = Reminder(
                                date: date.add(Duration(
                                    hours: time.hour, minutes: time.minute)));
                            setState(() {});
                          }
                        },
                        child: const Text('Add Reminder +',
                            style: TextStyle(color: Colors.grey)),
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

  Widget _timeDateContainer(
      {void Function()? onTap,
      String? initialText,
      TextEditingController? controller,
      IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.grey[700]),
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
                    hintStyle: const TextStyle(color: Colors.white),
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
