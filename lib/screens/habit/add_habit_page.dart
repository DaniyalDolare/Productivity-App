import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime? startDate, endDate;

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
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  "title": titleController.text,
                  "description": descController.text,
                  "startDate": startDate,
                  "endDate": endDate
                });
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
    );
  }
}
