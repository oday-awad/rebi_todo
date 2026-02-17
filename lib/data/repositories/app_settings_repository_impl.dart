import '../../core/utils/logger.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings_local_data_source.dart';

/// Repository implementation bridging domain and data layers for settings.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsLocalDataSource localDataSource;

  AppSettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<AppThemeMode> getThemeMode() async {
    final raw = localDataSource.getThemeModeRaw();
    final mode = AppThemeModeRawX.fromRaw(raw);
    Log.d('Theme mode loaded: ${mode.raw}', tag: 'AppSettingsRepositoryImpl');
    return mode;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    await localDataSource.setThemeModeRaw(mode.raw);
  }
}

