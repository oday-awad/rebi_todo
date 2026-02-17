import '../entities/app_theme_mode.dart';

/// Repository contract for app-wide user settings.
abstract class AppSettingsRepository {
  /// Returns the persisted theme mode. Defaults to [AppThemeMode.system].
  Future<AppThemeMode> getThemeMode();

  /// Persists the selected theme mode.
  Future<void> setThemeMode(AppThemeMode mode);
}

