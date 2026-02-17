import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/set_theme_mode.dart';

class ThemeState extends Equatable {
  final AppThemeMode mode;
  final bool loading;
  final String? errorMessage;

  const ThemeState({
    required this.mode,
    required this.loading,
    this.errorMessage,
  });

  const ThemeState.initial()
      : mode = AppThemeMode.system,
        loading = false,
        errorMessage = null;

  ThemeState copyWith({
    AppThemeMode? mode,
    bool? loading,
    String? errorMessage,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [mode, loading, errorMessage];
}

/// Maps domain enum to Flutter's [ThemeMode] for MaterialApp.
extension ThemeModeX on AppThemeMode {
  ThemeMode toFlutterThemeMode() => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}

/// Cubit responsible for loading and persisting the selected theme mode.
class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeMode getThemeMode;
  final SetThemeMode setThemeMode;

  ThemeCubit({required this.getThemeMode, required this.setThemeMode})
      : super(const ThemeState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final mode = await getThemeMode();
      emit(state.copyWith(mode: mode, loading: false));
    } catch (e, s) {
      Log.e(
        'Failed to load theme mode',
        tag: 'ThemeCubit',
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> select(AppThemeMode mode) async {
    if (mode == state.mode) return;
    emit(state.copyWith(mode: mode, errorMessage: null));
    try {
      await setThemeMode(mode);
    } catch (e, s) {
      Log.e(
        'Failed to persist theme mode: ${mode.raw}',
        tag: 'ThemeCubit',
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

