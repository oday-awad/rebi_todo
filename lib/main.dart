import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart';
import 'data/models/task_hive_model.dart';
import 'presentation/bloc/task_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/get_tasks.dart';
import 'domain/usecases/toggle_done.dart';
import 'domain/usecases/update_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveModelAdapter());
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

    return MaterialApp(
      title: 'Rebi TODO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => TaskBloc(
          getTasks: getTasks,
          addTask: addTask,
          updateTask: updateTask,
          deleteTask: deleteTask,
          toggleDone: toggleDone,
        )..add(const TaskStarted()),
        child: const HomePage(),
      ),
    );
  }
}
