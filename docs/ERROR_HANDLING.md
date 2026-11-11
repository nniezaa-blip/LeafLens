# Lextari Error Handling & Notification System

> **Three-tier system:** User-facing notifications → Sentry logging → In-memory metrics  
> **Introduced:** 27 May 2026  
> **Packages added:** `toastification: ^3.2.0`, `sentry_flutter: ^9.0.0`

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Tier 1 — User-Facing](#2-tier-1--user-facing)
   - 2.1 [Inline Form Errors](#21-inline-form-errors)
   - 2.2 [Toast Notifications](#22-toast-notifications)
   - 2.3 [Modal Dialogs](#23-modal-dialogs)
3. [Tier 2 — Logging (Sentry)](#3-tier-2--logging-sentry)
4. [Tier 3 — Metrics](#4-tier-3--metrics)
5. [Centralised Error Handler](#5-centralised-error-handler)
6. [File Reference](#6-file-reference)
7. [Decision Tree — What to Use Where](#7-decision-tree--what-to-use-where)
8. [API Reference](#8-api-reference)
   - 8.1 [NotificationService](#81-notificationservice)
   - 8.2 [ErrorHandler](#82-errorhandler)
   - 8.3 [showAppDialog](#83-showappdialog)

---

## 1. Architecture Overview

```
                    ┌──────────────────────────────────┐
                    │         ApiClient._handle()        │
                    │  ┌──────────────────────────────┐  │
                    │  │  401 → handleSilent(session)  │  │
                    │  │  4xx → handleSilent(api)      │  │  Tier 3: always counted
                    │  │  5xx → handle(api)            │  │  Tier 2: Sentry (5xx/network)
                    │  └──────────┬───────────────────┘  │  Tier 1: toast (5xx only)
                    └─────────────┼────────────────────┘
                                  │ throws Failure
                                  ▼
                    ┌─────────────────────────────┐
                    │   Screen catch blocks         │
                    │                               │
                    │  on InvalidCredentialsFailure  │──→ Inline red text
                    │  on Failure → ErrorHandler     │──→ Toast + Sentry + count
                    │  on Exception → UnknownFailure │──→ Wrapped + handled
                    └─────────────────────────────┘
```

Every API response passes through `ApiClient._handle()` which:
1. Counts the failure in metrics (Tier 3)
2. Sends it to Sentry if it's a 5xx or network error (Tier 2)
3. Shows a toast only for 5xx errors (Tier 1)

Screens that need **inline form errors** (wrong password, validation) catch
specific `Failure` subclasses before the error reaches the generic handler.
Everything else is handled automatically.

---

## 2. Tier 1 — User-Facing

Three distinct channels based on severity and context:

### 2.1 Inline Form Errors

**Purpose:** Keep the user on the form so they can correct and retry immediately.

**Where:** Login page (`login_page.dart`), Sign-up page (`signup_page.dart`).

**How it works:**
- Screen catches `InvalidCredentialsFailure` specifically
- Sets `_formError` state string
- Red `Text` widget renders above the submit button
- Error clears on next submission attempt

```dart
try {
  await repo.login(email, password);
  if (mounted) context.go('/dashboard');
} on InvalidCredentialsFailure {
  setState(() => _formError = 'Invalid email or password. Please try again.');
} on Failure catch (e) {
  ErrorHandler.handle(e);      // toast + Sentry + count
} on Exception catch (e) {
  ErrorHandler.handle(UnknownFailure(e.toString()));
} finally {
  if (mounted) setState(() => _loading = false);
}
```

**Do NOT use a dialog for form errors** — it forces the user to dismiss, then
re-enter everything. Inline is faster and keeps form state intact.

### 2.2 Toast Notifications

**Purpose:** Transient feedback for operations the user already completed.

**Position:** Top of screen (below app bar/safe area).

**Package:** `toastification` (wrapped by `NotificationService`).

| Type | Colour | Auto-dismiss | Use case |
|------|--------|-------------|----------|
| `success` | Green | 3s | Settings saved, operation started |
| `error` | Red | 5s | Server error, network failure |
| `warning` | Yellow | 4s | Rate-limited, stale data |
| `info` | Blue | 4s | General information |

```dart
// From anywhere in the app — no context needed after init()
NotificationService.error(
  'Connection lost',
  description: 'Check your internet and try again.',
);
```

The service is initialised once in `main.dart` with the root navigator key:
```dart
NotificationService.init(rootNavigatorKey);
```

The rest of the app never imports `toastification` directly. To swap the
underlying package, only `notification_service.dart` changes.

### 2.3 Modal Dialogs

**Purpose:** Blocking information that demands user acknowledgment.

**Function:** `showAppDialog<T>()` in `app_dialog.dart`.

```dart
// Info dialog (no meaningful return)
await showAppDialog(
  context: context,
  title: 'Session Expired',
  message: 'Please log in again.',
);

// Confirm/cancel dialog
final confirmed = await showAppDialog<bool>(
  context: context,
  title: 'Delete device?',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  confirmColor: AppColors.redDark,
);
if (confirmed == true) { /* delete */ }
```

**Rules:**
- `barrierDismissible` defaults to `false` — the user must tap a button
- Confirm returns `true`, cancel/dismiss returns `null`
- Always use themed colours from `AppColors`

---

## 3. Tier 2 — Logging (Sentry)

**Purpose:** Capture actionable errors in production for developer investigation.

**Package:** `sentry_flutter: ^9.0.0`

**Configuration:** Optional — passed via `--dart-define=SENTRY_DSN=...` at
build time. Without it, initialisation is skipped silently.

```dart
// main.dart
await SentryFlutter.init(
  (options) => options
    ..dsn = dsn
    ..tracesSampleRate = 0.2,
  appRunner: () {},
);
```

**What gets sent to Sentry:**

| Error type | Sent to Sentry? | Rationale |
|-----------|----------------|-----------|
| HTTP 5xx | Yes | Server is broken — developer needs to know |
| Network failure | Yes | Connectivity problem worth investigating |
| HTTP 4xx (except 5xx) | No | Expected business logic — not a bug |
| Session expired (401) | No | Expected flow — redirect handles it |
| Validation error (422) | No | User input issue — handled inline |
| Invalid credentials | No | Normal auth rejection |

Sentry captures happen inside `ErrorHandler._log()`, gated by `shouldReport`
and guarded by `!kDebugMode` (no Sentry calls during development).

---

## 4. Tier 3 — Metrics

**Purpose:** Track error frequency for thesis methodology and debugging.

**Storage:** In-memory `Map<String, int>` in `ErrorHandler`.

Every single failure, regardless of type, is counted:
```dart
static void _count(Failure failure) {
  final key = failure.runtimeType.toString();
  _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
}
```

**Access:**
```dart
ErrorHandler.errorCounts
// → { 'NetworkFailure': 3, 'InvalidCredentialsFailure': 1, 'ApiFailure': 7 }
```

This can be displayed in a debug panel, logged during testing, or included in
thesis results as evidence of error distribution.

---

## 5. Centralised Error Handler

**Class:** `ErrorHandler` in `lib/core/errors/error_handler.dart`.

### Methods

| Method | Shows toast | Logs to Sentry | Counts | When to use |
|--------|------------|---------------|--------|-------------|
| `handle(Failure)` | Yes | Yes (5xx/net) | Yes | Unexpected/transient errors |
| `handleSilent(Failure)` | No | Yes (5xx/net) | Yes | Expected errors with dedicated UI |

### What the ApiClient does automatically

`ApiClient._handle()` routes every non-2xx response through `ErrorHandler`:

| HTTP status | Handler called | User sees |
|-------------|---------------|-----------|
| 401 | `handleSilent(SessionExpiredFailure)` | Nothing — GoRouter redirects |
| 422 | `handleSilent(ApiFailure)` | Nothing — handled inline by form |
| 429 | `handleSilent(ApiFailure)` | Nothing — screen shows inline |
| 4xx (other) | `handleSilent(ApiFailure)` | Nothing — handled by screen |
| 500+ | `handle(ApiFailure)` | Toast: "Server error" |
| Network error | `handle(NetworkFailure)` | Toast: "Connection lost" |

### Failure hierarchy

All in `lib/core/errors/failures.dart`:

```dart
sealed class Failure implements Exception {}

class NetworkFailure extends Failure {}           // No internet / DNS / timeout
class ApiFailure extends Failure {                 // HTTP non-2xx
  final int statusCode;
  final String body;
}
class SessionExpiredFailure extends Failure {}     // 401 → token invalid
class InvalidCredentialsFailure extends Failure {} // Wrong email/password
class UnknownFailure extends Failure {             // Non-Failure exception wrapper
  final String message;
}
```

---

## 6. File Reference

| File | Lines | Role |
|------|-------|------|
| `lib/shared/notifications/notification_service.dart` | 165 | Wraps `toastification` — four methods: `success`, `error`, `warning`, `info`. Initialised once with navigator key. |
| `lib/shared/notifications/app_dialog.dart` | 79 | `showAppDialog<T>()` — standardised modal dialog with themed buttons, `StadiumBorder`, `AppColors`. |
| `lib/core/errors/error_handler.dart` | 132 | `ErrorHandler` — central dispatch for logging (Sentry), metrics (counts), and user-facing notifications (toasts). |
| `lib/core/errors/failures.dart` | 44 | Typed `Failure` hierarchy implementing `Exception`. |
| `lib/core/network/api_client.dart` | 82 | HTTP client — `_handle()` routes every failure through `ErrorHandler` before throwing. |

---

## 7. Decision Tree — What to Use Where

```
Is the error related to a form submission?
  │
  ├─ YES: Is it a specific, expected failure (wrong password, duplicate email)?
  │   ├─ YES → Show inline error text in the form. Don't use a toast or dialog.
  │   └─ NO  → Fall through to ErrorHandler.handle() — it shows a toast.
  │
  └─ NO: Is it triggered by a user action (RPC command, save)?
      │
      ├─ YES → Use NotificationService.success/error above the form.
      │       Auto-dismiss for success, persistent for error with retry option.
      │
      └─ NO: Is it a system event (session expired, account disabled)?
          │
          ├─ Session expired → GoRouter redirect handles it. No toast needed.
          │
          └─ Critical / blocking → showAppDialog(). User must acknowledge.
```

---

## 8. API Reference

### 8.1 NotificationService

```dart
// Initialisation (once in main.dart)
NotificationService.init(rootNavigatorKey);

// Methods (all static)
NotificationService.success(String title, {String? description, Duration? duration});
NotificationService.error(String title, {String? description, Duration? duration, VoidCallback? onRetry});
NotificationService.warning(String title, {String? description, Duration? duration});
NotificationService.info(String title, {String? description, Duration? duration});
NotificationService.show(NotificationMessage msg);
```

All methods are safe to call before `init()` — they silently return if
`currentContext` is null.

### 8.2 ErrorHandler

```dart
// Full report — use for unexpected errors
ErrorHandler.handle(Failure failure);

// Silent report — use for expected errors with dedicated UI
ErrorHandler.handleSilent(Failure failure);

// Metrics snapshot
ErrorHandler.errorCounts → Map<String, int>
```

### 8.3 showAppDialog

```dart
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,       // Default: "OK"
  String? cancelLabel,         // null = no cancel button
  bool barrierDismissible,     // Default: false
  Widget? icon,
  VoidCallback? onConfirm,
  Color? confirmColor,         // Default: AppColors.mediumGreen
});
```
