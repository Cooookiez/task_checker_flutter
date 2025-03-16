
class Task {
  final String name;
  final String description;
  int clickCount;

  Task({
    required this.name,
    required this.description,
    this.clickCount = 0,
  });

  // Increment click count
  void incrementClickCount() {
    clickCount++;
  }

  // Convert from Map (like when receiving from form)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      description: map['description'],
      clickCount: map['clickCount'] ?? 0,
    );
  }

  // Convert to Map (for storage or sending to API)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'clickCount': clickCount,
    };
  }
}