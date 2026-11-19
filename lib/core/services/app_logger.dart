import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static const String _name = 'LabLend';

  static void info(String message) {
    developer.log(message, name: _name, level: 800);
  }

  static void warning(String message) {
    developer.log(message, name: _name, level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
