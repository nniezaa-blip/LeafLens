import 'package:flutter/material.dart';

import 'package:lextari/shared/notifications/lextari_toast.dart';
import 'package:toastification/toastification.dart';

/// Application-level notification service.
///
/// Wraps toastification.showCustom so the rest of the app never imports
/// toastification directly. Uses [LextariToast] for consistent branding.
///
/// Must be initialized once with [init] before any other method is called.
class NotificationService {
  NotificationService._();

  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialise the service with the root navigator key.
  /// Call once from main after [WidgetsFlutterBinding.ensureInitialized].
  // Single-setter pattern intentional — avoids exposing _navigatorKey.
  // ignore: use_setters_to_change_properties
  static void init(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Shortcut because every method needs a context.
  static BuildContext? get _ctx => _navigatorKey?.currentContext;

  /// Shared showCustom call with type-specific defaults.
  static void _show({
    required String title,
    required ToastificationType type,
    String? description,
    Duration autoCloseDuration = const Duration(seconds: 4),
  }) {
    final ctx = _ctx;
    if (ctx == null) return;
    toastification.showCustom(
      context: ctx,
      alignment: Alignment.topCenter,
      autoCloseDuration: autoCloseDuration,
      builder: (context, holder) => LextariToast(
        holder: holder,
        title: title,
        description: description,
        type: type,
      ),
    );
  }

  // ── Public API ──────────────────────────────────────────

  /// An error occurred that the user should know about.
  static void error(
    String title, {
    String? description,
    Duration? duration,
    VoidCallback? onRetry,
  }) {
    _show(
      title: title,
      description: description,
      type: ToastificationType.error,
      autoCloseDuration: duration ?? const Duration(seconds: 5),
    );
  }

  /// An operation completed successfully.
  static void success(
    String title, {
    String? description,
    Duration? duration,
  }) {
    _show(
      title: title,
      description: description,
      type: ToastificationType.success,
      autoCloseDuration: duration ?? const Duration(seconds: 3),
    );
  }

  /// A cautionary note — not an error, but worth highlighting.
  static void warning(
    String title, {
    String? description,
    Duration? duration,
  }) {
    _show(
      title: title,
      description: description,
      type: ToastificationType.warning,
      autoCloseDuration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Neutral information that doesn't require user action.
  static void info(
    String title, {
    String? description,
    Duration? duration,
  }) {
    _show(
      title: title,
      description: description,
      type: ToastificationType.info,
      autoCloseDuration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Convenience: show a notification from a [NotificationMessage].
  static void show(NotificationMessage msg) {
    _show(
      title: msg.title,
      description: msg.description,
      type: msg.type,
      autoCloseDuration: msg.duration ?? const Duration(seconds: 4),
    );
  }
}

/// Lightweight data class for [NotificationService.show].
class NotificationMessage {
  /// Creates a [NotificationMessage] with the given [title] and [type].
  const NotificationMessage(
    this.title, {
    this.description,
    this.duration,
    this.type = ToastificationType.info,
  });

  /// The notification title.
  final String title;

  /// Optional secondary text.
  final String? description;

  /// How long to show before auto-dismissing.
  final Duration? duration;

  /// Visual type for colour and icon.
  final ToastificationType type;
}
