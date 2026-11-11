import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/core/router/app_router.dart';
import 'package:lextari/shared/notifications/notification_service.dart';

/// Orchestrates all app initialisation in the correct order.
///
/// Binding → error handlers → services → storage. Each step is isolated
/// so the startup sequence reads like a table of contents.
Future<void> initApp() async {
  // 1. Flutter bindings must exist before any plugin/asset access.
  WidgetsFlutterBinding.ensureInitialized();
  _initErrorHandlers();
  // 2. Load `.env` so configuration is available below.
  await AppConfig.load();
  // 3. The session is restored by LextariApp once the provider scope exists.
  _initNotifications();
  await _initStorage();
}

/// Registers global error handlers before any async work begins.
void _initErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    return true;
  };
}

/// Wires NotificationService to the root navigator key.
void _initNotifications() {
  NotificationService.init(AppRouter.rootNavigatorKey);
}

/// Initialises Hive for local caching.
Future<void> _initStorage() async {
  await Hive.initFlutter();
  await Hive.openBox<Map<String, dynamic>>(AppConfig.telemetryCacheBox);
}
