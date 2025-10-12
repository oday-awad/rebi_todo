import 'package:hive/hive.dart';

import '../models/task_list_hive_model.dart';

class TaskListLocalDataSource {
  final Box<TaskListHiveModel> listBox;

  TaskListLocalDataSource(this.listBox);

  Future<List<TaskListHiveModel>> getLists() async {
    return listBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<TaskListHiveModel> addList(TaskListHiveModel list) async {
    await listBox.put(list.id, list);
    return list;
  }

  Future<void> renameList(int id, String name) async {
    final existing = listBox.get(id);
    if (existing != null) {
      existing.name = name;
      await existing.save();
    }
  }

  Future<void> deleteList(int id) async {
    await listBox.delete(id);
  }
}
