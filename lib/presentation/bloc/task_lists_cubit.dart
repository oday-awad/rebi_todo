import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_list.dart';
import '../../domain/usecases/task_lists.dart';

class TaskListsState extends Equatable {
  final List<TaskList> lists;
  final String? selectedListId;
  final bool loading;
  final String? errorMessage;

  const TaskListsState({
    required this.lists,
    required this.selectedListId,
    required this.loading,
    this.errorMessage,
  });

  const TaskListsState.initial()
    : lists = const [],
      selectedListId = null,
      loading = false,
      errorMessage = null;

  TaskListsState copyWith({
    List<TaskList>? lists,
    String? selectedListId,
    bool? loading,
    String? errorMessage,
  }) {
    return TaskListsState(
      lists: lists ?? this.lists,
      selectedListId: selectedListId ?? this.selectedListId,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [lists, selectedListId, loading, errorMessage];
}

class TaskListsCubit extends Cubit<TaskListsState> {
  final GetTaskLists getTaskLists;
  final AddTaskList addTaskList;
  final RenameTaskList renameTaskList;
  final DeleteTaskList deleteTaskList;

  TaskListsCubit({
    required this.getTaskLists,
    required this.addTaskList,
    required this.renameTaskList,
    required this.deleteTaskList,
  }) : super(const TaskListsState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final lists = await getTaskLists();
      final selected =
          state.selectedListId ?? (lists.isNotEmpty ? lists.first.id : null);
      emit(
        state.copyWith(lists: lists, selectedListId: selected, loading: false),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  void select(String listId) {
    emit(state.copyWith(selectedListId: listId));
  }

  Future<TaskList?> create(String name) async {
    final list = TaskList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    final saved = await addTaskList(list);
    await load();
    return saved;
  }

  Future<void> rename(String id, String name) async {
    await renameTaskList(id, name);
    await load();
  }

  Future<void> remove(String id) async {
    await deleteTaskList(id);
    await load();
  }
}
