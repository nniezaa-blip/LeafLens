# Lextari Design Brief

> **Purpose:** The visual and experiential direction behind Lextari — brand
> intent, design principles, and screen-by-screen design rationale.
> **Token source:** `lib/core/theme/app_colors.dart`, `app_typography.dart`
> **Detailed spec:** [FRONTEND_DESIGN_SYSTEM.md](FRONTEND_DESIGN_SYSTEM.md)

---

## 1. Design Vision

Lextari should feel like **a calm, living houseplant companion** — not a
utilitarian dashboard. The emotional target is *reassurance*: open the app,
glance, and know your plant is fine.

**Design pillars**

1. **At-a-glance clarity** — one health score speaks before any numbers do.
2. **Calm, organic palette** — sage/green tones that echo foliage, never a
   clinical white lab UI.
3. **Reduce, don't overwhelm** — raw telemetry is secondary; interpretation is primary.
4. **Graceful imperfection** — offline, stale, and error states are designed,
   not afterthoughts.

---

## 2. Brand Identity

| Element | Value |
|---------|-------|
| Name | **Lextari** |
| Logotype | All-caps "LEXTARI", SemiBold, white on green |
| Tagline | "Smarter Care for Healthier Plants" |
| Mark | Stylised leaf illustration SVG (`assets/images/splash_illustration.svg`) |
| Mood | Organic, modern, trustworthy, unobtrusive |

---

## 3. Colour System

All colours live in `lib/core/theme/app_colors.dart`. **No hardcoded hex in
widgets.**

| Token | Hex | Role |
|-------|-----|------|
| `lightGreenBg` | `#A3B88C` | Splash/shell background — the brand surface |
| `mediumGreen` | `#409761` | Primary actions, links, avatar |
| `deepGreen` | `#083722` | Headings, brand emphasis |
| `offWhite` | `#F8F9FA` | Form screen backgrounds |
| `offBlack` | `#1A1A1A` | Google button bg, text on light |
| `white` | `#FFFFFF` | Text on dark |
| `redAlert` | `#D05555` | Error states, critical gauges |
| `cardBackground` | `0xB3D9D9D9` | Sensor / health cards (frosted) |
| `gaugeGreen` | `0x991B6F0A` | Healthy sensor gauges |
| `gaugeOrange` | `0x99FFB703` | Warning sensor gauges |
| `switchBackground` | `0x9960AE88` | Action switch pill |
| `switchTrack` | `0xFF316763` | Toggle track |
| `navBarBackground` | `0xA6263626` | Floating bottom nav bar |
| `warningText` | `0xD9E5A00A` | Health alert warning text |

**Semantic mapping (GHS status):**
Optimal → green · Moderate → light green · Caution → yellow · Danger → orange ·
Critical → `redAlert`.

---

## 4. Typography

**Single typeface: Lexend** (variable weight, embedded in the binary — no
`google_fonts`, no network font loading, 175 KB).

| Weight | UI role |
|--------|---------|
| Light 300 | Graph labels, muted footer |
| Regular 400 | Body text, sensor descriptions |
| Medium 500 | Form input labels |
| SemiBold 600 | Screen titles, button text |
| Bold 700 | Card titles, section headers |
| ExtraBold 800 | GHS gauge score, sensor values |

Rationale: Lexend is explicitly designed to improve reading fluency — a good
fit for a glanceable health readout.

---

## 5. Layout Principles

- **Pinned information, scrollable detail.** On the dashboard, greeting,
  controls, and health score stay fixed; only sensor cards scroll. The user
  never has to scroll to learn the plant's status.
- **Generous spacing.** Explicit `SizedBox` gaps over `Spacer`, so rhythm is
  deliberate and predictable.
- **Cards, not tables.** Frosted translucent cards (`cardBackground`) float over
  the green surface, keeping the organic feel.
- **Pills, not rectangles.** Status and buttons use `StadiumBorder()`.
- **Edge-to-edge decoration.** The splash ellipse deliberately bleeds outside
  `SafeArea` for a full-canvas organic shape.

---

## 6. Screen-by-Screen Intent

### 6.1 Splash (`/splash`)
- **Intent:** Brand moment + single clear entry point.
- Green canvas, decorative SVG ellipse bleeding off the bottom-right, leaf logo,
  brand header, and a single "Get Started" pill.
- No auth logic — always public.

### 6.2 Login (`/login`)
- **Intent:** Fast, low-friction return.
- Off-white canvas, large "Login" title, optional Google button, "Or continue
  with Email" divider, email + password fields, primary button with loading
  spinner, and a "Sign up" link.
- Errors appear **inline above the button**, keeping form state intact.

### 6.3 Sign Up (`/signup`)
- **Intent:** Trustworthy onboarding.
- Same pattern as login plus name and phone fields and a terms checkbox.
- Terms error renders inline below the checkbox.

### 6.4 Dashboard (`/dashboard`)
- **Intent:** Instant plant status + control.
- Greeting header (avatar = logout), three actuator toggles (Mist / Water /
  Refill) as animated pills, the GHS health score card with gauge and warning,
  then three sensor cards each with a `MiniGauge`.

### 6.5 Shell & Navigation
- Floating translucent bottom nav bar over a shared green canvas.
- Horizontal drag carousel between branches; animated active indicator.

### 6.6 Stats & Settings (placeholders)
- Reserved space for 30-day trend charts and species/threshold configuration.

---

## 7. Motion & Feedback

| Interaction | Motion |
|-------------|--------|
| Tab switch | Horizontal carousel slide, `snapThreshold = 0.35`, rubber-band `0.3` |
| Action switch | Animated knob |
| Button submit | Inline loading spinner |
| Toasts | Slide from top; success 3s, error 5s |
| Dialogs | Themed modal, `barrierDismissible: false` |

Motion is functional, not ornamental — it confirms state changes and keeps the
interface feeling responsive.

---

## 8. States to Design For

Every component has more than a happy path. Designed states:

| State | Treatment |
|-------|-----------|
| Loading | Skeleton (shimmer) — never a blocking spinner |
| Stale | Warning icon + error-coloured value |
| Error | Per-widget `SensorErrorBoundary` isolation |
| Offline | `OfflineBanner`, cached data with stale marker |
| Empty | Placeholder copy ("Coming soon") on Stats/Settings |

---

## 9. Accessibility

- Material 3 `ColorScheme.fromSeed` keeps contrast consistent.
- Status is conveyed by **label + colour**, never colour alone.
- Single, highly legible typeface; ExtraBold only for the primary number.
- Touch targets use pill/stadium shapes with comfortable height.

---

## 10. Assets

| File | Used by |
|------|---------|
| `assets/images/splash_ellipse.svg` | `BackgroundEllipse` |
| `assets/images/splash_illustration.svg` | `LextariLogo` |
| `assets/images/google_logo.svg` | Google sign-in buttons |

---

## 11. Related Documents

| Document | Purpose |
|----------|---------|
| [FRONTEND_DESIGN_SYSTEM.md](FRONTEND_DESIGN_SYSTEM.md) | Tokens + widget spec |
| [WIDGET_LIBRARY.md](WIDGET_LIBRARY.md) | Shared widget constructors |
| [SCREENS_AND_NAVIGATION.md](SCREENS_AND_NAVIGATION.md) | Screen layout trees |
| [APP_FLOW.md](APP_FLOW.md) | User journeys |
