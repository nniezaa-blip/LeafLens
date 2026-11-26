import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/onboarding/presentation/onboarding_screen.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  Widget buildTestApp() {
    return const ProviderScope(child: PrismApp(home: OnboardingScreen()));
  }

  group('OnboardingScreen', () {
    testWidgets('starts on the device-type step', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());

      expect(find.text('Connect your device'), findsOneWidget);
      expect(find.text('BLE provisioning coming soon'), findsOneWidget);
      expect(find.text('Environment sensors'), findsOneWidget);
      expect(find.text('Water system'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('No ESP32'), findsNothing);
    });

    testWidgets('continues to details and goes back', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('My Lextari'), findsOneWidget);
      expect(find.text('Agrilink_1_device@username'), findsOneWidget);
      expect(find.text('Connect device'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Environment sensors'), findsOneWidget);
    });
  });
}
