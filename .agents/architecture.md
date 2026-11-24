# Architecture

Android-first Lextari Flutter app. Optimize for clear ownership, testability, and 1:1 parity between UI, state, and backend contracts.

## Layers

- `lib/main.dart`: zone/bootstrap/run only.
- `lib/bootstrap.dart`: initializes bindings, env, storage, notifications, and provider container inputs.
- `lib/app.dart`: root app, theme, router, manager stack.
- `lib/managers/`: app lifecycle/platform concerns composed by `buildManagerStack`.
- `lib/core/`: config, errors, logging, network, router, storage, utils. No feature UI.
- `lib/ui/`: pure design system. Tokens, theme, primitives, motion. No Riverpod, no feature/domain/data imports.
- `lib/widgets/`: app-aware reusable compositions built from `ui` + view models.
- `lib/providers/`: app/config/state/actions providers. Shared state orchestration.
- `lib/features/<feature>/domain`: entities/value objects/repository interfaces. No Flutter/UI/data imports.
- `lib/features/<feature>/data`: DTOs, API/storage adapters, repository implementations. No presentation/ui imports.
- `lib/features/<feature>/presentation`: screens/widgets/controllers. No direct data implementation imports.
- `lib/features/<feature>/providers`: feature-scoped Riverpod providers/actions.

## Dependency Rules

- `ui` -> Flutter/prism_ui/ui only.
- `widgets` -> `ui`, domain/view models, Flutter.
- `presentation` -> `widgets/ui/providers/domain`, not `data/*` implementations.
- `providers/actions` -> domain/repository interfaces or feature repositories exposed through providers.
- `data` -> core/network/storage/domain DTO mapping; no presentation/widgets.
- `domain` -> pure Dart/types only.

Enforced by `test/lint/ui_layering_test.dart` and `test/lint/layer_boundaries_test.dart`.

## Backend Parity

- Backend contract DTOs/interfaces have matching Dart domain/data models and runtime parsing.
- Endpoint paths and method names are centralized in API/repository classes; screens never call HTTP directly.
- Error mapping is centralized in `core/errors` and surfaced through typed failures/states.
- Any backend contract change requires updating model, provider/action, presentation state, and tests.

## Android-Only

- Primary target is Android. Avoid platform-specific abstractions unless needed for Android.
- Managers handle Android lifecycle/notifications/connectivity/session concerns.
