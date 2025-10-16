import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/task_list.dart';
import '../../domain/usecases/get_tasks.dart';
import '../bloc/task_lists_cubit.dart';
import '../bloc/task_bloc.dart';
import 'home_page.dart';

class _ListCounts {
  final int active;
  final int done;
  final int archived;

  const _ListCounts({
    required this.active,
    required this.done,
    required this.archived,
  });
}

class TaskListsPage extends StatelessWidget {
  const TaskListsPage({super.key});

  Future<_ListCounts> _listCounts(String listId) async {
    final getTasks = GetIt.I<GetTasks>();
    final results = await Future.wait([
      getTasks(listId: listId), // non-archived
      getTasks(listId: listId, archived: true), // archived
    ]);
    final nonArchived = results[0];
    final archived = results[1];
    final active = nonArchived.where((t) => !t.isDone).length;
    final done = nonArchived.where((t) => t.isDone).length;
    return _ListCounts(active: active, done: done, archived: archived.length);
  }

  Future<void> _createList(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('New list'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'List name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final saved = await context.read<TaskListsCubit>().create(name);
    if (saved != null) {
      _openList(context, saved.id);
    }
  }

  Future<void> _renameList(BuildContext context, TaskList list) async {
    final controller = TextEditingController(text: list.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Rename list'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'List name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == list.name) return;
    await context.read<TaskListsCubit>().rename(list.id, name);
  }

  Future<void> _deleteList(BuildContext context, TaskList list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete list'),
        content: Text(
          'Delete "${list.name}"? This removes the list, not tasks.',
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
      await context.read<TaskListsCubit>().remove(list.id);
    }
  }

  void _openList(BuildContext context, String listId) {
    context.read<TaskListsCubit>().select(listId);
    context.read<TaskBloc>().add(TaskStarted(listId));
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop<String>(listId);
    } else {
      nav.push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<TaskBloc>()),
              BlocProvider.value(value: context.read<TaskListsCubit>()),
            ],
            child: const HomePage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Lists')),
      body: BlocBuilder<TaskListsCubit, TaskListsState>(
        builder: (context, state) {
          if (state.loading && state.lists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No lists yet'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _createList(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create list'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: state.lists.length,
            itemBuilder: (context, index) {
              final list = state.lists[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: FutureBuilder<_ListCounts>(
                  future: _listCounts(list.id),
                  builder: (context, snapshot) {
                    final counts = snapshot.data;
                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openList(context, list.id),
                        child: ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: Text(
                            list.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: -8,
                              children: [
                                _CountChip(
                                  label: 'Active',
                                  value: counts?.active,
                                ),
                                _CountChip(label: 'Done', value: counts?.done),
                                _CountChip(
                                  label: 'Archived',
                                  value: counts?.archived,
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'rename') {
                                _renameList(context, list);
                              } else if (value == 'delete') {
                                _deleteList(context, list);
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createList(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int? value;

  const _CountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text('$label: ${value ?? '…'}');
  }
}
