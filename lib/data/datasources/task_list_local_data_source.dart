import 'package:hive/hive.dart';

import '../models/task_list_hive_model.dart';

class TaskListLocalDataSource {
  final Box<TaskListHiveModel> listBox;

  TaskListLocalDataSource(this.listBox);

  Future<List<TaskListHiveModel>> getLists() async {
    return listBox.values.toList()
      ..sort((a, b) {
        if (a.order != b.order) return a.order.compareTo(b.order);
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Future<TaskListHiveModel> addList(TaskListHiveModel list) async {
    await listBox.put(list.id, list);
    return list;
  }

  Future<void> renameList(String id, String name) async {
    final existing = listBox.get(id);
    if (existing != null) {
      existing.name = name;
      await existing.save();
    }
  }

  Future<void> deleteList(String id) async {
    await listBox.delete(id);
  }

  Future<void> reorderLists(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      final list = listBox.get(orderedIds[i]);
      if (list != null) {
        list.order = i;
        await list.save();
      }
    }
  }
}
