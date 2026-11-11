import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide configuration values.
///
/// Values are read from the bundled `.env` file at runtime (see
/// [load], called during app startup). `--dart-define` values are used
/// as a fallback so CI/Production builds can inject secrets without a
/// `.env` file.
///
/// ## Setup
///
/// Copy `.env.example` to `.env` and fill in your values:
/// ```bash
/// cp .env.example .env
/// ```
///
/// Then just run the app normally:
/// ```bash
/// flutter run
/// ```
class AppConfig {
  AppConfig._();

  /// Whether `.env` was successfully loaded from the asset bundle.
  static bool _dotenvReady = false;

  /// Loads `.env` into [dotenv]. Must be called after
  /// `WidgetsFlutterBinding.ensureInitialized()` and before any getter
  /// below is read.
  ///
  /// Never hardcode secrets — use `.env` locally and CI environment
  /// variables (via `--dart-define`) in production.
  static Future<void> load() async {
    // `isOptional: true` keeps CI builds (which ship no `.env`) working —
    // getters below fall back to `--dart-define` values.
    await dotenv.load(isOptional: true);
    _dotenvReady = true;
  }

  /// Reads [key] from `.env`, falling back to the compile-time
  /// [fallback] (`String.fromEnvironment`).
  static String _value(String key, String fallback) {
    if (_dotenvReady) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  /// FastAPI backend base URL (no trailing slash).
  static String get apiUrl =>
      _value('API_URL', const String.fromEnvironment('API_URL'));

  /// FastAPI WebSocket URL.
  static String get wsUrl =>
      _value('WS_URL', const String.fromEnvironment('WS_URL'));

  /// Google web OAuth client ID used as the ID-token audience.
  static String get googleServerClientId => _value(
    'GOOGLE_SERVER_CLIENT_ID',
    const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
  );

  /// Lextari auth Worker base URL (no trailing slash).
  static String get authUrl =>
      _value('AUTH_URL', const String.fromEnvironment('AUTH_URL'));

  /// Hive box for offline cache.
  static const String telemetryCacheBox = 'telemetry_cache';

  /// Data older than this shows a stale indicator.
  static const Duration staleThreshold = Duration(minutes: 30);
}
