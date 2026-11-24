import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lextari/app.dart';
import 'package:lextari/bootstrap.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    final container = await bootstrapContainer();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const LextariApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}
