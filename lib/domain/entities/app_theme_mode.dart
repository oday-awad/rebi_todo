/// App-level theme mode that is independent of Flutter UI types.
///
/// We keep this enum in the domain layer (instead of using `ThemeMode`)
/// to preserve separation between UI/framework and business logic.
enum AppThemeMode { system, light, dark }

/// Raw (persisted) mapping helpers.
extension AppThemeModeRawX on AppThemeMode {
  /// Stable string value to persist in storage.
  String get raw => switch (this) {
    AppThemeMode.system => 'system',
    AppThemeMode.light => 'light',
    AppThemeMode.dark => 'dark',
  };

  /// Parse from persisted value. Defaults to [AppThemeMode.system].
  static AppThemeMode fromRaw(String? raw) => switch (raw) {
    'light' => AppThemeMode.light,
    'dark' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
}

