import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  testWidgets('gesture pull works over an empty state', (tester) async {
    var called = false;
    await tester.pumpWidget(
      ProviderScope(
        child: PrismApp(
          home: PullToRefresh(
            useGesture: true,
            onRefresh: () async {
              called = true;
            },
            child: const EmptyState(
              label: 'No device linked',
              description: 'Add one',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.dragFrom(const Offset(100, 100), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(called, isTrue);
  });
}
