import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/profile_badge.dart';

void main() {
  testWidgets('renders the profile initial and calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      PrismApp(
        home: PrismScaffold(
          bar: const EmptyBar(),
          body: ProfileBadge(
            profile: const UserProfile(
              name: 'Aishah',
              email: 'aishah@example.com',
            ),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    await tester.tap(find.byType(ProfileBadge));
    expect(tapped, isTrue);
  });
}
