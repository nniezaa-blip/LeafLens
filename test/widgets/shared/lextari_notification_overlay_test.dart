import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/notifications/lextari_notification_overlay.dart';
import 'package:toastification/toastification.dart';

void main() {
  group('LextariNotificationOverlay', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: LextariNotificationOverlay(
            child: PrismScaffold(
              bar: EmptyBar(),
              body: Text('Hello Lextari'),
            ),
          ),
        ),
      );

      expect(find.text('Hello Lextari'), findsOneWidget);
    });

    testWidgets('wraps child with ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: LextariNotificationOverlay(
            child: PrismScaffold(
              bar: EmptyBar(),
              body: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ToastificationWrapper), findsOneWidget);
    });

    testWidgets('child is inside ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: LextariNotificationOverlay(
            child: PrismScaffold(
              bar: EmptyBar(),
              body: Text('Nested'),
            ),
          ),
        ),
      );

      final wrapper = tester.widget<ToastificationWrapper>(
        find.byType(ToastificationWrapper),
      );
      expect(wrapper.child, isA<PrismScaffold>());
    });
  });
}
