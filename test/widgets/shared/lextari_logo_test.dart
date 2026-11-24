import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/widgets/lextari_logo.dart';
import 'package:lextari/ui/ui.dart';

import '../../helpers/test_asset_bundle.dart';

void main() {
  group('LextariLogo', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const PrismScaffold(bar: const EmptyBar(), body: LextariLogo()),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
