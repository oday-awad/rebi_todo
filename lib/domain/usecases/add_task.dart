import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Use case: add a new task
class AddTask {
  final TaskRepository repository;
  AddTask(this.repository);

  Future<Task> call(Task task) => repository.addTask(task);
}
