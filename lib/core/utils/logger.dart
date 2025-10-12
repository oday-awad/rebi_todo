import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Simple colored logger for pretty console output.
/// Uses ANSI colors in debug builds; no-ops in release by default.
class Log {
  Log._();

  /// Enable/disable logging globally.
  static bool enabled = kDebugMode;

  /// Enable/disable ANSI colors. Some terminals may not support colors.
  static bool colors = true;

  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _grey = '\x1B[90m';

  static void v(String message, {String? tag}) =>
      _log(level: 'VERBOSE', color: _grey, message: message, tag: tag);

  static void d(String message, {String? tag}) =>
      _log(level: 'DEBUG', color: _blue, message: message, tag: tag);

  static void i(String message, {String? tag}) =>
      _log(level: 'INFO', color: _cyan, message: message, tag: tag);

  static void s(String message, {String? tag}) =>
      _log(level: 'SUCCESS', color: _green, message: message, tag: tag);

  static void w(String message, {String? tag}) =>
      _log(level: 'WARN', color: _yellow, message: message, tag: tag);

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    level: 'ERROR',
    color: _red,
    message: message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
  );

  static void json(Object? data, {String? tag, String level = 'DEBUG'}) {
    if (!enabled) return;
    String pretty;
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      if (data is String) {
        pretty = encoder.convert(jsonDecode(data));
      } else {
        pretty = encoder.convert(data);
      }
    } catch (_) {
      pretty = data.toString();
    }
    _log(level: level, color: _magenta, message: pretty, tag: tag);
  }

  static void _log({
    required String level,
    required String color,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) return;
    final time = DateTime.now().toIso8601String();
    final levelStr = colors ? '$_bold$color$level$_reset' : level;
    final timeStr = colors ? '$_dim$time$_reset' : time;
    final tagStr = tag == null
        ? ''
        : ' ${colors ? _bold : ''}[$tag]${colors ? _reset : ''}';
    final header = '$timeStr $levelStr$tagStr';

    // Split long logs to avoid truncation
    for (final line in (message).split('\n')) {
      debugPrint('$header ${colors ? _bold : ''}$line${colors ? _reset : ''}');
    }
    if (error != null) {
      debugPrint(
        '$header ${colors ? _red : ''}Error: $error${colors ? _reset : ''}',
      );
    }
    if (stackTrace != null) {
      for (final line in stackTrace.toString().split('\n')) {
        if (line.trim().isEmpty) continue;
        debugPrint(
          '$header ${colors ? _grey : ''}$line${colors ? _reset : ''}',
        );
      }
    }
  }
}
