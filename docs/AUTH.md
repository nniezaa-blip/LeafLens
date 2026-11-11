# Lextari Authentication (Auth.md)

> **Purpose:** How identity is established, carried, verified, and revoked across
> all four layers of Lextari.
> **Sources:** `lib/features/auth/data/lextari_auth.dart`,
> `auth_repository.dart`, `lib/core/router/auth_guard.dart`,
> `lib/core/network/api_client.dart`, [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 1. Model Overview

Lextari uses **Supabase** (GoTrue) as the identity provider for app users.
There is no custom password store, no custom session table, and no
FavorIoT-side user account.

There are **four distinct credentials** in the system:

| Layer | Credential | Issuer | Holder | Never leaves |
|-------|-----------|--------|--------|--------------|
| App user | Supabase JWT | Supabase | Flutter | — |
| API access | Supabase JWT (Bearer) | Supabase | Flutter → FastAPI | — |
| FavorIoT proxy | FavorIoT API key | FavorIoT | FastAPI | **server** |
| Device | FavorIoT device access token | FavorIoT | ESP32 | device flash |

**Design principle:** the user authenticates **once** (Supabase). FastAPI
verifies that JWT and uses its *own* server-side FavorIoT API key to proxy. The
user never receives, sees, or needs a FavorIoT credential.

---

## 2. Supabase Wrapper — `LextariAuth`

**File:** `lib/features/auth/data/lextari_auth.dart`

A thin static wrapper so **no other file imports `supabase_flutter` directly**.
Swapping the identity provider touches one file.

| Method | Purpose |
|--------|---------|
| `init({url, publishableKey})` | One-time `Supabase.initialize` from `main`/`initApp` |
| `signInWithPassword({email, password})` | Returns `session.accessToken` |
| `signUp({email, password})` | Returns access token, or `null` if email confirmation required |
| `signOut()` | Clears the Supabase session |
| `accessToken` | Current token or `null` (synchronous) |
| `onAuthChange` | `Stream<AuthState>` — login / logout / token refresh |

**Configuration:** `SUPABASE_URL` + `SUPABASE_ANON_KEY` injected at build time
via `--dart-define-from-file` (`AppConfig`). The **anon key is public by design**;
the `service_role` key must never ship in the app.

---

## 3. Repository Layer — `AuthRepository`

**File:** `lib/features/auth/data/auth_repository.dart`

Owns the auth **application logic** and error translation. The UI only sees
typed `Failure`s, never raw Supabase exceptions.

```dart
Future<void> login(String email, String password)     // → ApiClient.token = token
Future<void> register(String email, String password)
Future<void> logout()                                  // → clears session + token
```

### 3.1 Error mapping (never leak provider text)

Supabase's `AuthException.code` is matched first (stable, documented); only the
legacy wrong-password error (`400`, no code) falls back to a message substring.

| Supabase code | User-facing message |
|---------------|---------------------|
| `email_exists` / `user_already_exists` | This email is already registered. |
| `weak_password` | Password is too weak. Try a longer password. |
| `email_not_confirmed` | Please confirm your email before logging in. |
| `validation_failed` | Enter a valid email address. |
| `over_email_send_rate_limit` / `over_request_rate_limit` | Too many attempts. Please wait and try again. |
| `signup_disabled` | Account creation is currently disabled. |
| `email_provider_disabled` | Email sign-up is currently disabled. |
| `user_banned` | This account has been suspended. |
| `captcha_failed` | Verification failed. Please try again. |
| `request_timeout` | The request timed out. Please try again. |
| *(legacy)* `invalid login credentials` | Email or password is incorrect. |
| *(fallback)* | Something went wrong. Please try again. |

`AuthRetryableFetchException` → `NetworkFailure`. The generic fallback guarantees
that raw provider text is never surfaced to the user.

---

## 4. Token Propagation

```
Login/Register success
  → LextariAuth returns accessToken
  → AuthRepository sets ApiClient.token
  → authStateProvider (StreamProvider) emits token
  → ref.read(apiClientProvider).token = token   (dashboard_providers.dart:69-75)
```

Every authenticated HTTP call attaches the token:

```dart
// api_client.dart:24-30
h['Authorization'] = 'Bearer $token';
```

Public calls use `postPublic()` (no `Authorization` header) — intended for
future unauthenticated endpoints; login/register currently go through Supabase
directly, not FastAPI.

---

## 5. Navigation Guard — `AuthGuard`

**File:** `lib/core/router/auth_guard.dart`

A **pure function** (no service access) — fully unit-testable without mocking
Supabase. Called by GoRouter on every navigation.

```dart
static String? call({
  required GoRouterState state,
  required bool isLoggedIn,       // reactive: authStateProvider
  String? currentToken,           // synchronous: LextariAuth.accessToken
})
```

### 5.1 Cold-start correctness

`authenticated = isLoggedIn || currentToken != null`

The `||` matters: on cold start, Supabase restores the session from **secure
storage before the auth stream emits**. Reading the synchronous `accessToken`
prevents a spurious redirect to `/login`.

### 5.2 Redirect rules

| Route | State | Redirect |
|-------|-------|----------|
| `/splash` | authenticated | `/dashboard` |
| `/splash` | unauthenticated | `/login` |
| any non-public | unauthenticated | `/login` |
| `/login`, `/signup` | authenticated | `/dashboard` |
| all other | authenticated | `null` (stay) |

Public routes: `/splash`, `/login`, `/signup`.

---

## 6. Session Lifecycle

```
Login
  └─ signInWithPassword → JWT → token set → redirect /dashboard

App restart
  └─ Supabase restores session from secure storage
       └─ AuthGuard sees currentToken != null → straight to /dashboard

Token refresh
  └─ Supabase auto-refreshes; onAuthChange emits new token
       └─ authStateProvider re-emits → ApiClient.token updated

401 from FastAPI
  └─ ApiClient clears token, raises SessionExpiredFailure (silent)
       └─ guard redirects to /login

Logout
  └─ signOut() → stream emits null → redirect /login
```

---

## 7. API-Side Authorization Boundary

FastAPI is the **policy enforcement point**:

1. Read `Authorization: Bearer <jwt>`.
2. Verify the Supabase JWT signature and expiry.
3. Extract the user id (`sub`).
4. Look up `user_id → platform_device_id` in PostgreSQL (**ownership check**).
5. Query FavorIoT with the server-held API key (`apikey` header).

**Rule:** every device-scoped request must be authorized against the
`devices` mapping. A valid JWT is *not* sufficient — it must map to the
requested device, otherwise the request is rejected (IDOR prevention). See
[THREAT_MODEL.md](THREAT_MODEL.md) §5.

---

## 8. Device Authentication

- **Provisioning:** devices are **pre-registered in the FavorIoT console** by an
  admin. The admin captures the `device_developer_id` and device **access
  token**; the app links the device to a user via `POST /api/v1/devices/link`
  (see [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) §5.1).
- **Telemetry:** after provisioning, the ESP32 holds a **FavorIoT device
  access token** in flash and connects to MQTT (`mqtt.favoriot.com`), using the
  token as its username and password. That token is scoped to a single device
  and never touches the Flutter app.

---

## 9. Rate Limiting & Abuse Controls

| Control | Where | Status |
|---------|-------|--------|
| Supabase email/request rate limits | Supabase | ✅ built-in |
| Rate-limit errors mapped to friendly text | `AuthRepository` | ✅ |
| Per-IP throttling on provisioning | FastAPI (planned) | ⏳ |
| Idempotent `/link` by `platform_device_id` | FastAPI (planned) | ⏳ |

---

## 10. Auth Hardening Checklist

- [x] Single auth provider, single wrapper file.
- [x] Raw provider errors never shown to the user.
- [x] Token attached only over HTTPS (production).
- [x] 401 → clear token + silent redirect (no toast spam).
- [x] Cold-start guard uses synchronous token.
- [ ] JWT signature/expiry verified in FastAPI.
- [ ] Every device request authorised against ownership mapping.
- [ ] Reject expired/`none`-algorithm JWTs.
- [ ] Enforce HTTPS only (HSTS).

---

## 11. Related Documents

| Document | Purpose |
|----------|---------|
| [SECURITY.md](SECURITY.md) | Overall security posture |
| [THREAT_MODEL.md](THREAT_MODEL.md) | Threats to auth boundaries |
| [DATA_SECURITY.md](DATA_SECURITY.md) | Token/PII storage |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Auth layer table + provisioning |
