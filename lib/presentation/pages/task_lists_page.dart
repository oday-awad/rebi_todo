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

class TaskListsPage extends StatefulWidget {
  const TaskListsPage({super.key});

  @override
  State<TaskListsPage> createState() => _TaskListsPageState();
}

class _TaskListsPageState extends State<TaskListsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      // Scrolling down
      if (_isFabVisible) {
        setState(() => _isFabVisible = false);
      }
    } else if (currentOffset < _lastScrollOffset || currentOffset < 50) {
      // Scrolling up or near top
      if (!_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    }
    _lastScrollOffset = currentOffset;
  }

  Widget _buildIcon(int? iconCodePoint) {
    if (iconCodePoint == null) {
      return const Icon(Icons.list_alt);
    }
    // ignore: avoid_dynamic_calls, prefer_const_constructors
    return Icon(IconData(iconCodePoint, fontFamily: 'MaterialIcons'));
  }

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
    int? selectedIcon;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New list'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'List name'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Choose an icon (optional)'),
                const SizedBox(height: 8),
                _IconPicker(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) {
                    setState(() => selectedIcon = icon);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx, {
                'name': controller.text.trim(),
                'icon': selectedIcon,
              }),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (result == null || result['name'] == null || result['name'].isEmpty) {
      return;
    }
    final saved = await context.read<TaskListsCubit>().create(
      result['name'] as String,
      iconCodePoint: result['icon'] as int?,
    );
    if (saved != null) {
      _openList(context, saved.id);
    }
  }

  Future<void> _renameList(BuildContext context, TaskList list) async {
    final controller = TextEditingController(text: list.name);
    int? selectedIcon = list.iconCodePoint;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit list'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'List name'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Choose an icon (optional)'),
                const SizedBox(height: 8),
                _IconPicker(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) {
                    setState(() => selectedIcon = icon);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx, {
                'name': controller.text.trim(),
                'icon': selectedIcon,
              }),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    final name = result['name'] as String;
    final icon = result['icon'] as int?;
    if (name.isEmpty || (name == list.name && icon == list.iconCodePoint)) {
      return;
    }
    if (name != list.name) {
      await context.read<TaskListsCubit>().rename(list.id, name);
    }
    if (icon != list.iconCodePoint) {
      await context.read<TaskListsCubit>().updateIcon(list.id, icon);
    }
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
          return ReorderableListView.builder(
            scrollController: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: state.lists.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final lists = List<TaskList>.from(state.lists);
              final item = lists.removeAt(oldIndex);
              lists.insert(newIndex, item);
              final orderedIds = lists.map((l) => l.id).toList();
              context.read<TaskListsCubit>().reorder(orderedIds);
            },
            itemBuilder: (context, index) {
              final list = state.lists[index];
              return Padding(
                key: ValueKey(list.id),
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
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.drag_handle, color: Colors.grey),
                              const SizedBox(width: 8),
                              _buildIcon(list.iconCodePoint),
                            ],
                          ),
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

      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: () => _createList(context),
          child: const Icon(Icons.add),
        ),
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

class _IconPicker extends StatelessWidget {
  final int? selectedIcon;
  final ValueChanged<int?> onIconSelected;

  const _IconPicker({required this.selectedIcon, required this.onIconSelected});

  static final List<int> _icons = [
    Icons.work.codePoint,
    Icons.home.codePoint,
    Icons.shopping_cart.codePoint,
    Icons.fitness_center.codePoint,
    Icons.school.codePoint,
    Icons.favorite.codePoint,
    Icons.star.codePoint,
    Icons.lightbulb.codePoint,
    Icons.music_note.codePoint,
    Icons.movie.codePoint,
    Icons.restaurant.codePoint,
    Icons.local_gas_station.codePoint,
    Icons.flight.codePoint,
    Icons.beach_access.codePoint,
    Icons.sports_soccer.codePoint,
    Icons.book.codePoint,
    Icons.computer.codePoint,
    Icons.phone.codePoint,
    Icons.car_rental.codePoint,
    Icons.pets.codePoint,
    Icons.local_hospital.codePoint,
    Icons.account_balance.codePoint,
    Icons.attach_money.codePoint,
    Icons.cake.codePoint,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () => onIconSelected(null),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedIcon == null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                width: selectedIcon == null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.close,
              color: selectedIcon == null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
        ..._icons.map((iconCode) {
          final isSelected = selectedIcon == iconCode;
          return GestureDetector(
            onTap: () => onIconSelected(iconCode),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _IconPicker._buildIcon(iconCode),
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildIcon(int iconCode) {
    // ignore: avoid_dynamic_calls, prefer_const_constructors
    return Icon(IconData(iconCode, fontFamily: 'MaterialIcons'));
  }
}
