import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/shared/notifications/notification_service.dart';

/// Centralised error handler implementing the two-tier logging system.
///
/// **Tier 1 — User-facing:** Calls [NotificationService] so the user sees
/// a meaningful message.
///
/// **Tier 2 — Metrics:** Counts every failure type in memory so the
/// dashboard can report "18 login failures since app start" for the thesis.
///
/// ## When to use which method
///
/// | Method | Shows toast | Counts | Use case |
/// |--------|------------|--------|----------|
/// | [handle] | Yes | Yes | Unexpected errors (server down, network lost) |
/// | [handleSilent] | No | Yes | Expected errors with their own UI |
class ErrorHandler {
  ErrorHandler._();

  // ── Metrics ────────────────────────────────────────────

  static final Map<String, int> _errorCounts = {};

  /// Snapshot of error counts by type since app start.
  /// Useful for the thesis methodology section showing error distribution.
  static Map<String, int> get errorCounts =>
      Map<String, int>.unmodifiable(_errorCounts);

  // ── Public API ─────────────────────────────────────────

  /// Full report: show user notification + count.
  ///
  /// Use this for errors the user should see and act on, e.g.:
  /// - "Server is not responding"
  /// - "Network connection lost"
  /// - "Something went wrong, try again"
  static void handle(Failure failure) {
    _count(failure);
    _notifyUser(failure);
  }

  /// Silent report: count only.
  ///
  /// Use this for expected errors that have their own UI handling:
  /// - Invalid credentials → login page shows inline error
  /// - Session expired → GoRouter redirects to login
  /// - Validation errors → form fields show individual messages
  static void handleSilent(Failure failure) {
    _count(failure);
  }

  // ── Metrics ────────────────────────────────────────────

  static void _count(Failure failure) {
    final key = failure.runtimeType.toString();
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
  }

  // ── User-facing notification ──────────────────────────

  static void _notifyUser(Failure failure) {
    switch (failure) {
      case NetworkFailure():
        NotificationService.error(
          'Connection lost',
          description: 'Check your internet and try again.',
        );

      case ApiFailure(statusCode: final code) when code >= 500:
        NotificationService.error(
          'Server error',
          description: 'Something went wrong on our end. Please try again.',
        );

      case ApiFailure(statusCode: final code) when code == 429:
        NotificationService.warning(
          'Too many requests',
          description: 'Please wait a moment before trying again.',
        );

      case ApiFailure(statusCode: final code, body: _) when code == 422:
        // Validation errors are handled inline by forms — silently count.
        break;

      case SessionExpiredFailure():
        // GoRouter redirect handles the user experience.
        break;

      case AuthFailure():
        // Handled inline by login/signup forms.
        break;

      case UnknownFailure():
        NotificationService.error(
          'Unexpected error',
          description: 'Something went wrong. Please try again.',
        );

      case ApiFailure():
        NotificationService.error(
          'Request failed',
          description: 'Please try again.',
        );
    }
  }
}
