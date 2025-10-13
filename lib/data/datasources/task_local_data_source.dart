import 'package:hive/hive.dart';
import '../../core/utils/logger.dart';

import '../models/task_hive_model.dart';

// Local data source encapsulating Hive operations for tasks.
class TaskLocalDataSource {
  final Box<TaskHiveModel> taskBox;

  TaskLocalDataSource(this.taskBox);

  Future<List<TaskHiveModel>> getTasks(
    String listId, {
    bool archived = false,
  }) async {
    final items =
        taskBox.values
            .where((t) => t.listId == listId && t.isArchived == archived)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<TaskHiveModel> addTask(TaskHiveModel task) async {
    try {
      await taskBox.put(task.id, task);
      Log.s('Task added', tag: 'TaskLocalDataSource');
      Log.d(
        'id=${task.id}, listId=${task.listId}, title=${task.title}',
        tag: 'TaskLocalDataSource',
      );
    } catch (e, s) {
      Log.e(
        'Failed to add task',
        tag: 'TaskLocalDataSource',
        error: e,
        stackTrace: s,
      );
    }
    return task;
  }

  Future<void> updateTask(TaskHiveModel task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
    Log.i('Task deleted id=$id', tag: 'TaskLocalDataSource');
  }

  Future<void> toggleDone(String id) async {
    final existing = taskBox.get(id);
    if (existing != null) {
      existing.isDone = !existing.isDone;
      await existing.save();
      Log.i(
        'Task toggled id=$id isDone=${existing.isDone}',
        tag: 'TaskLocalDataSource',
      );
    }
  }

  Future<void> toggleArchive(String id) async {
    final existing = taskBox.get(id);
    if (existing != null) {
      existing.isArchived = !existing.isArchived;
      await existing.save();
      Log.i(
        'Task archived id=$id isArchived=${existing.isArchived}',
        tag: 'TaskLocalDataSource',
      );
    }
  }
}
