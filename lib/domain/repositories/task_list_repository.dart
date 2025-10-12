import '../entities/task_list.dart';

abstract class TaskListRepository {
  Future<List<TaskList>> getAllLists();
  Future<TaskList> addList(TaskList list);
  Future<void> renameList(int id, String name);
  Future<void> deleteList(int id);
}
