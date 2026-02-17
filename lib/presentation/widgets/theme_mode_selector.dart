import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_mode.dart';

/// UI widget for selecting the app theme mode.
///
/// Kept in `presentation/widgets` to separate UI components from pages.
class ThemeModeSelector extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Flutter 3.32+: Radio widgets use a RadioGroup ancestor
    // (instead of passing groupValue/onChanged to each tile).
    return RadioGroup<AppThemeMode>(
      groupValue: selected,
      onChanged: (v) => v == null ? null : onChanged(v),
      child: const Column(
        children: [
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.system,
            title: Text('System'),
            subtitle: Text('Follow device settings'),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.light,
            title: Text('Light'),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.dark,
            title: Text('Dark'),
          ),
        ],
      ),
    );
  }
}

