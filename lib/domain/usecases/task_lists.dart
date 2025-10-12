import '../entities/task_list.dart';
import '../repositories/task_list_repository.dart';

class GetTaskLists {
  final TaskListRepository repository;
  GetTaskLists(this.repository);
  Future<List<TaskList>> call() => repository.getAllLists();
}

class AddTaskList {
  final TaskListRepository repository;
  AddTaskList(this.repository);
  Future<TaskList> call(TaskList list) => repository.addList(list);
}

class RenameTaskList {
  final TaskListRepository repository;
  RenameTaskList(this.repository);
  Future<void> call(String id, String name) => repository.renameList(id, name);
}

class DeleteTaskList {
  final TaskListRepository repository;
  DeleteTaskList(this.repository);
  Future<void> call(String id) => repository.deleteList(id);
}
