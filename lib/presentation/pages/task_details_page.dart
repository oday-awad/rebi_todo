import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_lists_cubit.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'task_form_page.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
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
                      BlocProvider.value(
                          value: context.read<TaskListsCubit>()),
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
                  content:
                      const Text('Are you sure you want to delete this task?'),
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

          // Task was deleted or moved.
          if (current == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 48, color: colors.outline),
                    const SizedBox(height: 16),
                    const Text('This task is no longer available.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Scrollable content.
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Status chip ──
                      _StatusChip(isDone: current.isDone),
                      const SizedBox(height: 16),

                      // ── Title ──
                      Text(
                        current.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Description ──
                      if (current.description != null &&
                          current.description!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            current.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Images ──
                      if (current.imagePaths.isNotEmpty) ...[
                        Text('Attachments',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            )),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: current.imagePaths.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final imagePath = current!.imagePaths[index];
                              return GestureDetector(
                                onTap: () => FullScreenImageViewer.open(
                                  context,
                                  imagePaths: current!.imagePaths,
                                  initialIndex: index,
                                  heroTagPrefix: 'details_img',
                                ),
                                child: Hero(
                                  tag: 'details_img_$index',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(imagePath),
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 180,
                                        height: 180,
                                        color: colors.surfaceContainerHighest,
                                        child: Icon(Icons.broken_image,
                                            color: colors.outline),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Metadata row ──
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: colors.outline),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('h:mm a, EEE, dd/MM/yyyy')
                                .format(current.createdAt.toLocal()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.outline,
                            ),
                          ),
                          if (current.isArchived) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.archive_outlined,
                                size: 16, color: colors.outline),
                            const SizedBox(width: 4),
                            Text('Archived',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.outline,
                                )),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom action bar ──
              _ActionBar(
                task: current,
                onToggleDone: () =>
                    context.read<TaskBloc>().add(TaskToggled(current!.id)),
                onArchive: () {
                  context
                      .read<TaskBloc>()
                      .add(TaskArchiveToggled(current!.id));
                  Navigator.of(context).pop();
                },
                onMove: () => _showMoveDialog(context, current!),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Shows a dialog to pick a destination list.
  Future<void> _showMoveDialog(BuildContext context, Task task) async {
    final listsState = context.read<TaskListsCubit>().state;
    if (listsState.lists.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one other list to move this task.'),
        ),
      );
      return;
    }
    final selectedListId = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Move to list'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: listsState.lists.length,
            itemBuilder: (ctx, index) {
              final list = listsState.lists[index];
              if (list.id == task.listId) return const SizedBox.shrink();
              return ListTile(
                title: Text(list.name),
                onTap: () => Navigator.pop(ctx, list.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selectedListId != null) {
      // ignore: use_build_context_synchronously
      context.read<TaskBloc>().add(
            TaskMoved(taskId: task.id, newListId: selectedListId),
          );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Colored chip showing Done / To Do status.
class _StatusChip extends StatelessWidget {
  final bool isDone;
  const _StatusChip({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDone
            ? colors.primaryContainer
            : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isDone
                ? colors.onPrimaryContainer
                : colors.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            isDone ? 'Done' : 'To Do',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDone
                  ? colors.onPrimaryContainer
                  : colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar with toggle, move, and archive buttons.
class _ActionBar extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleDone;
  final VoidCallback onArchive;
  final VoidCallback onMove;

  const _ActionBar({
    required this.task,
    required this.onToggleDone,
    required this.onArchive,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(top: BorderSide(color: colors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          // Toggle done – primary action.
          Expanded(
            child: FilledButton.icon(
              onPressed: onToggleDone,
              icon: Icon(task.isDone ? Icons.undo : Icons.check),
              label: Text(task.isDone ? 'Undo' : 'Done'),
            ),
          ),
          const SizedBox(width: 10),
          // Move.
          IconButton.outlined(
            tooltip: 'Move to list',
            onPressed: onMove,
            icon: const Icon(Icons.drive_file_move_outline),
          ),
          const SizedBox(width: 8),
          // Archive.
          IconButton.outlined(
            tooltip: task.isArchived ? 'Unarchive' : 'Archive',
            onPressed: onArchive,
            icon: Icon(
              task.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
