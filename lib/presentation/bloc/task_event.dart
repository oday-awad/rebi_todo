part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskStarted extends TaskEvent {
  const TaskStarted();
}

class TaskAdded extends TaskEvent {
  final Task task;
  const TaskAdded(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskEvent {
  final Task task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskEvent {
  final String id;
  const TaskDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TaskToggled extends TaskEvent {
  final String id;
  const TaskToggled(this.id);

  @override
  List<Object?> get props => [id];
}
