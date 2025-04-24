import 'package:flutter/material.dart';

import '../models/Task.dart';
import '../services/task_database_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  static const String id = 'AddEditTaskScreen';
  final Task? task; // Null if adding a new task, non-null if editing

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  late TextEditingController _nameController;

  // Selected category - initialize from existing task or default to none
  late TaskCategory _selectedCategory;

  // Determine if we're in edit mode
  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if in edit mode
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _selectedCategory = widget.task?.category ?? TaskCategory.none;
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    super.dispose();
  }

  // Create task from form data
  Task _createTaskFromForm() {
    return Task(
      id: widget.task?.id, // Keep original ID when editing
      name: _nameController.text.trim(),
      clickCount: widget.task?.clickCount ?? 0,
      category: _selectedCategory,
    );
  }

  // Save the task and return to previous screen
  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = _createTaskFromForm();

      // If this is a new task (not editing), save to database
      // The saving to database for edits is handled in EventListScreen
      if (!_isEditMode) {
        await TaskDatabaseService.instance.insertTask(task);
      }

      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'Add Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              // VA, NVA, NVA-R
              SegmentedButton<TaskCategory>(
                segments: const [
                  ButtonSegment<TaskCategory>(
                    value: TaskCategory.none,
                    label: Text('None'),
                  ),
                  ButtonSegment<TaskCategory>(
                    value: TaskCategory.va,
                    label: Text('VA'),
                  ),
                  ButtonSegment<TaskCategory>(
                    value: TaskCategory.nva,
                    label: Text('NVA'),
                  ),
                  ButtonSegment<TaskCategory>(
                    value: TaskCategory.nvar,
                    label: Text('NVA-R'),
                  ),
                ],
                selected: <TaskCategory>{_selectedCategory},
                onSelectionChanged: (Set<TaskCategory> newSelection) {
                  setState(() {
                    _selectedCategory = newSelection.first;
                  });
                },
              ),

              // Display click count if in edit mode
              if (_isEditMode) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Click Count:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.task?.clickCount ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditMode ? 'Update Task' : 'Create Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}