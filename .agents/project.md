# Project

Lextari is a Flutter Android app for plant health monitoring. Current stack: Flutter/Dart, Riverpod (codegen), go_router, freezed/json_serializable, Hive, secure storage, Firebase messaging/core, HTTP/WebSocket clients.

## Android Focus

Primary target is Android. Keep Android build and runtime healthy. Other platform directories may exist but are not the active product focus.

## Key Commands

```bash
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
flutter run -d android
flutter build apk
```

## Layout

- `lib/main.dart` - minimal entrypoint.
- `lib/bootstrap.dart` - app initialization.
- `lib/app.dart` - root app widget.
- `lib/manager/` - lifecycle/platform/app managers.
- `lib/core/` - config, router, network, storage, errors, utils.
- `lib/ui/` - pure design system (tokens, theme, primitives, motion).
- `lib/widgets/` - app-aware reusable widgets.
- `lib/providers/` - app/config/state/action providers.
- `lib/features/` - feature data/domain/presentation.
