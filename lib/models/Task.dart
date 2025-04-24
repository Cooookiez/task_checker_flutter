import 'package:uuid/uuid.dart';

import '../services/task_database_service.dart';

enum TaskCategory {
  none,
  va,
  nva,
  nvar,
}

class Task {
  final String id;
  final String name;
  int clickCount;
  TaskCategory category;

  Task({
    String? id,
    required this.name,
    this.clickCount = 0,
    this.category = TaskCategory.none,
  }) : id = id ?? const Uuid().v4();

  /// Increment click count
  Future<void> incrementClickCount() async {
    clickCount++;

    // Update in database
    await TaskDatabaseService.instance.updateTask(this);
  }

  /// Convert from Map (for receiving from database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? map['ID'] ?? '',
      name: map['name'] ?? map['NAME'] ?? '',
      clickCount: map['click_count'] ?? map['clickCount'] ?? 0,
    );
  }

  /// Convert to Map (for storing in database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'click_count': clickCount,
      'category': categoryToString(category),
    };
  }

  /// Update category
  Future<void> updateCategory(TaskCategory newCategory) async {
    category = newCategory;

    // Update in database
    await TaskDatabaseService.instance.updateTask(this);
  }

  /// Helper method to convert string to enum
  static TaskCategory categoryFromString(String category) {
    switch (category) {
      case 'va':
        return TaskCategory.va;
      case 'nva':
        return TaskCategory.nva;
      case 'nvar':
        return TaskCategory.nvar;
      case '':
      case ' ':
      case 'none':
      default:
        return TaskCategory.none;
    }
  }

  /// Helper method to convert enum to string
  static String categoryToString(TaskCategory category) {
    switch (category) {
      case TaskCategory.va:
        return 'va';
      case TaskCategory.nva:
        return 'nva';
      case TaskCategory.nvar:
        return 'nvar';
      case TaskCategory.none:
      default:
        return 'none';
    }
  }

  /// Get display name for category
  String getCategoryDisplayName() {
    switch (category) {
      case TaskCategory.va:
        return 'VA';
      case TaskCategory.nva:
        return 'NVA';
      case TaskCategory.nvar:
        return 'NVA-R';
      case TaskCategory.none:
      default:
        return 'None';
    }
  }
}