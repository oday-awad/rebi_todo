import 'package:hive/hive.dart';

part 'task_list_hive_model.g.dart';

@HiveType(typeId: 2)
class TaskListHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  int order;

  @HiveField(4)
  int? iconCodePoint;

  TaskListHiveModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
    this.iconCodePoint,
  });
}
