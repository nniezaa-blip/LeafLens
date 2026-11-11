import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/shared/widgets/background_ellipse.dart';

import '../../helpers/test_asset_bundle.dart';

Widget wrapWithAssetBundle(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: child,
      ),
    ),
  );
}

void main() {
  group('BackgroundEllipse', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(wrapWithAssetBundle(const BackgroundEllipse()));

      expect(find.byType(Align), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('uses default alignment bottomRight', (tester) async {
      await tester.pumpWidget(wrapWithAssetBundle(const BackgroundEllipse()));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.bottomRight);
    });

    testWidgets('accepts custom alignment', (tester) async {
      await tester.pumpWidget(
        wrapWithAssetBundle(
          const BackgroundEllipse(alignment: Alignment.topLeft),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.topLeft);
    });

    testWidgets('uses default width and height factors', (tester) async {
      await tester.pumpWidget(wrapWithAssetBundle(const BackgroundEllipse()));

      final fraction = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fraction.widthFactor, 0.9);
      expect(fraction.heightFactor, 0.9);
    });

    testWidgets('accepts custom dimensions', (tester) async {
      await tester.pumpWidget(
        wrapWithAssetBundle(
          const BackgroundEllipse(
            widthFactor: 0.6,
            heightFactor: 0.5,
          ),
        ),
      );

      final fraction = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fraction.widthFactor, 0.6);
      expect(fraction.heightFactor, 0.5);
    });
  });
}
