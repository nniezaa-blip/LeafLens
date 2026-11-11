import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lextari/features/auth/data/auth_api.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/data/auth_session_store.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';

/// In-memory stand-in for secure storage.
class FakeSessionStore implements AuthSessionStore {
  AuthSession? session;
  int clears = 0;

  @override
  Future<void> clear() async {
    clears++;
    session = null;
  }

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> save(AuthSession value) async {
    session = value;
  }
}

AuthSession buildSession({DateTime? expiresAt}) => AuthSession(
  accessToken: 'token.value',
  user: const AuthUser(id: 'user-1', email: 'aishah@example.com'),
  expiresAt: expiresAt ?? DateTime.now().toUtc().add(const Duration(hours: 1)),
);

AuthApi buildApi(MockClient client) =>
    AuthApi(baseUrl: 'https://auth.test', client: client);

void main() {
  group('AuthSessionManager', () {
    test('login persists and publishes the session', () async {
      final store = FakeSessionStore();
      final api = buildApi(
        MockClient(
          (request) async => http.Response(
            jsonEncode({
              'access_token': 'issued.token',
              'expires_in': 3600,
              'token_type': 'Bearer',
              'user': {'id': 'user-1', 'email': 'aishah@example.com'},
            }),
            200,
          ),
        ),
      );
      final manager = AuthSessionManager(api, store);

      final session = await manager.login(
        email: 'aishah@example.com',
        password: 'correcthorsebattery',
      );

      expect(session.accessToken, 'issued.token');
      expect(manager.currentSession?.user.id, 'user-1');
      expect(store.session?.accessToken, 'issued.token');
    });

    test('register maps the Worker error code', () async {
      final store = FakeSessionStore();
      final api = buildApi(
        MockClient(
          (request) async => http.Response(
            jsonEncode({'error': 'email_exists'}),
            409,
          ),
        ),
      );
      final manager = AuthSessionManager(api, store);

      await expectLater(
        manager.register(email: 'a@b.co', password: 'correcthorsebattery'),
        throwsA(
          isA<AuthException>()
              .having((error) => error.code, 'code', 'email_exists')
              .having((error) => error.statusCode, 'status', 409),
        ),
      );
      expect(manager.currentSession, isNull);
      expect(store.session, isNull);
    });

    test('restores an accepted, unexpired session', () async {
      final store = FakeSessionStore()..session = buildSession();
      final api = buildApi(
        MockClient(
          (request) async => http.Response(
            jsonEncode({'id': 'user-1', 'email': 'aishah@example.com'}),
            200,
          ),
        ),
      );
      final manager = AuthSessionManager(api, store);

      await manager.ensureRestored();

      expect(manager.currentSession?.accessToken, 'token.value');
    });

    test('drops an expired session without calling the Worker', () async {
      var called = false;
      final store = FakeSessionStore()
        ..session = buildSession(
          expiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 5),
          ),
        );
      final api = buildApi(
        MockClient((request) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );
      final manager = AuthSessionManager(api, store);

      await manager.ensureRestored();

      expect(manager.currentSession, isNull);
      expect(store.session, isNull);
      expect(called, isFalse);
    });

    test('drops a session the Worker rejects', () async {
      final store = FakeSessionStore()..session = buildSession();
      final api = buildApi(
        MockClient(
          (request) async =>
              http.Response(jsonEncode({'error': 'unauthorized'}), 401),
        ),
      );
      final manager = AuthSessionManager(api, store);

      await manager.ensureRestored();

      expect(manager.currentSession, isNull);
      expect(store.session, isNull);
    });

    test('keeps the session when the Worker is unreachable', () async {
      final store = FakeSessionStore()..session = buildSession();
      final api = buildApi(
        MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      final manager = AuthSessionManager(api, store);

      await manager.ensureRestored();

      expect(manager.currentSession?.accessToken, 'token.value');
    });

    test('logout clears local state even when the Worker fails', () async {
      final store = FakeSessionStore()..session = buildSession();
      final api = buildApi(
        MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      final manager = AuthSessionManager(api, store);
      await manager.ensureRestored();

      await manager.logout();

      expect(manager.currentSession, isNull);
      expect(store.session, isNull);
    });
  });
}
