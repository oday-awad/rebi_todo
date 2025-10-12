import 'package:hive/hive.dart';

part 'task_hive_model.g.dart';

// Hive model used for local persistence
@HiveType(typeId: 1)
class TaskHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  // For backward compatibility with old 5-field schema, we will default this
  // to 'default' when reading, if not present.
  @HiveField(1)
  String listId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  DateTime createdAt;

  TaskHiveModel({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.isDone,
    required this.createdAt,
  });
}
