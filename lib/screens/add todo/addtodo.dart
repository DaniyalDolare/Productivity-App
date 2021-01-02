import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool remind = false;
  TimeOfDay time = TimeOfDay.now();
  DateTime date = DateTime.now();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    timeController.dispose();
  }

  void _showTimePicker() async {
    TimeOfDay pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null)
      timeController.text =
          "${pickedTime.replacing(hour: pickedTime.hourOfPeriod).hour.toString().padLeft(2, "0")}:${pickedTime.minute.toString().padLeft(2, "0")} ${pickedTime.hour < 12 ? "AM" : "PM"}";
  }

  void _showDatePicker() async {
    DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date,
        lastDate: DateTime.now().add(Duration(days: 36500)));

    if (pickedDate != null) {
      dateController.text = DateFormat("MMMM d").format(pickedDate);
    }
  }

  Widget _timeDateContainer(
      {Function function,
      String initialText,
      TextEditingController controller,
      IconData icon}) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.grey[700]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                onTap: () {
                  function();
                },
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: initialText),
              ),
            ),
            Icon(icon)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, [titleController.text, DateTime.now().toString()]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                  context, [titleController.text, DateTime.now().toString()]);
            },
          ),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey),
        ),
        backgroundColor: Colors.grey[900],
        body: Container(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    hintText: "Title", border: InputBorder.none),
                style: TextStyle(fontSize: 23),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(6.0, 15.0, 6.0, 15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 8.0, bottom: 8.0),
                                  child: Text(
                                    'When to remind?',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                _timeDateContainer(
                                    function: _showTimePicker,
                                    initialText: "Time",
                                    controller: timeController,
                                    icon: Icons.timer),
                                _timeDateContainer(
                                    function: _showDatePicker,
                                    initialText: "Date",
                                    controller: dateController,
                                    icon: Icons.calendar_today),
                                Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[700]),
                                  child: Text("Do not repeat"),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FlatButton(
                                        onPressed: () {
                                          timeController.clear();
                                          dateController.clear();
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        timeController.clear();
                                        dateController.clear();
                                        Navigator.pop(context);
                                      },
                                      child: Text("Save"),
                                      color: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );

                      // setState(() {
                      //   remind = !remind;
                      // });
                    },
                    child: Text('Add Reminder +',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  // Switch(
                  //     activeColor: Colors.redAccent,
                  //     value: remind,
                  //     onChanged: (value) {
                  //       setState(() {
                  //         remind = value;
                  //       });
                  //     })
                ],
              ),
              remind
                  ? Container(
                      child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Time:'),
                            InkWell(
                                onTap: () {
                                  _showTimePicker();
                                },
                                child: Text(
                                    ' ${time.hour}:${time.minute} ${time.hour < 12 ? 'AM' : 'PM'}'))
                          ],
                        )
                      ],
                    ))
                  : Text(''),
            ]),
          ),
        ),
      ),
    );
  }
}
