import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_lists_cubit.dart';
import 'task_form_page.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Use the latest task from bloc state to avoid stale initial values
              Task? latest;
              final state = context.read<TaskBloc>().state;
              for (final t in state.tasks) {
                if (t.id == task.id) {
                  latest = t;
                  break;
                }
              }
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<TaskBloc>()),
                      BlocProvider.value(value: context.read<TaskListsCubit>()),
                    ],
                    child: TaskFormPage(initial: latest ?? task),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  title: const Text('Delete task'),
                  content: const Text(
                    'Are you sure you want to delete this task?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dCtx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dCtx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // ignore: use_build_context_synchronously
                context.read<TaskBloc>().add(TaskDeleted(task.id));
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          Task? current;
          for (final t in state.tasks) {
            if (t.id == task.id) {
              current = t;
              break;
            }
          }
          if (current == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This task is no longer available.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  current.title,
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                current.isDone
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (current.description != null &&
                              current.description!.isNotEmpty)
                            Text(current.description!),
                          if (current.imagePaths.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Images:'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: current.imagePaths.map((imagePath) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text('Created: ${current.createdAt.toLocal()}'),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  context.read<TaskBloc>().add(
                                    TaskToggled(current!.id),
                                  );
                                },
                                icon: Icon(
                                  current.isDone ? Icons.undo : Icons.check,
                                ),
                                label: Text(
                                  current.isDone
                                      ? 'Mark as Undone'
                                      : 'Mark as Done',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final task = current!;
                                  final listsState =
                                      context.read<TaskListsCubit>().state;
                                  if (listsState.lists.length <= 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You need at least one other list to move this task.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final selectedListId = await showDialog<String>(
                                    context: context,
                                    builder: (dCtx) => AlertDialog(
                                      title: const Text('Move to List'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: listsState.lists.length,
                                          itemBuilder: (ctx, index) {
                                            final list =
                                                listsState.lists[index];
                                            if (list.id == task.listId) {
                                              return const SizedBox.shrink();
                                            }
                                            return ListTile(
                                              title: Text(list.name),
                                              onTap: () =>
                                                  Navigator.pop(ctx, list.id),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dCtx),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (selectedListId != null) {
                                    context.read<TaskBloc>().add(
                                          TaskMoved(
                                            taskId: task.id,
                                            newListId: selectedListId,
                                          ),
                                        );
                                    Navigator.of(context).pop();
                                  }
                                },
                                icon: const Icon(Icons.move_to_inbox),
                                label: const Text('Move to List'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<TaskBloc>().add(
                                    TaskArchiveToggled(current!.id),
                                  );
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.archive_outlined),
                                label: const Text('Archive'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
