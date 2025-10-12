import '../repositories/task_repository.dart';

// Use case: toggle completion flag for a task by id
class ToggleDone {
  final TaskRepository repository;
  ToggleDone(this.repository);

  Future<void> call(String id) => repository.toggleDone(id);
}
