# Lextari Testing Guide

**98 active tests + 2 skipped = 100 total. All passing.**

---

## Running Tests

```bash
# All tests
flutter test

# With expanded output (each result on its own line)
flutter test -r expanded

# By layer
flutter test test/unit/              # Unit tests only (fastest)
flutter test test/widgets/           # Widget + flow tests

# Specific file
flutter test test/unit/growth_health_score_test.dart
flutter test test/widgets/shared/app_button_test.dart
flutter test test/widgets/flows/navigation_test.dart

# Filter by name
flutter test --name "HealthGauge"
flutter test --name "GrowthHealthScore"

# Include skipped tests
flutter test --no-skip
```

---

## Test Pyramid

```
test/unit/              24 tests   Pure Dart, no Flutter, < 1s
test/widgets/shared/    47 tests   Single widget in isolation
test/widgets/screens/   20 tests   Full screen with provider overrides
                         (2 skip)
test/widgets/flows/      5 tests   Multi-screen navigation flows
```

---

## Directory Layout

```
test/
  unit/
    growth_health_score_test.dart         24 tests
  widgets/
    shared/
      app_text_field_test.dart             7 tests
      app_button_test.dart                11 tests
      background_ellipse_test.dart         5 tests
      health_gauge_test.dart               6 tests
      lextari_logo_test.dart             1 test
      offline_banner_test.dart             2 tests
      sensor_error_boundary_test.dart      3 tests
      sensor_tile_test.dart                6 tests
      status_badge_test.dart               6 tests
    screens/
      splash_screen_test.dart              4 tests
      login_page_test.dart                 7 tests
      signup_page_test.dart                7 tests
      dashboard_screen_test.dart           2 tests (skipped)
    flows/
      navigation_test.dart                 5 tests
  helpers/
    test_asset_bundle.dart
```

---

## Writing Tests

### 1. Unit Tests (pure Dart, no testWidgets)

For domain logic with zero Flutter imports. Fastest tests — milliseconds.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';

void main() {
  group('GrowthHealthScore.compute', () {
    test('returns optimal at midpoint', () {
      final readings = { SensorKey.soilMoisture: reading(55) };
      final result = GrowthHealthScore.compute(readings, defaultConfig);

      expect(result.status, HealthStatus.optimal);
      expect(result.score, greaterThan(95));
    });
  });
}
```

### 2. Widget Tests (testWidgets, pure widget, no providers)

For stateless widgets with no Riverpod dependency.

```dart
testWidgets('renders label text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: StatusBadge(status: HealthStatus.optimal)),
    ),
  );

  expect(find.text('Optimal'), findsOneWidget);
});
```

### 3. Widget Tests with Riverpod Provider Overrides

For screens that depend on `authStateProvider`, `authRepositoryProvider`, etc.

```dart
Widget buildTestApp() {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream<String?>.value(null)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: const LoginPage(),
        ),
      ),
    ),
  );
}
```

**Important:** `DefaultAssetBundle` must go **inside** `MaterialApp`, not outside, because `MaterialApp` wraps its own asset bundle internally.

### 4. Widget Tests with SVG Assets

Use `TestAssetBundle` from `test/helpers/test_asset_bundle.dart` to mock SVG files:

```dart
import '../helpers/test_asset_bundle.dart';

await tester.pumpWidget(
  MaterialApp(
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: const BackgroundEllipse(),
    ),
  ),
);
```

### 5. Flow Tests (multi-screen navigation)

Test full navigation flows with the GoRouter redirect logic:

```dart
testWidgets('splash → login navigates correctly', (tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  expect(find.text('Email'), findsOneWidget);
});
```

### 6. Skipping Tests for Incomplete Features

```dart
testWidgets('dashboard renders health gauge', (tester) async {
  // TODO: write when dashboard is implemented
  // - HealthGauge renders with real data
  // - SensorTile shows telemetry
  // - Quick action buttons send RPC
  expect(true, isTrue);
}, skip: true);
```

Use `skip: true` with a TODO comment describing what the test will cover when the feature is built.

---

## SVG Test Helper

```dart
// test/helpers/test_asset_bundle.dart
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final svg = utf8.encode(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"/>',
    );
    return ByteData.view(Uint8List.fromList(svg).buffer);
  }
}
```

Returns a minimal valid SVG. The `viewBox` attribute is required by `flutter_svg` — without it, the library throws "SVG did not specify dimensions".
