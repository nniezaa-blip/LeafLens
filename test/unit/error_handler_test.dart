import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/core/errors/error_handler.dart';
import 'package:lextari/core/errors/failures.dart';

void main() {
  // ErrorHandler._errorCounts is private and static — no way to reset
  // between tests. We test relative increments instead.

  group('ErrorHandler', () {
    group('handle', () {
      test('does not throw for any failure type', () {
        expect(
          () => ErrorHandler.handle(const NetworkFailure()),
          returnsNormally,
        );
        expect(
          () => ErrorHandler.handle(const ApiFailure(500, 'err')),
          returnsNormally,
        );
        expect(
          () => ErrorHandler.handle(const AuthFailure('msg')),
          returnsNormally,
        );
        expect(
          () => ErrorHandler.handle(const UnknownFailure('msg')),
          returnsNormally,
        );
      });

      test('increments count for same failure type', () {
        final before = ErrorHandler.errorCounts['NetworkFailure'] ?? 0;
        ErrorHandler.handle(const NetworkFailure());
        ErrorHandler.handle(const NetworkFailure());
        final after = ErrorHandler.errorCounts['NetworkFailure'] ?? 0;
        expect(after - before, 2);
      });

      test('increments different failure types separately', () {
        final beforeAuth = ErrorHandler.errorCounts['AuthFailure'] ?? 0;
        final beforeApi = ErrorHandler.errorCounts['ApiFailure'] ?? 0;
        ErrorHandler.handleSilent(const AuthFailure('x'));
        ErrorHandler.handleSilent(const ApiFailure(422, 'bad'));
        expect(
          (ErrorHandler.errorCounts['AuthFailure'] ?? 0) - beforeAuth,
          1,
        );
        expect(
          (ErrorHandler.errorCounts['ApiFailure'] ?? 0) - beforeApi,
          1,
        );
      });
    });

    group('handleSilent', () {
      test('does not throw', () {
        expect(
          () => ErrorHandler.handleSilent(const NetworkFailure()),
          returnsNormally,
        );
        expect(
          () => ErrorHandler.handleSilent(const ApiFailure(400, 'bad')),
          returnsNormally,
        );
        expect(
          () => ErrorHandler.handleSilent(const SessionExpiredFailure()),
          returnsNormally,
        );
      });

      test('increments count', () {
        final before = ErrorHandler.errorCounts['ApiFailure'] ?? 0;
        ErrorHandler.handleSilent(const ApiFailure(400, 'bad'));
        ErrorHandler.handleSilent(const ApiFailure(400, 'bad'));
        final after = ErrorHandler.errorCounts['ApiFailure'] ?? 0;
        expect(after - before, 2);
      });
    });

    group('errorCounts', () {
      test('returns Map<String, int>', () {
        expect(ErrorHandler.errorCounts, isA<Map<String, int>>());
      });

      test('is unmodifiable', () {
        expect(
          () => ErrorHandler.errorCounts['New'] = 1,
          throwsA(anything),
        );
      });
    });

    group('failure type routing', () {
      test('5xx ApiFailure does not throw', () {
        expect(
          () => ErrorHandler.handle(const ApiFailure(500, 'Internal')),
          returnsNormally,
        );
      });

      test('4xx ApiFailure does not throw', () {
        expect(
          () => ErrorHandler.handle(const ApiFailure(400, 'Bad Request')),
          returnsNormally,
        );
      });

      test('NetworkFailure does not throw', () {
        expect(
          () => ErrorHandler.handle(const NetworkFailure()),
          returnsNormally,
        );
      });
    });
  });
}
