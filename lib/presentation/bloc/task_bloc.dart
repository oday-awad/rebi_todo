import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_done.dart';
import '../../domain/usecases/toggle_archive.dart';
import '../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

// BLoC orchestrating CRUD operations
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleDone toggleDone;
  final ToggleArchive toggleArchive;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleDone,
    required this.toggleArchive,
  }) : super(const TaskState.initial()) {
    on<TaskStarted>(_onStarted);
    on<TaskAdded>(_onAdded);
    on<TaskUpdated>(_onUpdated);
    on<TaskDeleted>(_onDeleted);
    on<TaskToggled>(_onToggled);
    on<TaskArchiveToggled>(_onArchiveToggled);
  }

  List<Task> _sortTasks(List<Task> tasks) {
    final sorted = [...tasks];
    sorted.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1; // undone first
      return b.createdAt.compareTo(a.createdAt); // newest first within group
    });
    return sorted;
  }

  Future<void> _onStarted(TaskStarted event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final tasks = await getTasks(listId: event.listId);
      emit(
        state.copyWith(status: TaskStatus.success, tasks: _sortTasks(tasks)),
      );
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdded(TaskAdded event, Emitter<TaskState> emit) async {
    try {
      final created = await addTask(event.task);
      // Prevent duplicates if list was already updated elsewhere
      final hasExisting = state.tasks.any((t) => t.id == created.id);
      final updated = hasExisting
          ? state.tasks.map((t) => t.id == created.id ? created : t).toList()
          : [created, ...state.tasks];
      emit(state.copyWith(tasks: _sortTasks(updated)));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdated(TaskUpdated event, Emitter<TaskState> emit) async {
    try {
      await updateTask(event.task);
      final updated = state.tasks
          .map((t) => t.id == event.task.id ? event.task : t)
          .toList();
      emit(state.copyWith(tasks: _sortTasks(updated)));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    try {
      await deleteTask(event.id);
      final updated = state.tasks.where((t) => t.id != event.id).toList();
      emit(state.copyWith(tasks: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggled(TaskToggled event, Emitter<TaskState> emit) async {
    try {
      await toggleDone(event.id);
      final updated = state.tasks
          .map((t) => t.id == event.id ? t.copyWith(isDone: !t.isDone) : t)
          .toList();
      emit(state.copyWith(tasks: _sortTasks(updated)));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onArchiveToggled(
    TaskArchiveToggled event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await toggleArchive(event.id);
      final updated = state.tasks
          .where((t) => t.id != event.id) // remove from current list (active)
          .toList();
      emit(state.copyWith(tasks: _sortTasks(updated)));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
