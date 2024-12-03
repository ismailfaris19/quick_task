import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/edit_screen.dart';

class Task {
  final String objectId;
  final String title;
  final DateTime dueDate;
  bool status;
  

  Task({
    required this.objectId,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromParse(ParseObject parseObject) {
    print('Fetched ParseObject: ${parseObject.toJson()}');
    return Task(
      objectId: parseObject.objectId!,
      title: parseObject.get<String>('title') ?? '',
      dueDate: parseObject.get<DateTime>('dueDate') ?? DateTime.now(),
      status: parseObject.get<bool>('isCompleted') ?? false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen initializes
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final currentUser = await ParseUser.currentUser();
      print('Current User: $currentUser');
      if (currentUser == null) {
        print('No current user found.');
        return [];
      }

      final query = QueryBuilder(ParseObject('Task'))
        ..orderByDescending('dueDate');

      final response = await query.query();

      if (response.success && response.results != null) {
        print('Query successful. Results: ${response.results}');
        return (response.results as List<ParseObject>)
            .map((e) => Task.fromParse(e))
            .toList();
      } else {
        print('Error fetching tasks: ${response.error?.message}');
        return [];
      }
    } catch (e) {
      print('Exception fetching tasks: $e');
      return [];
    }
  }

  Future<bool> deleteTask(String objectId) async {
    print('Object ID from deleteTask: $objectId');

    final task = ParseObject('Task')..objectId = objectId;

    final response = await task.delete();
    print('Delete Response: ${response.error?.message}');

    if (response.success) {
      print('Task deleted successfully');
      return true;
    } else {
      print('Error deleting task: ${response.error?.message}');
      return false;
    }
  }

  Future<bool> toggleTaskStatus(String objectId, bool currentStatus) async {
    print('Object ID from toggleTaskStatus: $objectId');

    final task = ParseObject('Task')..objectId = objectId;
    task.set('isCompleted', !currentStatus);

    final response = await task.save();
    print('Response: ${response.results}');
    if (response.success) {
      print('Task updated successfully');
      return true;
    } else {
      print('Error updating task: ${response.error?.message}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TASK MANAGEMENT'),
        backgroundColor: Colors.amber[100],
      ),
      body: Container(
        color: Colors.grey[50], // Full background color
        child: FutureBuilder<List<Task>>(
          future: fetchTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading tasks'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No tasks available'));
            } else {
              final tasks = snapshot.data!;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.amber, width: 1)
                    ),
                    elevation: 5,
                    color: Colors.white, 
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        'Due: ${task.dueDate.toLocal()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.status,
                            activeColor: Colors.amber[200], 
                            onChanged: (value) async {
                              final success = await toggleTaskStatus(
                                  task.objectId, task.status);
                              if (success) {
                                setState(() {
                                  task.status = !task.status;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(task: task),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _loadTasks();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final success = await deleteTask(task.objectId);
                              if (success) {
                                setState(() {
                                  tasks.remove(task);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask');
        },
        backgroundColor: Colors.amber[200],
        child: Icon(Icons.add),
      ),
    );
  }
}