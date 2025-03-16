import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String name;
  final String description;
  int clickCount;
  DateTime? lastNotificationTime;

  Task({
    String? id,
    required this.name,
    required this.description,
    this.clickCount = 0,
    this.lastNotificationTime,
  }) : id = id ?? const Uuid().v4();

  // Increment click count
  void incrementClickCount() {
    clickCount++;
  }

  // Update the last notification time
  void updateLastNotificationTime() {
    lastNotificationTime = DateTime.now();
  }

  // Convert from Map (like when receiving from form)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      clickCount: map['clickCount'] ?? 0,
      lastNotificationTime: map['lastNotificationTime'] != null
          ? DateTime.parse(map['lastNotificationTime'])
          : null,
    );
  }

  // Convert to Map (for storage or sending to API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'clickCount': clickCount,
      'lastNotificationTime': lastNotificationTime?.toIso8601String(),
    };
  }
}