import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/app.dart';
import 'package:lextari/core/init/app_init.dart';

/// Lextari application entry point.
///
/// Initialises services then hands off to [LextariApp].
Future<void> main() async {
  await initApp();
  _runApp();
}

void _runApp() {
  runApp(
    const ProviderScope(
      child: LextariApp(),
    ),
  );
}
