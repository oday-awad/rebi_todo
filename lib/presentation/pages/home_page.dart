import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import 'task_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: const TaskFormPage(),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: TaskFormPage(initial: task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: state.tasks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return ListTile(
                onTap: () => _openEdit(context, task),
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (_) =>
                      context.read<TaskBloc>().add(TaskToggled(task.id)),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: task.description == null || task.description!.isEmpty
                    ? null
                    : Text(task.description!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      context.read<TaskBloc>().add(TaskDeleted(task.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
