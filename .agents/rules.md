# Rules

## Dart/Flutter

- Follow `analysis_options.yaml` and keep lints clean.
- Prefer single quotes, trailing commas, `child` last, const/final, explicit return types.
- No `print`; use logger/debugPrint only where appropriate.

## Riverpod / Codegen

- Use Riverpod codegen (`@riverpod`) for providers/notifiers where practical.
- After changing annotated providers/models, run `dart run build_runner build -d`.
- Never hand-edit `*.g.dart` or `*.freezed.dart`.

## UI System

- `lib/ui/` contains pure visual components and tokens. It must not import feature/domain providers or repositories.
- `lib/widgets/` may compose `ui` components with app/domain state.
- Prefer reusable primitives over one-off styled widgets.
- Keep motion intentional: short, smooth, no unnecessary rebuild-heavy animations.

## State / Routing

- Route paths are centralized in router constants/helpers.
- Auth redirect is deterministic and based on current session state.
- Widgets should not own business logic; call actions/providers.

## Verification

- Run `flutter pub get` when dependencies change.
- Run `flutter analyze`.
- Run covering `flutter test` or targeted tests for changed behavior.
- For UI/flow changes, run Android build/run check when toolchain is available.
