import 'package:flutter/material.dart';
import 'package:task_checker_flutter/models/Task.dart';
import 'package:task_checker_flutter/screens/add_edit_task_screen.dart';

class EventListScreen extends StatefulWidget {
  static const String id = 'EventListScreen';

  const EventListScreen({Key? key}) : super(key: key);

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // List to store tasks
  final List<Task> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Checker'),
      ),
      body: _tasks.isEmpty
          ? const Center(
        child: Text(
          'No tasks yet. Add a task to get started!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ReorderableListView(
        padding: const EdgeInsets.only(top: 8.0),
        onReorder: _reorderTask,
        children: _buildTaskItems(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the list of task items
  List<Widget> _buildTaskItems() {
    return List.generate(_tasks.length, (index) {
      final task = _tasks[index];
      return Dismissible(
        key: ValueKey(index), // Using index as key ensures uniqueness
        direction: DismissDirection.none, // Disable swipe to dismiss
        child: Card(
          margin: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 8.0,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            title: Text(
              task.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display click count
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text('${task.clickCount}'),
                ),
                const SizedBox(width: 8),
                // Add 3-dots menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuSelection(value, task),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                // Add reorder handle
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_handle,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Increment click count
              setState(() {
                task.incrementClickCount();
              });
            },
          ),
        ),
      );
    });
  }

  // Reorder task in the list
  void _reorderTask(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        // Removing the item at oldIndex will shorten the list by 1
        newIndex -= 1;
      }
      final Task task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);

      // Show confirmation of move
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.name}" moved'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  // Handle menu selection (edit or delete)
  void _handleMenuSelection(String value, Task task) {
    switch (value) {
      case 'edit':
        if (task.clickCount >= 3) {
          _editTask(task);
        } else {
          // Show a message that the task can only be edited after clicking 3 times
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You need to click the task ${3 - task.clickCount} more time(s) before you can edit it.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'delete':
        _deleteTask(task);
        break;
    }
  }

  // Add a new task
  Future<void> _addTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );

    if (result != null && result is Task) {
      setState(() {
        _tasks.add(result);
      });
    }
  }

  // Edit an existing task
  Future<void> _editTask(Task task) async {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditTaskScreen(task: task),
        ),
      );

      if (result != null && result is Task) {
        setState(() {
          _tasks[index] = result;
        });
      }
    }
  }

  // Delete a task
  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }
}