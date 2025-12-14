import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_hive_model.dart';

// Repository implementation bridging domain and data layers.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  Task _mapFromHive(TaskHiveModel model) => Task(
    id: model.id,
    listId: model.listId,
    title: model.title,
    description: model.description,
    isDone: model.isDone,
    isArchived: model.isArchived,
    createdAt: model.createdAt,
  );

  TaskHiveModel _mapToHive(Task task) => TaskHiveModel(
    id: task.id,
    listId: task.listId,
    title: task.title,
    description: task.description,
    isDone: task.isDone,
    isArchived: task.isArchived,
    createdAt: task.createdAt,
  );

  @override
  Future<Task> addTask(Task task) async {
    final saved = await localDataSource.addTask(_mapToHive(task));
    return _mapFromHive(saved);
  }

  @override
  Future<void> deleteTask(String id) => localDataSource.deleteTask(id);

  @override
  Future<List<Task>> getAllTasks({
    required String listId,
    bool archived = false,
  }) async {
    final models = await localDataSource.getTasks(listId, archived: archived);
    return models.map(_mapFromHive).toList();
  }

  @override
  Future<void> toggleDone(String id) => localDataSource.toggleDone(id);

  @override
  Future<void> updateTask(Task task) =>
      localDataSource.updateTask(_mapToHive(task));

  @override
  Future<void> toggleArchive(String id) => localDataSource.toggleArchive(id);

  @override
  Future<void> moveTask(String taskId, String newListId) =>
      localDataSource.moveTask(taskId, newListId);
}
