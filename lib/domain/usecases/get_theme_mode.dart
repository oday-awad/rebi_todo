import '../entities/app_theme_mode.dart';
import '../repositories/app_settings_repository.dart';

// Use case: get persisted theme mode
class GetThemeMode {
  final AppSettingsRepository repository;
  GetThemeMode(this.repository);

  Future<AppThemeMode> call() => repository.getThemeMode();
}

