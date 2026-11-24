---
name: ui-work
description: Use when changing Lextari Flutter UI, screens, widgets, design tokens, animations, routing presentation, or interaction behavior.
---

# UI Work

- Android and iOS focus. Keep changes compatible with Android/iOS build and runtime.
- `lib/ui/` is pure design system: tokens, theme, primitives, motion. It must not import `features/`, `providers/`, `core/network/`, `core/router/`, or repositories.
- `lib/widgets/` composes `ui` primitives with app/domain view models.
- `features/*/presentation` owns screens and feature-specific presentation widgets.
- Reuse existing primitives/tokens before adding new styles. No hardcoded one-off visual systems.
- State belongs in Riverpod providers/notifiers/actions, not widgets.
- After provider/model annotation changes run `dart run build_runner build -d`.
- Verify with `flutter analyze` and covering `flutter test`.
