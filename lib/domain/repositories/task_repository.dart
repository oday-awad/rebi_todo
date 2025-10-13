import '../entities/task.dart';

// Contract for working with tasks (implemented in the data layer).
abstract class TaskRepository {
  Future<List<Task>> getAllTasks({
    required String listId,
    bool archived = false,
  });
  Future<Task> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleDone(String id);
  Future<void> toggleArchive(String id);
}
