import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';

/// Standardised Lextari modal dialog.
///
/// Use this instead of raw [AlertDialog] to ensure consistent theming,
/// typography, and button placement across the app.
///
/// ## Usage — blocking info dialog
/// ```dart
/// await showAppDialog(
///   context: context,
///   title: 'Session Expired',
///   message: 'Please log in again.',
/// );
/// ```
///
/// ## Usage — confirm/cancel
/// ```dart
/// final confirmed = await showAppDialog<bool>(
///   context: context,
///   title: 'Delete device?',
///   message: 'This cannot be undone.',
///   confirmLabel: 'Delete',
///   cancelLabel: 'Cancel',
///   confirmColor: AppColors.redDark,
/// );
/// if (confirmed == true) { /* delete */ }
/// ```
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool barrierDismissible = false,
  Widget? icon,
  VoidCallback? onConfirm,
  Color? confirmColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: icon,
      title: Text(
        title,
        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: Theme.of(ctx).textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              cancelLabel,
              style: TextStyle(color: confirmColor ?? AppColors.mediumGreen),
            ),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.mediumGreen,
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            onConfirm?.call();
            Navigator.of(ctx).pop(true);
          },
          child: Text(confirmLabel ?? 'OK'),
        ),
      ],
    ),
  );
}
