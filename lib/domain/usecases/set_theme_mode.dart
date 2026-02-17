import '../entities/app_theme_mode.dart';
import '../repositories/app_settings_repository.dart';

// Use case: persist selected theme mode
class SetThemeMode {
  final AppSettingsRepository repository;
  SetThemeMode(this.repository);

  Future<void> call(AppThemeMode mode) => repository.setThemeMode(mode);
}

