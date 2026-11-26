import 'package:flutter_test/flutter_test.dart';
import 'package:lablend/core/services/app_logger.dart';

void main() {
  group('AppLogger Tests', () {
    test('info() should accept a normal message', () {
      expect(() => AppLogger.info('Informational message'), returnsNormally);
    });

    test('info() should accept an empty message', () {
      expect(() => AppLogger.info(''), returnsNormally);
    });

    test('info() should accept a long message', () {
      final message = 'LabLend information ' * 100;

      expect(() => AppLogger.info(message), returnsNormally);
    });

    test('warning() should accept a warning message', () {
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
    });

    test('warning() should accept an empty message', () {
      expect(() => AppLogger.warning(''), returnsNormally);
    });

    test('error() should accept an error message', () {
      expect(() => AppLogger.error('Error message'), returnsNormally);
    });

    test('error() should accept an error object', () {
      expect(
        () => AppLogger.error(
          'Something went wrong',
          error: Exception('Test exception'),
        ),
        returnsNormally,
      );
    });

    test('error() should accept a stack trace', () {
      expect(
        () =>
            AppLogger.error('Stack trace test', stackTrace: StackTrace.current),
        returnsNormally,
      );
    });

    test('error() should accept both error and stack trace', () {
      expect(
        () => AppLogger.error(
          'Complete error information',
          error: Exception('Test exception'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('error() should accept null error and stack trace', () {
      expect(
        () => AppLogger.error(
          'Error without additional details',
          error: null,
          stackTrace: null,
        ),
        returnsNormally,
      );
    });
  });
}
