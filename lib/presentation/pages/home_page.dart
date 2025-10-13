import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_lists_cubit.dart';
import 'task_form_page.dart';
import 'archived_page.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  void _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<TaskBloc>()),
            BlocProvider.value(value: context.read<TaskListsCubit>()),
          ],
          child: const TaskFormPage(),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<TaskBloc>()),
            BlocProvider.value(value: context.read<TaskListsCubit>()),
          ],
          child: TaskFormPage(initial: task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TaskListsCubit, TaskListsState>(
          builder: (context, listState) {
            String? currentName;
            if (listState.lists.isNotEmpty) {
              final match = listState.lists.firstWhere(
                (l) => l.id == listState.selectedListId,
                orElse: () => listState.lists.first,
              );
              currentName = match.name;
            }
            return Text(currentName ?? 'Tasks');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              final listState = context.read<TaskListsCubit>().state;
              await showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Add list'),
                          leading: const Icon(Icons.add),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final controller = TextEditingController();
                            final name = await showDialog<String>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('New list'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: 'List name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(
                                      dCtx,
                                      controller.text.trim(),
                                    ),
                                    child: const Text('Create'),
                                  ),
                                ],
                              ),
                            );
                            if (name != null && name.isNotEmpty) {
                              final created = await context
                                  .read<TaskListsCubit>()
                                  .create(name);
                              if (created != null) {
                                context.read<TaskListsCubit>().select(
                                  created.id,
                                );
                                context.read<TaskBloc>().add(
                                  TaskStarted(created.id),
                                );
                              }
                            }
                          },
                        ),
                        for (final l in listState.lists)
                          ListTile(
                            leading: Icon(
                              l.id == listState.selectedListId
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                            ),
                            title: Text(l.name),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.read<TaskListsCubit>().select(l.id);
                              context.read<TaskBloc>().add(TaskStarted(l.id));
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Ensure we load tasks for the selected list when lists are ready
          final listsState = context.watch<TaskListsCubit>().state;
          if (listsState.selectedListId != null &&
              state.status == TaskStatus.initial) {
            context.read<TaskBloc>().add(
              TaskStarted(listsState.selectedListId!),
            );
          }
          if (state.status == TaskStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.inbox_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('No tasks yet. Tap + to add one.'),
                ],
              ),
            );
          }
          return ListView.builder(
            key: const PageStorageKey('tasks_list'),
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return TaskTile(
                task: task,
                onTap: () => _openEdit(context, task),
                onToggle: (_) =>
                    context.read<TaskBloc>().add(TaskToggled(task.id)),
                onDelete: () =>
                    context.read<TaskBloc>().add(TaskDeleted(task.id)),
                onArchiveToggle: () =>
                    context.read<TaskBloc>().add(TaskArchiveToggled(task.id)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archived tasks'),
                  onPressed: () async {
                    final listId = context
                        .read<TaskListsCubit>()
                        .state
                        .selectedListId;
                    if (listId == null) return;
                    await Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<TaskBloc>(),
                                ),
                                BlocProvider.value(
                                  value: context.read<TaskListsCubit>(),
                                ),
                              ],
                              child: ArchivedPage(listId: listId),
                            ),
                          ),
                        )
                        .then((value) {
                          context.read<TaskBloc>().add(TaskStarted(listId));
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
