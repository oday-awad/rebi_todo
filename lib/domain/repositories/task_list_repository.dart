import '../entities/task_list.dart';

abstract class TaskListRepository {
  Future<List<TaskList>> getAllLists();
  Future<TaskList> addList(TaskList list);
  Future<void> renameList(String id, String name);
  Future<void> deleteList(String id);
  Future<void> reorderLists(List<String> orderedIds);
}
