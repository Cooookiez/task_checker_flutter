import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Task.dart';

class TaskDatabaseService {
  // Singleton pattern
  static final TaskDatabaseService instance = TaskDatabaseService._init();
  static Database? _database;

  TaskDatabaseService._init();

  // Database name and version
  static const String _databaseName = 'task_checker.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String tableTask = 'tasks';

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnClickCount = 'click_count';
  static const String columnCategory = 'category';

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTask (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnClickCount INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL DEFAULT 'none'
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add category column if upgrading from version 1
      await db.execute('''
        ALTER TABLE $tableTask ADD COLUMN $columnCategory TEXT NOT NULL DEFAULT 'none'
      ''');
    }
  }

  /// Insert a task
  Future<int> insertTask(Task task) async {
    final db = await database;
    // Convert the task to map and ensure column names match database schema
    final Map<String, dynamic> taskMap = {
      columnId: task.id,
      columnName: task.name,
      columnClickCount: task.clickCount,
      columnCategory: Task.categoryToString(task.category),
    };
    return await db.insert(
      tableTask,
      taskMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTask);

    return List.generate(maps.length, (i) {
      // Map database column names to Task properties
      return Task(
        id: maps[i][columnId],
        name: maps[i][columnName],
        clickCount: maps[i][columnClickCount],
        category: Task.categoryFromString(maps[i][columnCategory] ?? 'none'),
      );
    });
  }

  /// Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    // Convert the task to map and ensure column names match database schema
    final Map<String, dynamic> taskMap = {
      columnId: task.id,
      columnName: task.name,
      columnClickCount: task.clickCount,
      columnCategory: Task.categoryToString(task.category),
    };
    return await db.update(
      tableTask,
      taskMap,
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task
  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      tableTask,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Close database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}