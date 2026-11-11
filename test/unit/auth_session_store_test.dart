import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/data/auth_session_store.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  AuthSession buildSession({DateTime? expiresAt}) => AuthSession(
    accessToken: 'token.value',
    user: const AuthUser(id: 'user-1', email: 'aishah@example.com'),
    expiresAt: expiresAt ?? DateTime.utc(2030),
  );

  group('AuthSessionStore', () {
    test('round-trips a saved session', () async {
      final store = AuthSessionStore();
      final session = buildSession();

      await store.save(session);
      final restored = await store.read();

      expect(restored, isNotNull);
      expect(restored!.accessToken, 'token.value');
      expect(restored.user.id, 'user-1');
      expect(restored.user.email, 'aishah@example.com');
      expect(restored.expiresAt, session.expiresAt);
    });

    test('returns null when nothing is stored', () async {
      expect(await AuthSessionStore().read(), isNull);
    });

    test('clears the stored session', () async {
      final store = AuthSessionStore();
      await store.save(buildSession());

      await store.clear();

      expect(await store.read(), isNull);
    });

    test('tolerates a malformed payload', () async {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'lextari.session', value: 'not-json');
      expect(await AuthSessionStore().read(), isNull);

      await storage.write(
        key: 'lextari.session',
        value:
            '{"accessToken":"","userId":"user-1","email":"a@b.co",'
            '"expiresAt":1893456000000}',
      );
      expect(await AuthSessionStore().read(), isNull);
    });

    test('overwrites a previous session', () async {
      final store = AuthSessionStore();
      await store.save(buildSession());
      await store.save(
        AuthSession(
          accessToken: 'second.token',
          user: const AuthUser(id: 'user-2', email: 'second@example.com'),
          expiresAt: DateTime.utc(2031),
        ),
      );

      final restored = await store.read();

      expect(restored!.accessToken, 'second.token');
      expect(restored.user.id, 'user-2');
    });
  });

  group('AuthSession.isExpired', () {
    test('is false for a future expiry', () {
      final session = buildSession(
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      expect(session.isExpired, isFalse);
    });

    test('is true for a past expiry', () {
      final session = buildSession(
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      expect(session.isExpired, isTrue);
    });
  });
}
