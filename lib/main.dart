import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart';
import 'data/models/task_hive_model.dart';
import 'presentation/bloc/task_bloc.dart';
import 'presentation/bloc/task_lists_cubit.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/pages/task_lists_page.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/get_theme_mode.dart';
import 'domain/usecases/get_tasks.dart';
import 'domain/usecases/set_theme_mode.dart';
import 'domain/usecases/toggle_done.dart';
import 'domain/usecases/toggle_archive.dart';
import 'domain/usecases/update_task.dart';
import 'domain/usecases/move_task.dart';
import 'domain/usecases/task_lists.dart';
import 'data/models/task_list_hive_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveModelAdapter());
  Hive.registerAdapter(TaskListHiveModelAdapter());
  // Initialize DI and open boxes
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final getTasks = GetIt.I<GetTasks>();
    final addTask = GetIt.I<AddTask>();
    final updateTask = GetIt.I<UpdateTask>();
    final deleteTask = GetIt.I<DeleteTask>();
    final toggleDone = GetIt.I<ToggleDone>();
    final toggleArchive = GetIt.I<ToggleArchive>();
    final moveTask = GetIt.I<MoveTask>();
    final getThemeMode = GetIt.I<GetThemeMode>();
    final setThemeMode = GetIt.I<SetThemeMode>();

    // Provide ThemeCubit ABOVE MaterialApp so it is accessible to all routes.
    return BlocProvider(
      create: (_) =>
          ThemeCubit(getThemeMode: getThemeMode, setThemeMode: setThemeMode)
            ..load(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Rebi TODO',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E1E2C),
                elevation: 2,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.deepPurple.shade300,
                foregroundColor: Colors.white,
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFF2A2A3E),
              ),
            ),
            themeMode: themeState.mode.toFlutterThemeMode(),
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => TaskListsCubit(
                    getTaskLists: GetIt.I<GetTaskLists>(),
                    addTaskList: GetIt.I<AddTaskList>(),
                    renameTaskList: GetIt.I<RenameTaskList>(),
                    deleteTaskList: GetIt.I<DeleteTaskList>(),
                    reorderTaskLists: GetIt.I<ReorderTaskLists>(),
                    updateTaskListIcon: GetIt.I<UpdateTaskListIcon>(),
                  )..load(),
                ),
                BlocProvider(
                  create: (_) => TaskBloc(
                    getTasks: getTasks,
                    addTask: addTask,
                    updateTask: updateTask,
                    deleteTask: deleteTask,
                    toggleDone: toggleDone,
                    toggleArchive: toggleArchive,
                    moveTask: moveTask,
                  ),
                ),
              ],
              child: const TaskListsPage(),
            ),
          );
        },
      ),
    );
  }
}
