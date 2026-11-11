# Lextari — Frontend Design System & Project Documentation

> **Project:** Lextari — AI-Powered Plant Health Monitoring  
> **Stack:** Flutter (Material 3) + Riverpod (3.x) + GoRouter + freezed + json_serializable + flutter_svg  
> **Codegen:** freezed, json_serializable, riverpod_generator via build_runner  
> **Architecture:** ESP32 → FavorIoT → FastAPI → Flutter (BLE-provisioned)  
> **Last updated:** 28 May 2026

---

## Table of Contents

1. [Design Tokens](#1-design-tokens)
   - 1.1 [Colors](#11-colors)
   - 1.2 [Typography](#12-typography)
2. [Architecture Pattern](#2-architecture-pattern)
3. [Screens](#3-screens)
   - 3.1 [Splash Screen](#31-splash-screen)
   - 3.2 [Login Page](#32-login-page)
   - 3.3 [Dashboard](#33-dashboard)
4. [Navigation Flow](#4-navigation-flow)
5. [Asset Inventory](#5-asset-inventory)
6. [Conventions](#6-conventions)
7. [Shared Widgets](#7-shared-widgets)

---

## 1. Design Tokens

### 1.1 Colors

All defined in `lib/core/theme/app_colors.dart`. No hardcoded hex in widgets.

| Token | Hex | Usage |
|-------|-----|-------|
| `offWhite` | `#F8F9FA` | Screen backgrounds (login, signup) |
| `offBlack` | `#1A1A1A` | Google button bg, text on light |
| `lightGreenBg` | `#A3B88C` | Splash screen background, scaffold bg, shell bg |
| `mediumGreen` | `#409761` | Primary actions, links, avatar bg |
| `deepGreen` | `#083722` | Headings, brand emphasis |
| `white` | `#FFFFFF` | Text on dark backgrounds |
| `redAlert` | `#D05555` | Error states, critical sensor gauges |
| `darkGreenText` | — | Status text on sensor cards |
| `mediumGreenOverlay` | `0x99409761` | Semi-transparent overlay for background ellipse |
| `cardBackground` | `0xB3D9D9D9` | Sensor cards, health score card |
| `gaugeGreen` | `0x991B6F0A` | Healthy sensor gauges |
| `gaugeOrange` | `0x99FFB703` | Warning sensor gauges |
| `switchBackground` | `0x9960AE88` | Action switch pill background |
| `switchTrack` | `0xFF316763` | Action switch toggle track |
| `navBarBackground` | `0xA6263626` | Floating bottom navigation bar |
| `warningText` | `0xD9E5A00A` | Health alert warning text |

Full list in `lib/core/theme/app_colors.dart`.

### 1.2 Typography

**Single font: Lexend** (variable weight, embedded in binary via pubspec.yaml). No `google_fonts` dependency.

| Weight | UI Role |
|--------|---------|
| Light 300 | Muted footer, graph labels |
| Regular 400 | Body text, sensor descriptions |
| Medium 500 | Form input labels |
| SemiBold 600 | Screen titles, button text |
| Bold 700 | Card titles, section headers |
| ExtraBold 800 | GHS gauge score, sensor values |

All tokenized in `lib/core/theme/app_typography.dart`. Per-screen custom styles use file-private `extension on BuildContext` with plain `const TextStyle` — never `GoogleFonts.*()`.

---

## 2. Architecture Pattern

### File Structure

```
lib/
├── main.dart                           # Entry point — init Sentry/Supabase/Hive, runApp()
├── app.dart                            # LextariApp — theme + router + notification overlay
├── core/
│   ├── config/app_config.dart           # Build-time config via --dart-define-from-file
│   ├── init/
│   │   ├── sentry_init.dart
│   │   └── lextari_auth_init.dart
│   ├── network/
│   │   ├── api_client.dart              # HTTP client for FastAPI
│   │   └── ws_client.dart               # WebSocket client
│   ├── errors/
│   │   ├── failures.dart                # Sealed Failure hierarchy
│   │   └── error_handler.dart           # 3-tier: toast + Sentry + metrics
│   ├── router/
│   │   ├── app_router.dart              # GoRouter + StatefulShellRoute
│   │   └── auth_guard.dart              # Auth redirect logic
│   └── theme/
│       ├── app_colors.dart              # All colour tokens
│       ├── app_typography.dart          # Typography tokens (Lexend)
│       └── app_theme.dart               # ColorScheme.fromSeed, button/card defaults
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart     # AuthRepository + @riverpod providers
│   │   │   └── lextari_auth.dart      # Supabase auth wrapper
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       └── signup_page.dart
│   ├── dashboard/
│   │   ├── data/dashboard_providers.dart
│   │   ├── domain/
│   │   │   ├── dashboard_update.dart    # @freezed sealed union
│   │   │   ├── growth_health_score.dart # GHS algorithm
│   │   │   ├── sensor_key.dart
│   │   │   ├── sensor_reading.dart
│   │   │   └── water_system_state.dart
│   │   └── presentation/
│   │       ├── dashboard_screen.dart    # Main dashboard (pinned top + scrollable cards)
│   │       ├── dashboard_shell.dart     # Shell: green bg + ellipse + floating nav bar
│   │       └── widgets/
│   │           ├── action_switch.dart   # Toggle pill with animated knob
│   │           ├── health_score_card.dart # GHS card with gauge + warning
│   │           ├── mini_gauge.dart      # Circular arc gauge (CustomPaint)
│   │           └── sensor_card.dart     # Sensor reading card (gauge + info + "More")
│   ├── stats/
│   │   └── presentation/stats_screen.dart  # Placeholder
│   ├── settings/
│   │   └── presentation/settings_screen.dart # Placeholder
│   └── splash/
│       └── presentation/splash_screen.dart
└── shared/
    ├── widgets/
    │   ├── app_text_field.dart
    │   ├── app_button.dart
    │   ├── background_ellipse.dart
    │   ├── lextari_logo.dart
    │   ├── health_gauge.dart
    │   ├── sensor_tile.dart
    │   ├── status_badge.dart
    │   ├── sensor_error_boundary.dart
    │   └── offline_banner.dart
    └── notifications/
        ├── notification_service.dart    # Toastification wrapper
        ├── lextari_notification_overlay.dart
        └── app_dialog.dart
```

Generated files (`.g.dart` and `.freezed.dart`) are committed to the repo.

---

## 3. Screens

### 3.1 Splash Screen

**File:** `lib/features/splash/presentation/splash_screen.dart`  
**Route:** `/splash`  
**State:** `StatelessWidget`

| Layer | Element | Layout |
|-------|---------|--------|
| 1 | Green background | `Scaffold(backgroundColor: lightGreenBg)` |
| 2 | Decorative SVG | `BackgroundEllipse()` — 90% × 90%, bottomRight |
| 3 | Leaf logo | `LextariLogo()` |
| 4 | "LEXTARI" + tagline | `Text` (SemiBold 28px, white) |
| 5 | "Get Started" button | `FilledButton` with `StadiumBorder` |

### 3.2 Login Page

**File:** `lib/features/auth/presentation/login_page.dart`  
**Route:** `/login`  
**State:** `ConsumerStatefulWidget`

- Email + Password form with validation
- Google Sign-In button (stub)
- Loading state + inline error on wrong credentials
- "Sign up" link navigates to `/signup`

### 3.3 Dashboard

**File:** `lib/features/dashboard/presentation/dashboard_screen.dart`  
**Route:** `/dashboard`  
**State:** `ConsumerStatefulWidget`

The dashboard is wrapped by `DashboardShell` (green background, ellipse, floating nav bar). The screen itself uses a **pinned top + scrollable bottom** layout:

- **Pinned:** Greeting header, 3 action switch toggles (Mist / Water / Refill), Health Score card
- **Scrollable:** `Expanded` > `ListView` containing 3 sensor cards (Temperature, Humidity, Soil Moisture)

Each sensor card contains a `MiniGauge` (circular arc), sensor name, unit, status text, and a "More" link.

---

## 4. Navigation Flow

```
/splash  ── "Get Started" ──→  /login
/login   ── "Sign up"  ──→     /signup
/signup  ── "Login" ──→       /login
/login   ── Login success ──→ /dashboard
```

GoRouter uses `StatefulShellRoute.indexedStack` for the dashboard tabs:

```
StatefulShellRoute.indexedStack (DashboardShell)
├── Branch 0: /dashboard  → DashboardScreen
├── Branch 1: /stats      → StatsScreen
└── Branch 2: /settings   → SettingsScreen
```

Auth redirect guard (defined in `lib/core/router/app_router.dart`):

```dart
if (path == '/splash') return null;
if (!isLoggedIn && notPublicRoute) return '/login';
if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
```

---

## 5. Asset Inventory

| File | Used By |
|------|---------|
| `assets/images/splash_ellipse.svg` | `BackgroundEllipse` (splash) |
| `assets/images/splash_illustration.svg` | `LextariLogo` |
| `assets/images/google_logo.svg` | Google Sign-In buttons |

---

## 6. Conventions

### Naming
- Files: `snake_case`
- Classes: `PascalCase`
- Private widgets: `_PascalCase`
- Private extensions: file-private `extension on BuildContext`

### Code Style
- Comments explain WHY, not WHAT
- No decorative comment blocks
- `const` constructors everywhere
- `StadiumBorder()` for pills, not `RoundedRectangleBorder`
- `.withValues(alpha:)`, never `.withOpacity()`

### State Management
- Riverpod 3.x with `@riverpod` codegen
- `ConsumerStatefulWidget` for screens with forms
- `ref.invalidate()` after auth mutations
- `mounted` checks after async gaps
- `throw UnimplementedError('message')` for stubs — never empty `() {}`

### Theming
- Colours from `AppColors` only
- Typography tokens from `AppTypography`

---

## 7. Shared Widgets

| Widget | Props | States |
|--------|-------|--------|
| `AppTextField` | hint, obscureText, controller, validator, keyboardType, icons | Normal, error |
| `AppButton` | label, onPressed, variant (4), loading, icon, width | Normal, disabled, loading |
| `BackgroundEllipse` | assetPath, widthFactor, heightFactor, alignment, fit | — |
| `LextariLogo` | — | SVG render |

### Dashboard Widgets (in `features/dashboard/presentation/widgets/`)

| Widget | Props | States |
|--------|-------|--------|
| `ActionSwitch` | icon, label, value, onChanged | Off, on (animated knob) |
| `MiniGauge` | value (0–1), color, size | Arc sweeps proportional to value |
| `SensorCard` | sensorName, value, unit, unitIcon, statusText, gaugeColor, onMoreTap, isStale | Normal, stale |
| `HealthScoreCard` | score, statusText, gaugeColor, warningText? | With/without warning |
