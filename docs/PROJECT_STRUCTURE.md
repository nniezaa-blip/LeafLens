# Lextari Project Structure

## Architecture: Google MVVM

Lextari follows Google's official MVVM architecture pattern for Flutter apps.
See: https://docs.flutter.dev/app-architecture/guide

**Key layers:**
- **Views** — `presentation/` screens (widgets, no business logic)
- **ViewModels** — Riverpod providers in `data/` (state + logic)
- **Repositories** — `data/` files (source of truth)
- **Services** — External API wrappers (`lextari_auth.dart`, `api_client.dart`)
- **Core** — Shared infrastructure (config, errors, router, theme)
- **Shared** — Cross-cutting concerns (notifications, reusable widgets)
- **Domain** — Pure Dart models and algorithms (no Flutter imports)

---

## Top-level folders: core, features, shared

```
lib/
├── core/        ← infrastructure (features depend on this)
├── features/    ← business modules (each owns data + presentation)
└── shared/      ← cross-cutting (used by multiple features)
```

### `core/` — the foundation

Infrastructure that every feature depends on. Never imports from `features/`. If `core/` breaks, everything breaks.

| What | Why core |
|------|----------|
| Config | Every feature reads API URLs, thresholds |
| Errors | Every feature throws/handles failures |
| Network | Every feature calls FastAPI |
| Router | Navigation is app-wide |
| Theme | Every screen uses colours and typography |
| Init | Startup runs once, affects everything |

**Rule:** `core/` depends on nothing inside `lib/` except Dart/Flutter packages. It never imports from `features/` or `shared/` (with rare exceptions like `AppColors`).

### `features/` — self-contained rooms

Each feature is a standalone module with its own data + presentation. Features can depend on `core/` and `shared/`, but never on each other.

```
features/
└── auth/
    ├── data/           ← Repository + Service (ViewModel lives here via Riverpod)
    └── presentation/   ← Screens and widgets (View)
```

**Rule:** If you're building login, everything goes in `features/auth/`. You don't touch `features/dashboard/` while working on auth. Features are isolated.

**When to create a new feature:** When you add a screen that has its own data flow (its own providers, its own repository). If it just renders data from an existing feature, it's a widget in that feature's `presentation/`, not a new feature.

### `shared/` — the toolbox

Things used by 2+ features but aren't load-bearing infrastructure. Grab when needed, not required.

| What | Why shared |
|------|------------|
| Widgets (buttons, text fields, gauges) | Used across auth, dashboard, splash |
| Notifications (toast, dialog) | Any feature can show a toast |

**Rule:** If only one feature uses it, it stays in that feature. If a second feature needs it, move to `shared/`. If every feature needs it, move to `core/`.

### Dependency direction

```
features/ → core/     ✅ (features depend on core)
features/ → shared/   ✅ (features use shared widgets)
core/ → features/     ❌ (never)
core/ → shared/       ✅ (core can use shared, rare)
shared/ → features/   ❌ (never)
shared/ → core/       ✅ (shared can use core, e.g. AppColors)
```

Think of it as a house:
- **core/** = foundation and walls (can't change without affecting everything)
- **features/** = rooms (each room is self-contained)
- **shared/** = toolbox in the garage (any room can use it)

---

## Folder tree

```
lib/
├── main.dart                              # Entry point only: void main(), init calls, runApp()
├── app.dart                               # LextariApp widget only: theme + router + overlay
├── core/
│   ├── config/
│   │   └── app_config.dart                # API URL, Supabase config, stale threshold, Hive box name
│   ├── errors/
│   │   ├── failures.dart                  # Typed exception classes (AuthFailure, NetworkFailure, etc.)
│   │   └── error_handler.dart             # 3-tier: toast + Sentry + metrics
│   ├── init/
│   │   ├── sentry_init.dart               # initSentry() — Sentry error tracking setup
│   │   └── lextari_auth_init.dart       # initLextariAuth() — Supabase client setup
│   ├── network/
│   │   ├── api_client.dart                # HTTP client → FastAPI
│   │   └── ws_client.dart                 # WebSocket client → FastAPI
│   ├── router/
│   │   ├── app_router.dart                # AppRouter class — GoRouter config, routes, auth redirect
│   │   └── auth_guard.dart                # AuthGuard — pure function for auth-based navigation
│   └── theme/
│       ├── app_colors.dart                # All colour tokens as static Color constants
│       ├── app_typography.dart            # Typography tokens (Lexend weights)
│       └── app_theme.dart                 # Material3 ThemeData with ColorScheme.fromSeed
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart       # AuthRepository + @riverpod providers (ViewModel)
│   │   │   ├── auth_repository.g.dart     # Generated
│   │   │   └── lextari_auth.dart        # Service: Supabase auth wrapper (static API)
│   │   └── presentation/
│   │       ├── login_page.dart            # View: ConsumerStatefulWidget — Form + email/password
│   │       └── signup_page.dart           # View: ConsumerStatefulWidget — 4 fields + terms
│   ├── dashboard/
│   │   ├── data/
│   │   │   ├── dashboard_providers.dart   # ViewModel: @riverpod providers (stream, state)
│   │   │   └── dashboard_providers.g.dart # Generated
│   │   ├── domain/
│   │   │   ├── dashboard_update.dart      # @freezed sealed union (WS payloads)
│   │   │   ├── dashboard_update.freezed.dart
│   │   │   ├── dashboard_update.g.dart
│   │   │   ├── growth_health_score.dart   # GHS algorithm (pure domain logic)
│   │   │   ├── sensor_key.dart            # Enum: soilMoisture, temperature, humidity, waterLevel
│   │   │   ├── sensor_reading.dart        # Data model with staleness tracking
│   │   │   └── water_system_state.dart    # Pump/mist/refill status
│   │   └── presentation/
│   │       ├── dashboard_screen.dart      # View: ConsumerStatefulWidget — pinned top + scrollable sensor cards
│   │       ├── dashboard_shell.dart       # Shell: green bg + ellipse + floating nav bar (carousel)
│   │       └── widgets/
│   │           ├── action_switch.dart     # Toggle pill with animated knob (Mist/Water/Refill)
│   │           ├── health_score_card.dart # GHS card with gauge + status + warning
│   │           ├── mini_gauge.dart        # Circular arc gauge (CustomPaint, reusable)
│   │           └── sensor_card.dart       # Sensor reading card (gauge + info + "More")
│   └── splash/
│       └── presentation/
│           └── splash_screen.dart         # View: StatelessWidget — decorative SVG + CTA
└── shared/
    ├── widgets/
    │   ├── app_text_field.dart             # Themed outlined input with floating label
    │   ├── app_button.dart                 # 4 variants + loading state
    │   ├── background_ellipse.dart         # Configurable decorative SVG
    │   ├── lextari_logo.dart             # Brand leaf illustration SVG
    │   ├── health_gauge.dart               # Circular gauge (CustomPaint)
    │   ├── sensor_tile.dart                # Sensor value + skeleton + stale indicator
    │   ├── status_badge.dart               # Colored chip
    │   ├── sensor_error_boundary.dart      # Per-widget error boundary
    │   └── offline_banner.dart             # Connectivity banner
    └── notifications/
        ├── notification_service.dart       # Toastification wrapper
        ├── lextari_notification_overlay.dart  # ToastificationWrapper root widget
        ├── lextari_toast.dart            # Custom branded toast widget
        └── app_dialog.dart                # Modal dialog utility
```

---

## Where to put code

| Type | Location | Example |
|------|----------|---------|
| View (screen) | `lib/features/{name}/presentation/` | `lib/features/auth/presentation/login_page.dart` |
| ViewModel (providers) | `lib/features/{name}/data/` | `lib/features/dashboard/data/dashboard_providers.dart` |
| Repository | `lib/features/{name}/data/` | `lib/features/auth/data/auth_repository.dart` |
| Service | `lib/features/{name}/data/` | `lib/features/auth/data/lextari_auth.dart` |
| Domain model | `lib/features/{name}/domain/` | `lib/features/dashboard/domain/sensor_reading.dart` |
| Pure algorithm | `lib/features/{name}/domain/` | `lib/features/dashboard/domain/growth_health_score.dart` |
| Shared widget | `lib/shared/widgets/` | `lib/shared/widgets/app_button.dart` |
| Theme token | `lib/core/theme/` | `lib/core/theme/app_colors.dart` |
| Router | `lib/core/router/` | `lib/core/router/app_router.dart` |
| Network client | `lib/core/network/` | `lib/core/network/api_client.dart` |
| Error handler | `lib/core/errors/` | `lib/core/errors/error_handler.dart` |
| App config | `lib/core/config/` | `lib/core/config/app_config.dart` |
| Init/bootstrap | `lib/core/init/` | `lib/core/init/sentry_init.dart` |
| Notification/overlay | `lib/shared/notifications/` | `lib/shared/notifications/notification_service.dart` |
| Test | `test/{unit,widgets}/{subdir}/` | `test/widgets/shared/app_button_test.dart` |

---

## MVVM mapping

The MVVM layers in this project map to Flutter as follows:

```
┌─────────────────────────────────────────────────────────────┐
│                        View Layer                           │
│   presentation/ screens — ConsumerWidget / ConsumerStatefulWidget │
│   Purely visual: builds UI from ViewModel state             │
│   Examples: login_page.dart, dashboard_screen.dart          │
└──────────────────────────┬──────────────────────────────────┘
                           │ watches / reads
┌──────────────────────────▼──────────────────────────────────┐
│                     ViewModel Layer                         │
│   Riverpod @riverpod providers in data/                     │
│   Holds reactive state, exposes methods to View             │
│   Examples: dashboard_providers.dart (stream + state)       │
└──────────────────────────┬──────────────────────────────────┘
                           │ calls
┌──────────────────────────▼──────────────────────────────────┐
│                    Repository Layer                          │
│   Data/ files — single source of truth                      │
│   Coordinates between ViewModel and external services       │
│   Examples: auth_repository.dart                            │
└──────────────────────────┬──────────────────────────────────┘
                           │ uses
┌──────────────────────────▼──────────────────────────────────┐
│                     Service Layer                           │
│   External API wrappers (Supabase, FastAPI HTTP/WS)         │
│   Stateless, static methods                                 │
│   Examples: lextari_auth.dart, api_client.dart            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Domain Layer                              │
│   Pure Dart models + algorithms (NO Flutter imports)        │
│   Examples: sensor_reading.dart, growth_health_score.dart   │
└─────────────────────────────────────────────────────────────┘
```

**Rule of thumb:** Views never import services or network clients directly. They only see ViewModels (providers). ViewModels call repositories. Repositories call services. Domain models flow between all layers.

---

## Code Generator

This project uses Riverpod codegen, Freezed, and JsonSerializable. Generated files are **committed to git**.

### When to run

```bash
dart run build_runner build
```

After adding/editing any file with `@riverpod`, `@freezed`, or `@JsonSerializable`.

### Package coordination

All codegen packages must be upgraded as a set — never one at a time:

| Package | Version | Role |
|---------|---------|------|
| `flutter_riverpod` | 3.2.1 | Runtime |
| `riverpod_annotation` | ^4.0.2 | Annotations |
| `riverpod_generator` | ^4.0.3 | Codegen (dev) |
| `freezed_annotation` | ^3.1.0 | Sealed unions |
| `freezed` | ^3.2.5 | Codegen (dev) |
| `json_annotation` | ^4.12.0 | JSON |
| `json_serializable` | ^6.14.0 | Codegen (dev) |
| `build_runner` | ^2.15.0 | Runner (dev) |
