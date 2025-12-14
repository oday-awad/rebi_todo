class TaskList {
  final String id;
  final String name;
  final DateTime createdAt;
  final int order;

  const TaskList({
    required this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
  });

  TaskList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? order,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }
}
