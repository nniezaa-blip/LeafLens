import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/shared/widgets/lextari_logo.dart';

import '../../helpers/test_asset_bundle.dart';

void main() {
  group('LextariLogo', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const Scaffold(body: LextariLogo()),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
