import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_archive.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_tile.dart';

class ArchivedPage extends StatefulWidget {
  final String listId;
  const ArchivedPage({super.key, required this.listId});

  @override
  State<ArchivedPage> createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  Future<List<Task>> _load() =>
      GetIt.I<GetTasks>()(listId: widget.listId, archived: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived')),
      body: FutureBuilder<List<Task>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? const [];
          if (tasks.isEmpty) {
            return const Center(child: Text('No archived tasks'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task,
                onTap: () {},
                onToggle: (_) {},
                onDelete: () {
                  context.read<TaskBloc>().add(TaskDeleted(task.id));
                  setState(() {});
                },
                onArchiveToggle: () async {
                  await GetIt.I<ToggleArchive>()(task.id);
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
