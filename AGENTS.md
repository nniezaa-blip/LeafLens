# AGENTS.md

Entry point for agents working in Lextari (Flutter, Android-focused).

## Read First

- [.agents/project.md](.agents/project.md) - project scope, stack, commands.
- [.agents/rules.md](.agents/rules.md) - coding, Riverpod, UI layering, verification rules.
- [.agents/architecture.md](.agents/architecture.md) - bootstrap, managers, routing, providers, UI/component system.

## Highest Priority Rules

- Android and iOS focus. Do not add iOS/desktop/web-specific abstractions unless required for Android build compatibility.
- Keep changes scoped and explicit. Do not perform unrelated refactors.
- Use `flutter test`, not `dart test`. Run `dart run build_runner build -d` after changing Riverpod providers/models/codegen annotations.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`).
- `lib/ui/` is pure design system: no imports from `features/`, `providers/`, `core/network`, `core/router`, or app state. Compose app-aware widgets in `lib/widgets/` or feature presentation.
- Prefer Riverpod codegen/notifiers for state and actions. UI reads providers; business mutations live in actions/notifiers/repositories, not widgets.
- Keep comments only for non-obvious constraints. Do not narrate code.
- Before reporting done, run `flutter pub get` if deps changed, `flutter analyze`, and covering `flutter test`/build checks. Report skipped checks.
- Commit messages follow Conventional Commits. No `Co-authored-by` agent trailers.
