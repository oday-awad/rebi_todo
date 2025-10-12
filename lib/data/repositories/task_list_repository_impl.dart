import '../../domain/entities/task_list.dart';
import '../../domain/repositories/task_list_repository.dart';
import '../datasources/task_list_local_data_source.dart';
import '../models/task_list_hive_model.dart';

class TaskListRepositoryImpl implements TaskListRepository {
  final TaskListLocalDataSource localDataSource;

  TaskListRepositoryImpl({required this.localDataSource});

  TaskList _fromHive(TaskListHiveModel model) =>
      TaskList(id: model.id, name: model.name, createdAt: model.createdAt);

  TaskListHiveModel _toHive(TaskList list) => TaskListHiveModel(
    id: list.id,
    name: list.name,
    createdAt: list.createdAt,
  );

  @override
  Future<TaskList> addList(TaskList list) async {
    final saved = await localDataSource.addList(_toHive(list));
    return _fromHive(saved);
  }

  @override
  Future<void> deleteList(String id) => localDataSource.deleteList(id);

  @override
  Future<List<TaskList>> getAllLists() async {
    final models = await localDataSource.getLists();
    return models.map(_fromHive).toList();
  }

  @override
  Future<void> renameList(String id, String name) =>
      localDataSource.renameList(id, name);
}
