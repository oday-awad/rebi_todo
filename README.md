## rebi_todo

Clean Architecture Flutter To‑Do app using Hive for local storage, BLoC for state management, and get_it for dependency injection. Built with Material 3.

### Features
- **Clean architecture**: `presentation` / `domain` / `data` layers
- **Local storage**: Hive with a hand‑written TypeAdapter (no build_runner needed)
- **State management**: `flutter_bloc`
- **Dependency injection**: `get_it`
- **Material 3 UI**
- **Settings**: Theme selector (Light / Dark / System) persisted locally
- **CRUD**: Add, Edit, Delete, Toggle Done
- **Multiple lists**: Create/select separate lists (e.g. Shopping, Learning)
- **Delete confirmation**: Prompt before deleting (swipe or menu)
- **Smooth scrolling**: List preserves scroll position when toggling items
- **Archive**: Archive/unarchive tasks; view archived tasks per list

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
      app_settings_local_data_source.dart
      task_local_data_source.dart
      task_list_local_data_source.dart
    models/
      task_hive_model.dart
      task_hive_model.g.dart   # Hand-written Hive adapter
      task_list_hive_model.dart
      task_list_hive_model.g.dart
    repositories/
      app_settings_repository_impl.dart
      task_repository_impl.dart
      task_list_repository_impl.dart
  domain/
    entities/
      app_theme_mode.dart
      task.dart
      task_list.dart
    repositories/
      app_settings_repository.dart
      task_repository.dart
      task_list_repository.dart
    usecases/
      add_task.dart
      update_task.dart
      delete_task.dart
      get_theme_mode.dart
      get_tasks.dart
      set_theme_mode.dart
      toggle_done.dart
      task_lists.dart
  presentation/
    bloc/
      task_bloc.dart
      task_event.dart
      task_state.dart
      task_lists_cubit.dart
      theme_cubit.dart
    pages/
      home_page.dart
      settings_page.dart
      task_form_page.dart
    widgets/
      task_tile.dart
      theme_mode_selector.dart
  main.dart
```

### Key implementation notes
- **Hive setup**: Adapters are registered in `main.dart` via `Hive.registerAdapter(TaskHiveModelAdapter())` and `Hive.registerAdapter(TaskListHiveModelAdapter())`. Boxes: `tasks_box`, `task_lists_box`.
- **DI**: All dependencies are wired in `core/di/injection_container.dart`, called during app startup.
- **IDs**: All IDs are Strings (e.g. `DateTime.now().millisecondsSinceEpoch.toString()`), including `Task.id`, `Task.listId`, and `TaskList.id`.
- **Repository**: `TaskRepositoryImpl` bridges domain entities and Hive models.
- **State management**: `TaskBloc` exposes events for start, add, update, delete, and toggle.
- **Lists management**: `TaskListsCubit` manages list CRUD and selection; `TaskBloc` loads tasks filtered by the selected list.

### Usage
- Home shows the current list's tasks with a checkbox to mark as done.
- Tap the list icon in the app bar to select or create a list.
- Tap the Floating Action Button to add a task to the selected list.
- Tap a task to edit it.
- Use the delete icon on a task to remove it.

### Tech stack
- Flutter, Dart
- Hive, hive_flutter
- flutter_bloc, equatable
- get_it

### Troubleshooting
- If you see an error about desktop not being configured, follow the optional Desktop steps above or run on a mobile device/emulator.
- If you changed schemas and see Hive adapter type errors, do a full restart. Legacy tasks are migrated at read time and assigned to the `default` list.
