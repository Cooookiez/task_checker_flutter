import 'package:uuid/uuid.dart';

import '../services/task_database_service.dart';

class Task {
  final String id;
  final String name;
  final String description;
  int clickCount;

  Task({
    String? id,
    required this.name,
    required this.description,
    this.clickCount = 0,
  }) : id = id ?? const Uuid().v4();

  // Increment click count
  Future<void> incrementClickCount() async {
    clickCount++;

    // Update in database
    await TaskDatabaseService.instance.updateTask(this);
  }

// Convert from Map (for receiving from database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? map['ID'] ?? '',
      name: map['name'] ?? map['NAME'] ?? '',
      description: map['description'] ?? map['DESCRIPTION'] ?? '',
      clickCount: map['click_count'] ?? map['clickCount'] ?? 0,
    );
  }

// Convert to Map (for storing in database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'click_count': clickCount,
    };
  }
}