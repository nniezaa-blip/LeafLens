# Lextari

<img src="https://img.shields.io/badge/version-1.0.0+1-5BC0DE?style=flat-square" alt="Version">&nbsp;
<img src="https://img.shields.io/github/stars/mishoshup/Lextari?style=flat-square&label=stars&color=5BC0DE" alt="Stars">&nbsp;
<img src="https://img.shields.io/github/license/mishoshup/Lextari?style=flat-square&color=5BC0DE" alt="License">&nbsp;
<img src="https://img.shields.io/github/languages/top/mishoshup/Lextari?style=flat-square&color=5BC0DE" alt="Dart">&nbsp;
<img src="https://img.shields.io/github/last-commit/mishoshup/Lextari?style=flat-square&color=5BC0DE" alt="Last Commit">
<br>
<img src="https://img.shields.io/badge/Flutter-3.12-5BC0DE?style=flat-square&logo=flutter&logoColor=white" alt="Flutter">&nbsp;
<img src="https://img.shields.io/badge/Dart-3.11-5BC0DE?style=flat-square&logo=dart&logoColor=white" alt="Dart">&nbsp;
<img src="https://img.shields.io/badge/Riverpod-3.x-5BC0DE?style=flat-square" alt="Riverpod">&nbsp;
<img src="https://img.shields.io/badge/FavorIoT-IoT-5BC0DE?style=flat-square" alt="FavorIoT">

**AI-Powered Mobile Application for Intelligent Plant Health Monitoring**

Final Year Project — Bachelor of Computer Science, IIUM  
**Supervisor:** Ts. Dr. Ahmad Anwar bin Zainuddin

---

## Overview

Lextari monitors indoor plant health through a dual-ESP32 sensor system,
presents a unified **Growth Health Score (GHS)** on a Flutter mobile app, and
autonomously manages water refill so plants survive even when you're away.

**Key differentiator from existing IoT gardening systems:**
- Translates raw telemetry (27°C, 45% moisture) into a single 0-100% score
  that anyone can understand at a glance
- Autonomous water-line refill with safety cutoff — plant doesn't depend on
  you refilling the tank

---

## Architecture

Lextari is a **three-tier system** with **BLE-based device provisioning**:

```
Provisioning (one-time BLE setup)

  0. Admin  ──console──→ FavorIoT       create device → device_developer_id + token
  1. Flutter ──BLE──→ ESP32            Wi-Fi creds + device_developer_id + token
  2. ESP32 connects to Wi-Fi
  3. ESP32  ──MQTT──→ FavorIoT         telemetry stream begins
  4. Flutter ──POST──→ FastAPI         /api/v1/devices/link (verify + map)
  5. FastAPI ─────→ PostgreSQL         save user_id ↔ platform_device_id

───────────────────────────────────────────────────────────

Steady State

  ESP32 ──MQTT──→ FavorIoT ←──REST──→ FastAPI ──REST/WS──→ Flutter
  FastAPI ──RPC──→ FavorIoT ──MQTT──→ ESP32
```

| Layer | Technology | Role |
|-------|-----------|------|
| **Provisioning** | BLE (ESP32 firmware) | One-click Wi-Fi setup, no IP/port typing |
| **Hardware** | 2× ESP32, soil moisture, DHT, ultrasonic, pump, mist maker, solenoid valve | Sensor data collection + actuation |
| **Cloud** | FavorIoT IoT Platform (global SaaS) | Telemetry ingest/storage, device management, RPC |
| **Backend** | FastAPI (Python) | Device linking, GHS computation, FavorIoT proxy, alarms |
| **Auth** | Supabase | User accounts, sessions, JWT issuance |
| **Mobile** | Flutter + Riverpod (MVVM) + GoRouter | Dashboard UI, charts, offline mode, BLE provisioning UI |

**Flutter never talks to FavorIoT directly.** The FastAPI backend sits as a
gateway — the FavorIoT API key stays on the server. The Flutter app
authenticates via Supabase and FastAPI proxies FavorIoT data.

---

## Documentation

Detailed docs for every aspect of the project in `docs/`:

### Requirements & planning

| Doc | Covers |
|-----|--------|
| [`docs/PRODUCT_REQUIREMENTS.md`](docs/PRODUCT_REQUIREMENTS.md) | Problem statement, personas, functional + non-functional requirements, success metrics |
| [`docs/TECHNICAL_REQUIREMENTS.md`](docs/TECHNICAL_REQUIREMENTS.md) | Stack + versions, platform/backend/hardware requirements, telemetry + config contract |
| [`docs/APP_FLOW.md`](docs/APP_FLOW.md) | End-to-end user journeys: launch, auth, BLE provisioning, dashboard, RPC, offline |
| [`docs/DESIGN_BRIEF.md`](docs/DESIGN_BRIEF.md) | Design vision, brand, colour/type system, layout principles, screen intent |
| [`docs/BACKEND_SCHEMA.md`](docs/BACKEND_SCHEMA.md) | PostgreSQL schema, FavorIoT entities, FastAPI REST + WebSocket contract |
| [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) | Phased delivery, milestones, status, demo-risk mitigations |

### Security

| Doc | Covers |
|-----|--------|
| [`docs/AUTH.md`](docs/AUTH.md) | Identity model, token lifecycle, guard, authorization boundary, error mapping |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Security principles, trust boundaries, transport, secrets, controls, known gaps |
| [`docs/DATA_SECURITY.md`](docs/DATA_SECURITY.md) | Data classification, PII, encryption, retention, privacy commitments |
| [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md) | STRIDE analysis, assets, trust boundaries, risk summary, deep-dives |
| [`docs/SECURITY_CHECKLIST.md`](docs/SECURITY_CHECKLIST.md) | Actionable pre-release security gates |

### Engineering reference

| Doc | Covers |
|-----|--------|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | BLE provisioning, steady-state data flow, auth layers, ESP32 hardware, FavorIoT data model |
| [`docs/ERROR_HANDLING.md`](docs/ERROR_HANDLING.md) | 3-tier notification system: toast overlays, inline errors, modal dialogs, Sentry logging, error metrics |
| [`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md) | Directory layout, file responsibilities, codegen workflow |
| [`docs/SCREENS_AND_NAVIGATION.md`](docs/SCREENS_AND_NAVIGATION.md) | All routes, screen layouts, GoRouter auth redirect |
| [`docs/FRONTEND_DESIGN_SYSTEM.md`](docs/FRONTEND_DESIGN_SYSTEM.md) | Design tokens (colours, typography), screens, shared widgets |
| [`docs/WIDGET_LIBRARY.md`](docs/WIDGET_LIBRARY.md) | All 9 shared widgets with constructor props and states |
| [`docs/DOMAIN_MODELS.md`](docs/DOMAIN_MODELS.md) | Data models, GHS algorithm reference, thresholds |
| [`docs/NETWORKING.md`](docs/NETWORKING.md) | Docker Compose stack, ports, traffic flow, secrets |
| [`docs/TESTING.md`](docs/TESTING.md) | Test pyramid, running tests, writing patterns (unit/widget/flow/skip) |
| [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md) | Code style, naming, state management, error handling |

Thesis document available on request (not in this repo).

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | ^3.11.5 | [Install guide](https://docs.flutter.dev/get-started/install) |
| Dart SDK | Bundled with Flutter | |
| Android Studio | Latest | Required for Android builds on all platforms |
| Xcode | Latest | macOS only — required for iOS/macOS builds |
| Java JDK | 17–21 | AGP 8.11.1 requires Java 17–21. Java 22+ breaks Gradle. |
| Python 3.10+ | (backend only) | For FastAPI analytics server |
| FavorIoT account | v2 API | Cloud IoT platform (devices registered in console) |

---

## Getting Started

### 1. Clone and install dependencies

```bash
git clone <repo-url> lextari
cd lextari
flutter pub get
```

### 2. Run on a device

```bash
# List connected devices
flutter devices

# Run on a specific device (Android/iOS/macOS/Windows/Linux)
flutter run -d <device-id>

# Or pick from interactive prompt
flutter run
```

### 3. Run on Android (physical device)

```bash
# Check device is detected
flutter devices

# If using command-line ADB:
adb devices -l

# If device not showing, verify:
#   - USB debugging is enabled on phone (Developer options)
#   - Accept the RSA fingerprint prompt on phone
#   - Use a data-capable USB cable
#   - Windows: install Google USB driver
#   - Linux: add udev rule for your device
#   - Restart ADB: adb kill-server && adb start-server

# Run on that device
flutter run -d <device-id>
```

### 4. Java version notes (Android builds)

AGP 8.11.1 requires Java 17–21. If `java -version` shows 22+, you'll get a
cryptic Gradle failure.

**Check your Java version:**
```bash
java -version
```

**Set JAVA_HOME for a compatible JDK:**

| Platform | Command |
|----------|---------|
| **macOS** (Homebrew) | `JAVA_HOME=$(/usr/libexec/java_home -v 21) flutter run -d <device-id>` |
| **macOS** (manual) | `JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home flutter run -d <device-id>` |
| **Linux** | `JAVA_HOME=/usr/lib/jvm/java-21-openjdk flutter run -d <device-id>` |
| **Windows** (PowerShell) | `$env:JAVA_HOME="C:\Program Files\Java\jdk-21"; flutter run -d <device-id>` |
| **Windows** (cmd) | `set JAVA_HOME=C:\Program Files\Java\jdk-21 && flutter run -d <device-id>` |

**Permanent fix — add to `android/gradle.properties`:**
```properties
org.gradle.java.home=/path/to/your/jdk-21
```

### 5. Platform-specific notes

| Platform | Notes |
|----------|-------|
| **macOS** | Xcode required for iOS builds. CocoaPods removed — uses SPM. |
| **Linux** | `flutter doctor` may ask for missing dependencies — install them via your package manager. |
| **Windows** | Visual Studio required for Windows desktop builds. Android Studio recommended for Android. |
| **iOS** | Builds require a macOS machine with Xcode. No way around this. |

---

## Running Tests

```bash
# Run ALL tests
flutter test

# Run ALL tests with expanded output (each result on its own line,
# no overwriting — answer to "can it output per test result")
flutter test --reporter expanded
flutter test -r expanded              # shorthand

# Run unit tests only (fast — pure Dart, no Flutter rendering)
flutter test test/unit/

# Run widget + flow tests
flutter test test/widgets/

# Run a specific test file
flutter test test/widgets/shared/app_button_test.dart
flutter test test/widgets/screens/login_page_test.dart
flutter test test/widgets/flows/navigation_test.dart

# Run all tests in a directory
flutter test test/widgets/shared/
flutter test test/widgets/screens/

# Filter by test name
flutter test --name "HealthGauge"
flutter test --name "renders login"
flutter test --name "StatusBadge"
flutter test --name "GrowthHealthScore"

# Skip skipped tests (dashboard placeholder)
flutter test --no-skip

# JSON output for CI tools
flutter test --reporter json

# Verbose mode
flutter test -v
```

### Test coverage summary (98 active + 2 skipped = 100 tests)

**Unit tests** (plain `test()`, zero Flutter, runs in milliseconds):

| File | Tests | What's tested |
|------|-------|---------------|
| `test/unit/growth_health_score_test.dart` | 24 | Bell curve scoring, weighted composition, partial data, status thresholds (all 5 levels), custom config (cactus), score clamping, HealthScoreResult helpers, timestamp |

**Widget tests** (`testWidgets()`, single widget in isolation):

| File | Tests | What's tested |
|------|-------|---------------|
| `test/widgets/shared/app_text_field_test.dart` | 7 | Hint, icons, obscure, input, controller, keyboard type |
| `test/widgets/shared/background_ellipse_test.dart` | 5 | SVG render, alignment, width/height factors, custom params |
| `test/widgets/shared/lextari_logo_test.dart` | 1 | SVG render without error |
| `test/widgets/shared/status_badge_test.dart` | 6 | All 5 HealthStatus labels, all render without error |
| `test/widgets/shared/health_gauge_test.dart` | 6 | Score %, status labels, CustomPaint, custom size, all statuses |
| `test/widgets/shared/sensor_tile_test.dart` | 6 | Value display, skeleton (null), stale indicator, age label |
| `test/widgets/shared/app_button_test.dart` | 11 | Label, tap, disabled, 4 variants, loading, icon, width |
| `test/widgets/shared/sensor_error_boundary_test.dart` | 3 | Normal render, label hidden in normal state |
| `test/widgets/shared/offline_banner_test.dart` | 2 | Hidden when authenticated, shown when unauthenticated |
| `test/widgets/screens/splash_screen_test.dart` | 4 | Brand text, Get Started button, error-free render, Stack layout |
| `test/widgets/screens/login_page_test.dart` | 7 | Title, fields, buttons, links, divider, email/password input |
| `test/widgets/screens/signup_page_test.dart` | 7 | Title, all 4 fields, buttons, links, checkbox, divider, input |

**Flow tests** (multi-screen widget integration):

| File | Tests | What's tested |
|------|-------|---------------|
| `test/widgets/flows/navigation_test.dart` | 5 | splash → login, login → signup, signup → login, full round trip, redirect guard |

**Skipped (incomplete features):**

| File | Tests | What's pending |
|------|-------|---------------|
| `test/widgets/screens/dashboard_screen_test.dart` | 2 (skip) | Health gauge, sensor tiles, quick actions, offline indicator |

---

## Project Structure

```
lib/
  main.dart                           # Entry point only: void main(), init calls, runApp()
  app.dart                            # LextariApp widget: theme + router + notification overlay

  core/
    config/
      app_config.dart                 # API URL, Supabase config, stale threshold, Hive box name
    errors/
      failures.dart                   # Typed exception classes (AuthFailure, NetworkFailure, etc.)
      error_handler.dart              # 3-tier: toast + Sentry + metrics
    init/
      sentry_init.dart                # initSentry() — Sentry error tracking setup
      lextari_auth_init.dart        # initLextariAuth() — Supabase client setup
    network/
      api_client.dart                 # HTTP client → FastAPI
      ws_client.dart                  # WebSocket client → FastAPI
    router/
      app_router.dart                 # AppRouter class — GoRouter config + routes
      auth_guard.dart                 # AuthGuard — pure function for auth redirect
    theme/
      app_colors.dart                 # All colour tokens
      app_typography.dart             # Typography tokens (Lexend weights)
      app_theme.dart                  # Material3 ThemeData

  features/
    auth/
      data/
        auth_repository.dart          # AuthRepository + @riverpod providers
        auth_repository.g.dart        # Generated
        lextari_auth.dart           # Service: Supabase auth wrapper (static API)
      presentation/
        login_page.dart               # View: Form + email/password + Google stub
        signup_page.dart              # View: 4 fields + terms + Google stub
    dashboard/
      data/
        dashboard_providers.dart      # ViewModel: @riverpod providers (stream, state)
        dashboard_providers.g.dart    # Generated
      domain/
        dashboard_update.dart         # @freezed sealed union (WS payloads)
        growth_health_score.dart      # GHS algorithm (pure domain logic)
        sensor_key.dart               # Enum: soilMoisture, temperature, humidity, waterLevel
        sensor_reading.dart           # Data model with staleness tracking
        water_system_state.dart       # Pump/mist/refill status
      presentation/
        dashboard_screen.dart         # View: placeholder dashboard
    splash/
      presentation/
        splash_screen.dart            # View: decorative SVG + "Get Started" CTA

  shared/
    widgets/
      app_text_field.dart             # Themed outlined input
      app_button.dart                 # 4 variants + loading
      background_ellipse.dart         # Configurable decorative SVG
      lextari_logo.dart             # Brand leaf SVG
      health_gauge.dart               # Circular gauge (CustomPaint)
      sensor_tile.dart                # Sensor value + skeleton + stale
      status_badge.dart               # Colored chip
      sensor_error_boundary.dart      # Per-widget error boundary
      offline_banner.dart             # Connectivity banner
    notifications/
      notification_service.dart       # Toastification wrapper
      lextari_notification_overlay.dart  # ToastificationWrapper root widget
      lextari_toast.dart            # Custom branded toast
      app_dialog.dart                 # Modal dialog utility

test/
  unit/
    growth_health_score_test.dart        # 24 tests — pure domain logic, no Flutter
  widgets/
    shared/
      app_text_field_test.dart           # 7 tests
      app_button_test.dart               # 11 tests
      background_ellipse_test.dart       # 5 tests
      lextari_logo_test.dart           # 1 test
      health_gauge_test.dart             # 6 tests
      sensor_tile_test.dart              # 6 tests
      status_badge_test.dart             # 6 tests
      sensor_error_boundary_test.dart    # 3 tests
      offline_banner_test.dart           # 2 tests
    screens/
      splash_screen_test.dart            # 4 tests
      login_page_test.dart               # 7 tests
      signup_page_test.dart              # 7 tests
      dashboard_screen_test.dart         # 2 tests (skipped — placeholder)
    flows/
      navigation_test.dart               # 5 tests — splash→login→signup flows
  helpers/
    test_asset_bundle.dart               # Mock SVG bundle for flutter_svg in tests

Directory layout follows the Flutter testing pyramid:
  test/unit/     = pure Dart functions, zero Flutter, runs in < 1s
  test/widgets/  = single widget isolation + multi-screen integration
  ---
  integration_test/  = (planned) full-device integration tests
```

---

## Key Screens

| Route | Screen | Type | State |
|-------|--------|------|-------|
| `/splash` | SplashScreen | `StatelessWidget` | Done — decorative + "Get Started" button |
| `/login` | LoginPage | `ConsumerStatefulWidget` | Done — email/password form, Google stub |
| `/signup` | SignUpPage | `ConsumerStatefulWidget` | Done — 4 fields, terms checkbox, Google stub |
| `/dashboard` | DashboardScreen | `ConsumerWidget` | Placeholder — "Dashboard — next build" |
| `/history` | — | — | Planned |
| `/settings` | — | — | Planned |

Navigation uses **GoRouter** with auth redirect:
- Unauthenticated user on `/splash` → stay (splash is public)
- Unauthenticated user on any other route → redirect to `/login`
- Authenticated user on `/login` or `/signup` → redirect to `/dashboard`

---

## Code Generation

This project uses `riverpod_generator`, `freezed`, and `json_serializable`.
After modifying any file with `@riverpod`, `@freezed`, or `@JsonSerializable`:

```bash
dart run build_runner build
```

Generated files (`.g.dart`, `.freezed.dart`) are **committed to git**.

**Always upgrade codegen packages as a coordinated set —** bumping one
package individually causes incompatible `build` package version conflicts.

| Package | Version | Role |
|---------|---------|------|
| `flutter_riverpod` | 3.2.1 | State management runtime |
| `riverpod_annotation` | ^4.0.2 | `@riverpod` annotations |
| `riverpod_generator` | ^4.0.3 (dev) | Riverpod codegen |
| `freezed_annotation` | ^3.1.0 | Sealed union annotations |
| `freezed` | ^3.2.5 (dev) | Freezed codegen |
| `json_annotation` | ^4.12.0 | JSON annotations |
| `json_serializable` | ^6.14.0 (dev) | JSON codegen |

---

## Font

**Lexend** (variable font, 175KB) is embedded in the binary via pubspec.yaml.
Single font for the entire app — no google_fonts dependency, no network font
loading.

| Weight | UI Role |
|--------|---------|
| Light 300 | Graph labels, muted footer text |
| Regular 400 | Body text, sensor descriptions |
| Medium 500 | Form input labels |
| SemiBold 600 | Screen titles, button text |
| Bold 700 | Card titles, section headers |
| ExtraBold 800 | Sensor values, GHS gauge score |

---

## Hardware

| Component | ESP32 | Telemetry Key | Unit |
|-----------|-------|---------------|------|
| Soil moisture sensor | #1 (env) | soil_moisture | % |
| DHT temperature | #1 (env) | temperature | °C |
| DHT humidity | #1 (env) | humidity | % |
| Water pump | #1 (env) | — (actuator) | — |
| Mist maker | #1 (env) | — (actuator) | — |
| Ultrasonic water level | #2 (water) | water_level | % |
| Solenoid valve | #2 (water) | — (refill actuator) | — |

**Telemetry cadence:** published every 5 seconds via MQTT (all sensors batched in one message). 15-minute cadence from thesis was for battery-powered scenarios — this setup runs on USB, so we push real-time.

---

## Growth Health Score (GHS)

The intellectual core of the thesis. Algorithm in
`lib/features/dashboard/domain/growth_health_score.dart`.

**Weights:** Soil moisture 50% / Temperature 30% / Humidity 20%

**Scoring:** Bell curve — score = 1.0 at midpoint of acceptable range, 0.0 at
or beyond boundaries. Falls off linearly.

**Status:**
| Score | Status | Color |
|-------|--------|-------|
| ≥ 80 | Optimal | Green |
| ≥ 65 | Moderate | Light green |
| ≥ 50 | Caution | Yellow |
| ≥ 30 | Danger | Orange |
| < 30 | Critical | Red |

**Partial sensor data:** re-weights remaining sensors proportionally.

---

## Writing Tests

### Pattern for pure-UI widgets

```dart
testWidgets('renders label text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: StatusBadge(status: HealthStatus.optimal))),
  );
  expect(find.text('Optimal'), findsOneWidget);
});
```

### Pattern for screens with Riverpod providers

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

### Pattern for SVG-dependent widgets

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

Place `DefaultAssetBundle` **inside** `MaterialApp` — not outside —
because `MaterialApp` wraps with its own asset bundle internally.

---

## Demo Risk Points (Viva)

1. **WebSocket drops mid-demo** — reconnect must be silent and automatic
2. **Sensor offline** — each sensor tile is independently error-bounded
3. **TB token expires** — JWT refresh must be transparent
4. **Autonomous refill** — have a manual trigger button in the app
5. **No Wi-Fi** — show stale data with indicator, never a spinner
6. **Chart loads slowly** — skeleton placeholder immediately, never block render

---

## Related Repositories

- **FastAPI Backend:** [link] — Python analytics, GHS computation, FavorIoT proxy
- **ESP32 Firmware:** [link] — MQTT telemetry, actuator control, refill logic
- **Thesis Report:** [link] — Full methodology, UAT results, diagrams

---

## License

Final Year Project — IIUM, Kulliyyah of ICT
