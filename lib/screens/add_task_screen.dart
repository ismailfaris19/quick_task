import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  // Method to create a new task
  Future<ParseObject?> createTask(String title, DateTime dueDate) async {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false);

    final response = await task.save();
    if (response.success) {
      print('Task created: ${response.result}');
      return response.result;
    } else {
      print('Error creating task: ${response.error?.message}');
      return null;
    }
  }

  // Method to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Earliest date allowed
      lastDate: DateTime(2100), // Latest date allowed
    );

    if (pickedDate != null) {
      // Format the selected date and display it in the controller
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      dueDateController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
        backgroundColor: Colors.amber[200],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context), // Show date picker
                      ),
                    ),
                    readOnly: true, // Make it read-only to prevent manual input
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Retrieve input values
                      final title = titleController.text.trim();
                      final dueDateText = dueDateController.text.trim();

                      // Validate inputs
                      if (title.isEmpty || dueDateText.isEmpty) {
                        print('Title and due date are required.');
                        return;
                      }

                      try {
                        // Parse the due date
                        final dueDate = DateTime.parse(dueDateText);

                        // Call the createTask method
                        final task = await createTask(title, dueDate);

                        if (task != null) {
                          print("Task created: ${task.toString()}");
                          Navigator.pushNamed(context, '/home');
                        } else {
                          print("Task creation result: ${task?.toString() ?? 'null'}");
                        }
                      } catch (e) {
                        print('Error parsing date or creating task: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}