import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/user_avatar.dart';

void main() {
  testWidgets('uses the emoji monogram for a name with an emoji', (
    tester,
  ) async {
    await tester.pumpWidget(
      const PrismApp(
        home: PrismScaffold(
          bar: EmptyBar(),
          body: UserAvatar(
            profile: UserProfile(name: '🌱 Plant', email: 'plant@example.com'),
          ),
        ),
      ),
    );

    expect(find.byType(EmojiText), findsOneWidget);
  });
}
