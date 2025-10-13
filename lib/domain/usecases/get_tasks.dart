import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Use case: fetch all tasks
class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);

  Future<List<Task>> call({required String listId, bool archived = false}) =>
      repository.getAllTasks(listId: listId, archived: archived);
}
