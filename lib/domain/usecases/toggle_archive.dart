import '../repositories/task_repository.dart';

class ToggleArchive {
  final TaskRepository repository;
  ToggleArchive(this.repository);

  Future<void> call(String id) => repository.toggleArchive(id);
}
