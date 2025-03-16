import 'package:flutter/material.dart';
import 'package:task_checker_flutter/models/Task.dart';
import 'package:task_checker_flutter/screens/add_edit_task_screen.dart';
import 'package:flutter/services.dart';
import 'package:task_checker_flutter/services/notification_controller.dart';
import 'package:task_checker_flutter/services/notification_service.dart';

class EventListScreen extends StatefulWidget {
  static const String id = 'EventListScreen';

  const EventListScreen({Key? key}) : super(key: key);

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> with WidgetsBindingObserver {
  // List to store tasks
  final List<Task> _tasks = [];

  // View mode state (list or grid)
  bool _isGridView = false;

  // Time interval in minutes
  int _intervalMinutes = 5;

  // Available interval options
  final List<int> _intervalOptions = [1, 2, 5, 10, 15, 30, 60];

  // Whether notifications are enabled
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Register this class as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Ensure _intervalMinutes has a valid default value that exists in _intervalOptions
    if (!_intervalOptions.contains(_intervalMinutes)) {
      _intervalMinutes =
      _intervalOptions.contains(5) ? 5 : _intervalOptions.first;
    }

    // Check if notifications are allowed
    _checkNotificationPermissions();
  }

  @override
  void dispose() {
    // Unregister observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, schedule notifications based on current interval
    if (state == AppLifecycleState.resumed) {
      _scheduleAppNotifications();
    }
  }

  // Check if notifications are allowed
  Future<void> _checkNotificationPermissions() async {
    final isAllowed = await NotificationService.checkPermissions();
    setState(() {
      _notificationsEnabled = isAllowed;
    });

    // If notifications are enabled, schedule app-wide notifications
    if (isAllowed) {
      _scheduleAppNotifications();
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    final isAllowed = await NotificationService.requestPermissions();
    setState(() {
      _notificationsEnabled = isAllowed;
    });
    if (isAllowed) {
      _scheduleAppNotifications();
    }
  }

  // Schedule app-wide notifications with the current interval
  void _scheduleAppNotifications() {
    if (!_notificationsEnabled) return;

    // Only schedule notifications if there are tasks
    if (_tasks.isNotEmpty) {
      NotificationController.scheduleAppReminders(
        intervalMinutes: _intervalMinutes,
        title: 'Task Reminder',
        message: _getNotificationMessage(),
      );
    } else {
      // If there are no tasks, cancel any scheduled notifications
      NotificationService.cancelAllPeriodicNotifications();
    }
  }

  // Get a message for notifications based on the number of tasks
  String _getNotificationMessage() {
    if (_tasks.isEmpty) {
      return 'No tasks yet. Add some tasks to get started!';
    } else if (_tasks.length == 1) {
      return 'You have 1 task to check: ${_tasks.first.name}';
    } else {
      return 'You have ${_tasks.length} tasks to check';
    }
  }

  // Send an immediate app-wide notification
  void _sendImmediateNotification() {
    if (!_notificationsEnabled) {
      _showEnableNotificationsDialog();
      return;
    }

    NotificationController.sendImmediateNotification(
      title: 'Task Reminder',
      message: _getNotificationMessage(),
    );
  }

  // Show dialog to enable notifications
  void _showEnableNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
                'Notifications are currently disabled. Would you like to enable them to receive task reminders?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _requestNotificationPermissions();
                },
                child: const Text('ENABLE'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Checker'),
        actions: [
          // Notification toggle button
          IconButton(
            icon: Icon(_notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off),
            tooltip: _notificationsEnabled
                ? 'Notifications enabled'
                : 'Notifications disabled',
            onPressed: () {
              if (_notificationsEnabled) {
                // Disable notifications
                setState(() {
                  _notificationsEnabled = false;
                });
                // Cancel all scheduled notifications
                NotificationService.cancelAllPeriodicNotifications();
              } else {
                // Request permissions
                _requestNotificationPermissions();
              }
            },
          ),

          // Interval selection dropdown
          DropdownButton<int>(
            value: _intervalOptions.contains(_intervalMinutes)
                ? _intervalMinutes
                : _intervalOptions[2],
            // Default to 5 if current value is not in options
            icon: const Icon(Icons.timer),
            underline: Container(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _intervalMinutes = newValue;
                });
                // Reschedule notifications with the new interval
                if (_notificationsEnabled) {
                  _scheduleAppNotifications();
                }
              }
            },
            items: _intervalOptions.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('${value} ${value == 1 ? 'min' : 'mins'}'),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),

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
      body: Column(
        children: [
          // Interval selection row for more visibility
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Reminder Interval:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10.0),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20.0),
                      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: Slider(
                      value: _intervalMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      // 1 minute increments (60-1 = 59 divisions)
                      label: '$_intervalMinutes ${_intervalMinutes == 1
                          ? 'minute'
                          : 'minutes'}',
                      onChanged: (double value) {
                        setState(() {
                          _intervalMinutes = value.round();
                        });
                        // Reschedule notifications with the new interval
                        if (_notificationsEnabled) {
                          _scheduleAppNotifications();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '$_intervalMinutes min',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Notification status indicator
          if (!_notificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Notifications are disabled. Enable them to receive task reminders.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: _requestNotificationPermissions,
                        child: const Text('ENABLE'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tasks list/grid
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
              child: Text(
                'No tasks yet. Add a task to get started!',
                style: TextStyle(fontSize: 18),
              ),
            )
                : _isGridView
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
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
          key: ValueKey(task.id),
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
                  itemBuilder: (BuildContext context) =>
                  [
                    const PopupMenuItem<String>(
                      value: 'notify',
                      child: Text('Send Reminder Now'),
                    ),
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
        crossAxisCount: 2, // Two columns
        childAspectRatio: 0.85,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          key: ValueKey(task.id),
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
                                    content: Text(
                                        'Switch to list view for reordering'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // Switch to list view
                                setState(() {
                                  _isGridView = false;
                                });
                              },
                              child: const Icon(Icons.drag_handle, size: 16,
                                  color: Colors.grey),
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions row at the bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Notify button
                      IconButton(
                        icon: const Icon(Icons.notifications_active, size: 20),
                        onPressed: () => _handleMenuSelection('notify', task),
                      ),

                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: task.clickCount >= 3
                            ? () => _editTask(task)
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You need to click the task ${3 - task
                                    .clickCount} more time(s) before you can edit it.',
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

  // Handle menu selection (notify, edit, or delete)
  void _handleMenuSelection(String value, Task task) {
    switch (value) {
      case 'notify':
        if (_notificationsEnabled) {
          // Show immediate notification about the specific task
          NotificationController.sendImmediateNotification(
            title: task.name,
            message: task.description,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Prompt to enable notifications
          _showEnableNotificationsDialog();
        }
        break;
      case 'edit':
        if (task.clickCount >= 3) {
          _editTask(task);
        } else {
          // Show a message that the task can only be edited after clicking 3 times
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You need to click the task ${3 -
                    task.clickCount} more time(s) before you can edit it.',
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

      // Update app-wide notifications with the new task count
      if (_notificationsEnabled) {
        _scheduleAppNotifications();
      }
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

        // Update app-wide notifications with the updated task
        if (_notificationsEnabled) {
          _scheduleAppNotifications();
        }
      }
    }
  }

  // Delete a task
  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });

    // Update app-wide notifications after removing a task
    if (_notificationsEnabled && _tasks.isNotEmpty) {
      _scheduleAppNotifications();
    } else if (_notificationsEnabled && _tasks.isEmpty) {
      // If this was the last task, cancel all notifications
      NotificationService.cancelAllPeriodicNotifications();
    }
  }
}