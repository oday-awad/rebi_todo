import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/task_local_data_source.dart';
import '../../data/models/task_hive_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_done.dart';
import '../../domain/usecases/update_task.dart';

final sl = GetIt.instance;

// Registers app-wide dependencies.
Future<void> initDependencies() async {
  // Boxes
  final taskBox = await Hive.openBox<TaskHiveModel>('tasks_box');

  // Data sources
  sl.registerLazySingleton(() => TaskLocalDataSource(taskBox));

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleDone(sl()));
}
