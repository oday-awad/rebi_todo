import '../repositories/task_repository.dart';

// Use case: delete a task by id
class DeleteTask {
  final TaskRepository repository;
  DeleteTask(this.repository);

  Future<void> call(String id) => repository.deleteTask(id);
}
