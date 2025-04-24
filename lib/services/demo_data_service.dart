import '../models/Task.dart';
import 'task_database_service.dart';

class DemoDataService {
  // Singleton pattern
  static final DemoDataService _instance = DemoDataService._internal();

  factory DemoDataService() {
    return _instance;
  }

  DemoDataService._internal();

  // Get list of demo tasks
  List<Task> getDemoTasks() {
    return [
      Task(
        name: 'Morning Exercise',
        clickCount: 5,
        category: TaskCategory.va,
      ),
      Task(
        name: 'Check Emails',
        clickCount: 8,
        category: TaskCategory.nva,
      ),
      Task(
        name: 'Team Meeting',
        clickCount: 3,
        category: TaskCategory.va,
      ),
      Task(
        name: 'Social Media Check',
        clickCount: 12,
        category: TaskCategory.nvar,
      ),
      Task(
        name: 'Project Planning',
        clickCount: 2,
        category: TaskCategory.va,
      ),
      Task(
        name: 'Document Review',
        clickCount: 4,
        category: TaskCategory.nva,
      ),
      Task(
        name: 'App Development',
        clickCount: 15,
        category: TaskCategory.va,
      ),
      Task(
        name: 'UI Design Review',
        clickCount: 7,
        category: TaskCategory.va,
      ),
    ];
  }

  // Load all demo tasks into database
  Future<List<Task>> loadAllDemoTasks() async {
    final demoTasks = getDemoTasks();

    for (final task in demoTasks) {
      await TaskDatabaseService.instance.insertTask(task);
    }

    return demoTasks;
  }

  // Clear all tasks from database
  Future<void> clearAllTasks() async {
    final tasks = await TaskDatabaseService.instance.getTasks();

    for (final task in tasks) {
      await TaskDatabaseService.instance.deleteTask(task.id);
    }
  }

  // Reset database with only demo tasks
  Future<List<Task>> resetWithDemoTasks() async {
    await clearAllTasks();
    return await loadAllDemoTasks();
  }
}