import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/core/errors/failures.dart';

void main() {
  group('Failure classes', () {
    group('NetworkFailure', () {
      test('is a Failure', () {
        expect(const NetworkFailure(), isA<Failure>());
      });

      test('is an Exception', () {
        expect(const NetworkFailure(), isA<Exception>());
      });
    });

    group('ApiFailure', () {
      test('holds statusCode and body', () {
        const failure = ApiFailure(500, 'Internal Server Error');
        expect(failure.statusCode, 500);
        expect(failure.body, 'Internal Server Error');
      });

      test('is a Failure', () {
        expect(const ApiFailure(404, ''), isA<Failure>());
      });
    });

    group('SessionExpiredFailure', () {
      test('is a Failure', () {
        expect(const SessionExpiredFailure(), isA<Failure>());
      });
    });

    group('AuthFailure', () {
      test('holds user-friendly message', () {
        const failure = AuthFailure('Email or password is incorrect.');
        expect(failure.message, 'Email or password is incorrect.');
      });

      test('is a Failure', () {
        expect(const AuthFailure('test'), isA<Failure>());
      });
    });

    group('UnknownFailure', () {
      test('holds original message', () {
        const failure = UnknownFailure('Something unexpected');
        expect(failure.message, 'Something unexpected');
      });

      test('is a Failure', () {
        expect(const UnknownFailure('x'), isA<Failure>());
      });
    });

    group('sealed class exhaustiveness', () {
      test('switch covers all subtypes', () {
        const failures = <Failure>[
          NetworkFailure(),
          ApiFailure(500, 'err'),
          SessionExpiredFailure(),
          AuthFailure('msg'),
          UnknownFailure('msg'),
        ];

        for (final failure in failures) {
          final result = switch (failure) {
            NetworkFailure() => 'network',
            ApiFailure() => 'api',
            SessionExpiredFailure() => 'session',
            AuthFailure() => 'auth',
            UnknownFailure() => 'unknown',
          };
          expect(result, isNotEmpty);
        }
      });
    });
  });
}
