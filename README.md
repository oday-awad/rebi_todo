## rebi_todo

Clean Architecture Flutter To‑Do app using Hive for local storage, BLoC for state management, and get_it for dependency injection. Built with Material 3.

### Features
- **Clean architecture**: `presentation` / `domain` / `data` layers
- **Local storage**: Hive with a hand‑written TypeAdapter (no build_runner needed)
- **State management**: `flutter_bloc`
- **Dependency injection**: `get_it`
- **Material 3 UI**
- **CRUD**: Add, Edit, Delete, Toggle Done

### Requirements
- Flutter (stable channel). Tested with Flutter 3.32.x and Dart 3.8.x

### Getting started
```bash
flutter pub get
flutter run
```

If you want to run on a specific device:
```bash
flutter devices
flutter run -d <device_id>
```

Desktop (optional): This project is mobile‑first. To add Windows/macOS/Linux support locally, enable the platform and create the host projects:
```bash
# Example for Windows
flutter config --enable-windows-desktop
flutter create .
flutter run -d windows
```

### Project structure
```text
lib/
  core/
    di/
      injection_container.dart
  data/
    datasources/
      task_local_data_source.dart
    models/
      task_hive_model.dart
      task_hive_model.g.dart   # Hand-written Hive adapter
    repositories/
      task_repository_impl.dart
  domain/
    entities/
      task.dart
    repositories/
      task_repository.dart
    usecases/
      add_task.dart
      update_task.dart
      delete_task.dart
      get_tasks.dart
      toggle_done.dart
  presentation/
    bloc/
      task_bloc.dart
      task_event.dart
      task_state.dart
    pages/
      home_page.dart
      task_form_page.dart
    widgets/
      task_tile.dart
  main.dart
```

### Key implementation notes
- **Hive setup**: Adapter is registered in `main.dart` via `Hive.registerAdapter(TaskHiveModelAdapter())`. Box name: `tasks_box`.
- **DI**: All dependencies are wired in `core/di/injection_container.dart`, called during app startup.
- **IDs**: Tasks use `DateTime.now().millisecondsSinceEpoch` as a unique `id`.
- **Repository**: `TaskRepositoryImpl` bridges domain entities and Hive models.
- **State management**: `TaskBloc` exposes events for start, add, update, delete, and toggle.

### Usage
- Home shows a list of tasks with a checkbox to mark as done.
- Tap the Floating Action Button to add a task.
- Tap a task to edit it.
- Use the delete icon on a task to remove it.

### Tech stack
- Flutter, Dart
- Hive, hive_flutter
- flutter_bloc, equatable
- get_it

### Troubleshooting
- If you see an error about desktop not being configured, follow the optional Desktop steps above or run on a mobile device/emulator.
