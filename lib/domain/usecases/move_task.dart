import '../repositories/task_repository.dart';

// Use case: move a task to another list
class MoveTask {
  final TaskRepository repository;
  MoveTask(this.repository);

  Future<void> call({required String taskId, required String newListId}) =>
      repository.moveTask(taskId, newListId);
}

