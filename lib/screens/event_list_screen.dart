import 'package:flutter/material.dart';
import 'package:task_checker_flutter/models/Task.dart';
import 'package:task_checker_flutter/screens/add_edit_task_screen.dart';
import 'package:flutter/services.dart';

class EventListScreen extends StatefulWidget {
  static const String id = 'EventListScreen';

  const EventListScreen({Key? key}) : super(key: key);

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // List to store tasks
  final List<Task> _tasks = [];

  // View mode state (list or grid)
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Checker'),
        actions: [
          // Toggle between list and grid view
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
        child: Text(
          'No tasks yet. Add a task to get started!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : _isGridView
          ? _buildGridView()
          : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build list view of tasks with reordering
  Widget _buildListView() {
    return ReorderableListView.builder(
      itemCount: _tasks.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Task item = _tasks.removeAt(oldIndex);
          _tasks.insert(newIndex, item);
        });

        // Provide haptic feedback when reordering
        HapticFeedback.mediumImpact();
      },
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          key: ValueKey(task.name + index.toString()),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: ListTile(
            title: Text(
              task.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(task.description),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
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
              ],
            ),
            onTap: () {
              // Increment click count
              setState(() {
                task.incrementClickCount();
              });
            },
          ),
        );
      },
    );
  }

  // Build grid view of tasks
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,  // Two columns
        childAspectRatio: 0.85,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          key: ValueKey(task.name + index.toString()),
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              // Increment click count
              setState(() {
                task.incrementClickCount();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name and click count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onLongPress: () {
                                // Show a tip about reordering in list view
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Switch to list view for reordering'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // Switch to list view
                                setState(() {
                                  _isGridView = false;
                                });
                              },
                              child: const Icon(Icons.drag_handle, size: 16, color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          '${task.clickCount}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 16.0),

                  // Task description
                  Expanded(
                    child: Text(
                      task.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14.0,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions row at the bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: task.clickCount >= 3
                            ? () => _editTask(task)
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You need to click the task ${3 - task.clickCount} more time(s) before you can edit it.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _deleteTask(task),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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