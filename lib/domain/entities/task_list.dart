class TaskList {
  final String id;
  final String name;
  final DateTime createdAt;

  const TaskList({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  TaskList copyWith({String? id, String? name, DateTime? createdAt}) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
