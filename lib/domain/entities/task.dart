// Domain entity representing a task in the application.
class Task {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final bool isDone;
  final bool isArchived;
  final DateTime createdAt;
  final List<String> imagePaths;

  const Task({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.isDone,
    this.isArchived = false,
    required this.createdAt,
    this.imagePaths = const [],
  });

  Task copyWith({
    String? id,
    String? listId,
    String? title,
    String? description,
    bool? isDone,
    bool? isArchived,
    DateTime? createdAt,
    List<String>? imagePaths,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
