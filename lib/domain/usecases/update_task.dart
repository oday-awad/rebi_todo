import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Use case: update an existing task
class UpdateTask {
  final TaskRepository repository;
  UpdateTask(this.repository);

  Future<void> call(Task task) => repository.updateTask(task);
}
