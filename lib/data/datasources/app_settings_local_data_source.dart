import 'package:hive/hive.dart';

import '../../core/utils/logger.dart';

/// Local data source encapsulating Hive operations for app settings.
class AppSettingsLocalDataSource {
  static const String _themeModeKey = 'theme_mode';

  final Box<dynamic> settingsBox;

  AppSettingsLocalDataSource(this.settingsBox);

  /// Returns the stored theme mode string (`system`|`light`|`dark`) or null.
  String? getThemeModeRaw() {
    try {
      final raw = settingsBox.get(_themeModeKey);
      return raw is String ? raw : null;
    } catch (e, s) {
      Log.e(
        'Failed to read theme mode',
        tag: 'AppSettingsLocalDataSource',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  /// Persists the theme mode raw string.
  Future<void> setThemeModeRaw(String raw) async {
    try {
      await settingsBox.put(_themeModeKey, raw);
      Log.i('Theme mode saved: $raw', tag: 'AppSettingsLocalDataSource');
    } catch (e, s) {
      Log.e(
        'Failed to save theme mode: $raw',
        tag: 'AppSettingsLocalDataSource',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}

