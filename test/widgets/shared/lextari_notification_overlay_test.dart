import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/shared/notifications/lextari_notification_overlay.dart';
import 'package:toastification/toastification.dart';

void main() {
  group('LextariNotificationOverlay', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LextariNotificationOverlay(
            child: Scaffold(
              body: Text('Hello Lextari'),
            ),
          ),
        ),
      );

      expect(find.text('Hello Lextari'), findsOneWidget);
    });

    testWidgets('wraps child with ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LextariNotificationOverlay(
            child: Scaffold(
              body: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ToastificationWrapper), findsOneWidget);
    });

    testWidgets('child is inside ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LextariNotificationOverlay(
            child: Scaffold(
              body: Text('Nested'),
            ),
          ),
        ),
      );

      final wrapper = tester.widget<ToastificationWrapper>(
        find.byType(ToastificationWrapper),
      );
      expect(wrapper.child, isA<Scaffold>());
    });
  });
}
