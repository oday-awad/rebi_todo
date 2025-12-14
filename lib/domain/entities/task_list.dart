class TaskList {
  final String id;
  final String name;
  final DateTime createdAt;
  final int order;
  final int? iconCodePoint;

  const TaskList({
    required this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
    this.iconCodePoint,
  });

  TaskList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? order,
    int? iconCodePoint,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}
