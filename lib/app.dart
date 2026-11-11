import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/core/router/app_router.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/core/theme/app_theme.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/shared/notifications/lextari_notification_overlay.dart';

/// Root application widget for Lextari.
///
/// Provides theming, routing, and notification overlay, and kicks off session
/// restoration once a provider scope exists.
class LextariApp extends ConsumerStatefulWidget {
  /// Creates a [LextariApp] widget.
  const LextariApp({super.key});

  @override
  ConsumerState<LextariApp> createState() => _LextariAppState();
}

class _LextariAppState extends ConsumerState<LextariApp> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(authManagerProvider).ensureRestored());
  }

  @override
  Widget build(BuildContext context) {
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
