import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/core/router/app_router.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/core/theme/app_theme.dart';
import 'package:lextari/shared/notifications/lextari_notification_overlay.dart';

/// Root application widget for Lextari.
///
/// Provides theming, routing, and notification overlay.
class LextariApp extends ConsumerWidget {
  /// Creates a [LextariApp] widget.
  const LextariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);

    return LextariNotificationOverlay(
      child: MaterialApp.router(
        title: 'Lextari',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        color: AppColors.lightGreenBg,
        routerConfig: router,
      ),
    );
  }
}
