# Lextari Screens & Navigation

**Routes defined in:** `lib/core/router/app_router.dart`

---

## Route Map

| Route | Screen | Widget Type | Status |
|-------|--------|-------------|--------|
| `/splash` | SplashScreen | `StatelessWidget` | ✅ Done |
| `/login` | LoginPage | `ConsumerStatefulWidget` | ✅ Done |
| `/signup` | SignUpPage | `ConsumerStatefulWidget` | ✅ Done |
| `/dashboard` | DashboardScreen | `ConsumerStatefulWidget` | ✅ Done |
| `/stats` | StatsScreen | `StatelessWidget` | ⏳ Placeholder |
| `/settings` | SettingsScreen | `StatelessWidget` | ⏳ Placeholder |

Dashboard, Stats, and Settings are branches of a `StatefulShellRoute.indexedStack` managed by `DashboardShell`.

---

## SplashScreen

**File:** `lib/features/splash/presentation/splash_screen.dart`

The first screen users see. Purely decorative — no auth logic, no state.

### Layout (bottom → top)

```
Scaffold(lightGreenBg)
└── Stack
    ├── BackgroundEllipse()          ← decorative SVG, edge-to-edge, no SafeArea
    └── SafeArea
        └── _SplashContent
            └── Center → Column
                ├── Spacer(flex: 4)
                ├── LextariLogo()
                ├── SizedBox(height: 12)
                ├── _BrandHeader     ← "LEXTARI" + "Smarter Care for Healthier Plants"
                ├── Spacer(flex: 2)
                ├── _GetStartedButton  ← navigates to /login
                └── Spacer(flex: 1)
```

### Key Points

- Decorative ellipse (`BackgroundEllipse`) is **not** in `SafeArea` — needs to bleed to screen edge on notched devices
- No GoRouter redirect logic checks splash — it's always public
- `LextariLogo` renders `assets/images/splash_illustration.svg`
- `BackgroundEllipse` renders `assets/images/splash_ellipse.svg`

---

## LoginPage

**File:** `lib/features/auth/presentation/login_page.dart`

Email/password authentication form. Talks to FastAPI through `AuthRepository`.

### Layout

```
Scaffold(offWhite)
└── SafeArea
    └── Center
        └── Form
            └── SingleChildScrollView
                └── Column(CrossAxisAlignment.stretch)
                    ├── Center → _LoginHeader      ← "Login" (38px SemiBold)
                    ├── _GoogleSignInButton        ← stub (UnimplementedError)
                    ├── _OrDivider                 ← "Or continue with Email"
                    ├── _EmailField                ← AppTextField with email validation
                    ├── SizedBox(height: 12)
                    ├── _PasswordField             ← AppTextField with visibility toggle
                    ├── SizedBox(height: 28)
                    ├── _LoginButton               ← loading spinner when submitting
                    ├── SizedBox(height: 12)
                    └── _SignUpRow                 ← "Don't have an account? Sign up"
```

### State

| Variable | Type | Purpose |
|----------|------|---------|
| `_formKey` | `GlobalKey<FormState>` | Form validation |
| `_emailCtrl` | `TextEditingController` | Email input |
| `_passwordCtrl` | `TextEditingController` | Password input |
| `_obscurePassword` | `bool` | Password visibility toggle |
| `_loading` | `bool` | Button spinner state |
| `_formError` | `String?` | Inline error message (wrong credentials) |

### Flow

1. User taps "Login"
2. Form validates (empty fields show errors)
3. `AuthRepository.login(email, password)` called
4. On success: `authStateProvider` invalidated → GoRouter redirects to `/dashboard`
5. On `InvalidCredentialsFailure`: inline red text above the button
6. On other `Failure`: `ErrorHandler.handle()` → top-of-screen toast + Sentry + metrics
7. Button re-enabled in `finally` block (`mounted`-safe)

---

## SignUpPage

**File:** `lib/features/auth/presentation/signup_page.dart`

Registration form with name, email, phone, password, and terms acceptance.

### Layout

```
Same pattern as LoginPage with:
├── Center → _SignUpHeader          ← "Sign up" (30px SemiBold)
├── _GoogleSignUpButton            ← stub (UnimplementedError)
├── _OrDivider
├── _NameField                     ← AppTextField
├── _EmailField                    ← AppTextField
├── _PhoneField                    ← AppTextField
├── _PasswordField                 ← AppTextField
├── _TermsCheckbox                 ← Checkbox with RichText
├── _SignUpButton                  ← loading spinner
└── _LoginRow                      ← "Already have an account? Login"
```

### Extra State

| Variable | Type | Purpose |
|----------|------|---------|
| `_nameCtrl` | `TextEditingController` | Full name |
| `_phoneCtrl` | `TextEditingController` | Phone number |
| `_agreeToTerms` | `bool` | Terms checkbox |
| `_formError` | `String?` | Inline error message (duplicate email) |
| `_termsError` | `String?` | Inline error below checkbox (terms not accepted) |

### Flow

Same as login but calls `AuthRepository.register()` instead. Terms checkbox must be checked before submission — shows inline red text below the checkbox if skipped.

---

## DashboardShell

**File:** `lib/features/dashboard/presentation/dashboard_shell.dart`

App-level shell wrapping the three dashboard tabs. Manages the green background, decorative ellipse, floating bottom nav bar, and horizontal carousel slide animation between tabs.

### Layout

```
Scaffold
└── Stack
    ├── BackgroundEllipse()                    ← decorative, behind everything
    ├── GestureDetector                        ← horizontal drag for carousel
    │   └── SafeArea
    │       └── _buildAnimatedChild()          ← current tab page (or animated pair during drag)
    └── Positioned(bottom)                     ← floating nav bar
        └── _FloatingNavBar
            └── Stack
                ├── _ActiveIndicator           ← white circle behind active icon
                └── _NavIcon × 3               ← home, stats, settings
```

### Tab Navigation

- `StatefulShellRoute.indexedStack` keeps each branch's State alive across tab switches
- Child routes use `NoTransitionPage` for instant tab switching (no route animation)
- Horizontal drag gesture on the page area triggers carousel animation
- Nav bar taps also trigger the same slide animation via `_handleNavTap`
- Carousel tracks finger during drag, settles to nearest tab on release
- `snapThreshold = 0.35` — 35% of screen width required to trigger tab switch
- Rubber-band dampening (`0.3`) when dragging past the edge

---

## DashboardScreen

**File:** `lib/features/dashboard/presentation/dashboard_screen.dart`

Main dashboard showing live sensor readings, action toggles, and the Growth Health Score.

### Layout

```
Padding(left: 22, top: 24, right: 22)
└── Column(CrossAxisAlignment.stretch)
    ├── [PINNED] _GreetingHeader               ← time-based greeting + avatar (tap to logout)
    ├── SizedBox(height: 16)
    ├── [PINNED] _ActionSwitchesRow             ← 3 horizontal toggle pills (Mist / Water / Refill)
    │   └── SizedBox(height: 62)
    │       └── ListView(scrollDirection: horizontal)
    │           ├── ActionSwitch(label: 'Mist', icon: cloud_outlined)
    │           ├── ActionSwitch(label: 'Water', icon: water_drop_outlined)
    │           └── ActionSwitch(label: 'Refill', icon: autorenew)
    ├── SizedBox(height: 16)
    ├── [PINNED] HealthScoreCard                ← GHS gauge + status + warning text
    ├── SizedBox(height: 12)
    └── [SCROLLABLE] Expanded
        └── ListView(bottom padding: 120)       ← 120px clears the floating nav bar
            ├── SensorCard('Temperature')       ← MiniGauge + value + status + "More"
            ├── SizedBox(height: 12)
            ├── SensorCard('Humidity')
            ├── SizedBox(height: 12)
            └── SensorCard('Soil Moisture')
```

### State

| Variable | Type | Purpose |
|----------|------|---------|
| `_mistOn` | `bool` | Mist maker toggle state |
| `_waterOn` | `bool` | Water pump toggle state |
| `_refillOn` | `bool` | Solenoid valve refill toggle state |

### Key Design Decisions

- **Pinned top, scrollable bottom** — greeting, toggles, and health score stay fixed. Only sensor cards scroll. User sees health status immediately without scrolling.
- **`Expanded` + `ListView`** pattern — `Expanded` fills remaining vertical space, `ListView` scrolls within it. Top section is not affected by scroll.
- **`bottom: 120`** on ListView — clears the floating nav bar so the last SensorCard isn't hidden behind it.
- **3 toggle switches in horizontal ListView** — 3 × 180px + 2 × 10px gaps = 560px. Scrolls horizontally on phones narrower than 560dp (most phones).

---

## StatsScreen (Placeholder)

**File:** `lib/features/stats/presentation/stats_screen.dart`

Currently renders "30-Day Trends — Coming soon". Will contain 30-day historical trend charts for soil moisture, temperature, and humidity.

---

## SettingsScreen (Placeholder)

**File:** `lib/features/settings/presentation/settings_screen.dart`

Currently renders "Settings — Coming soon". Will contain species-specific threshold configuration, notification preferences, and account management.

---

## Navigation

GoRouter with `StatefulShellRoute.indexedStack` and auth redirect (defined in `lib/core/router/app_router.dart`):

```dart
redirect: (context, state) {
  final isLoggedIn = auth.value != null;
  return AuthGuard.call(
    state: state,
    isLoggedIn: isLoggedIn,
    // ...
  );
}
```

### Shell Route Structure

```
StatefulShellRoute.indexedStack
├── Branch 0: /dashboard  → DashboardScreen
├── Branch 1: /stats      → StatsScreen
└── Branch 2: /settings   → SettingsScreen
```

### Auth Redirect Rules

| Current Route | Auth State | Redirect |
|---------------|------------|----------|
| `/splash` | Any | None (stay on splash) |
| Any (not login/signup/splash) | Unauthenticated | → `/login` |
| `/login` or `/signup` | Authenticated | → `/dashboard` |
| All other routes | Authenticated | None |
