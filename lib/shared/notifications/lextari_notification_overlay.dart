import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Root widget that enables toast rendering across the app.
///
/// Wraps [ToastificationWrapper] so the rest of the app never imports
/// [toastification] directly at the widget tree level.
///
/// Place this as the outermost widget in [MaterialApp.router]:
/// ```dart
/// return LextariNotificationOverlay(
///   child: MaterialApp.router(...),
/// );
/// ```
class LextariNotificationOverlay extends StatelessWidget {
  /// Creates a [LextariNotificationOverlay] with the given [child].
  const LextariNotificationOverlay({required this.child, super.key});

  /// The app tree that renders below the toast overlay.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(child: child);
  }
}
