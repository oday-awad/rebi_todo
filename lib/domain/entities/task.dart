// Domain entity representing a task in the application.
class Task {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.isDone,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? listId,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
