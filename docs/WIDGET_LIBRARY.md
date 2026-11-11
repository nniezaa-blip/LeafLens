# Lextari Widget Library

Shared widgets in `lib/shared/widgets/` and dashboard-specific widgets in `lib/features/dashboard/presentation/widgets/`.

---

## Shared Widgets (`lib/shared/widgets/`)

### AppTextField

Themed outlined input with floating label. Used in login and signup forms.

```dart
AppTextField({
  String? hint,                          // Label text, floats on focus
  bool obscureText = false,              // Password mode
  TextEditingController? controller,     // External controller
  String? Function(String?)? validator,  // Form validation
  TextInputType keyboardType = TextInputType.text,
  Widget? prefixIcon,                    // Left icon
  Widget? suffixIcon,                    // Right icon (e.g. visibility toggle)
})
```

**States:** Normal, focused, validation error.

---

### AppButton

Styled button with 4 variants and loading state.

```dart
enum AppButtonVariant { primary, secondary, outline, text }

AppButton({
  required String label,
  VoidCallback? onPressed,               // null = disabled
  AppButtonVariant variant = AppButtonVariant.primary,
  IconData? icon,
  bool loading = false,                  // shows spinner, disables
  double? width,                         // fixed width if needed
})
```

| Variant | Widget | Usage |
|---------|--------|-------|
| `primary` | `FilledButton` | Main CTA (Login, Sign Up) |
| `secondary` | `FilledButton.tonal` | Google sign-in |
| `outline` | `OutlinedButton` | Secondary actions |
| `text` | `TextButton` | Tertiary actions |

**States:** Normal, disabled (onPressed null), loading (spinner).

---

### BackgroundEllipse

Decorative SVG with fractional sizing. Used behind splash screen content.

```dart
BackgroundEllipse({
  String assetPath = 'assets/images/splash_ellipse.svg',
  double widthFactor = 0.9,              // % of parent width
  double heightFactor = 0.9,             // % of parent height
  Alignment alignment = Alignment.bottomRight,
  BoxFit fit = BoxFit.contain,
})
```

Must be placed **without** `SafeArea` — decorative elements need to bleed to screen edge.

---

### LextariLogo

Brand logo — leaf illustration SVG.

```dart
const LextariLogo()
```

Renders `assets/images/splash_illustration.svg` at natural size.

---

## Dashboard Widgets (`lib/features/dashboard/presentation/widgets/`)

### ActionSwitch

Toggle pill used in the dashboard action row. Shows an icon, a label, and a toggle indicator. The pill background is semi-transparent green; the toggle track is dark teal with a white circle when active.

```dart
ActionSwitch({
  required IconData icon,        // Left-side icon (e.g. Icons.cloud_outlined)
  required String label,         // Text inside the toggle track
  required bool value,           // Current on/off state
  required ValueChanged<bool> onChanged,
})
```

| State | Visual |
|-------|--------|
| Off | White circle on left side of track |
| On | White circle on right side of track |

**Size:** 180 × 62px. Three switches in a horizontal `ListView` (560px total — scrolls on most phones).

---

### MiniGauge

Circular gauge that shows a value as an arc with a percentage label in the center. Used in sensor cards and the health score card.

```dart
MiniGauge({
  required double value,         // Normalised 0.0–1.0
  required Color color,          // Arc colour
  double size = 152,             // Diameter in logical pixels
})
```

- Arc sweeps clockwise from the top, proportional to `value`
- Inner white circle covers the arc center
- Text shows `'${(value * 100).round()}%'` in the center

---

### SensorCard

Sensor reading card displayed on the dashboard. Shows a `MiniGauge` on the left, the sensor name and unit icon on the top-right, a status message, and a "More" link at the bottom-right.

```dart
SensorCard({
  required String sensorName,    // e.g. "Temperature", "Humidity"
  required double value,         // Numeric value (passed to MiniGauge as value/100)
  required String unit,          // e.g. "°C", "%"
  required IconData unitIcon,    // e.g. Icons.thermostat
  required String statusText,    // e.g. "Temperature is normal"
  required Color gaugeColor,     // Arc colour
  required VoidCallback onMoreTap,
  bool isStale = false,          // Shows stale indicator when true
})
```

| State | Visual |
|-------|--------|
| Normal | Gauge arc + sensor name + unit + status text + "More" |
| Stale | Warning indicator (future: icon + error colour) |

**Height:** 191px. Background: `AppColors.cardBackground`. Border radius: 25px.

---

### HealthScoreCard

Overall health score card displayed above the sensor list. Shows the GHS gauge, a combined status message, and an optional warning line when the plant needs immediate attention.

```dart
HealthScoreCard({
  required double score,              // GHS score 0–100
  required String statusText,         // Combined status description
  required Color gaugeColor,          // Arc colour
  String? warningText,                // e.g. "STOP WATERING!"
})
```

| State | Visual |
|-------|--------|
| Normal | Gauge + "Health Score" title + status text |
| Warning | Same + warning text in `AppColors.warningText` below status |

**Height:** 191px. Same card style as `SensorCard`.

---

## Legacy Shared Widgets (in `lib/shared/widgets/`)

These are from the earlier design phase. Some are still used, some are superseded by dashboard-specific widgets above.

### HealthGauge

Circular gauge showing the Growth Health Score with colour-coded arc. Green → yellow → red as score drops.

```dart
HealthGauge({
  required HealthScoreResult result,     // score + status + componentScores
  double size = 200,                     // width and height
})
```

| Score | Status | Arc Colour |
|-------|--------|------------|
| ≥ 80 | Optimal | `#4CAF50` (green) |
| ≥ 65 | Moderate | `#8BC34A` (light green) |
| ≥ 50 | Caution | `#FFC107` (yellow) |
| ≥ 30 | Danger | `#FF9800` (orange) |
| < 30 | Critical | `theme.colorScheme.error` (red) |

Implementation uses `CustomPaint` with `_RingPainter` — background circle + score arc. Superseded by `MiniGauge` for dashboard use.

---

### SensorTile

Displays a single sensor value with label, unit, and stale indicator.

```dart
SensorTile({
  required SensorKey sensor,             // defines name + unit
  SensorReading? reading,               // null → skeleton placeholder
})
```

**States:**
- **Skeleton** (reading is null) — grey placeholder bars, no text
- **Normal** — sensor name, value, unit, age label
- **Stale** (reading older than 30 min) — warning icon + error colour value

Superseded by `SensorCard` for dashboard use.

---

### StatusBadge

Coloured chip showing health status at a glance.

```dart
StatusBadge({
  required HealthStatus status,
})
```

| Status | Label | Dot Colour |
|--------|-------|------------|
| `optimal` | "Optimal" | `#4CAF50` |
| `moderate` | "Moderate" | `#8BC34A` |
| `caution` | "Caution" | `#FFC107` |
| `danger` | "Danger" | `#FF9800` |
| `critical` | "Critical" | `theme.colorScheme.error` |

---

### SensorErrorBoundary

Catches build errors in a single sensor widget and shows a fallback instead of crashing the whole dashboard.

```dart
SensorErrorBoundary({
  required String label,                 // "Temperature", "Humidity", etc.
  required Widget child,                 // the sensor widget to guard
})
```

**States:**
- **Normal** — renders `child` transparently
- **Error** — shows "Temperature unavailable" with icon + Retry button

---

### OfflineBanner

Connectivity indicator that watches `authStateProvider`. Shown when user is unauthenticated (no connection to backend).

```dart
const OfflineBanner()
```

**States:**
- **Authenticated** — `SizedBox.shrink()` (hidden)
- **Unauthenticated** — `MaterialBanner` with cloud_off icon + "No connection" message
