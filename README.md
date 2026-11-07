# ARIA

Mobile companion that guards your digital habits — screentime, app limits, and a
calm AI presence that nudges rather than scolds.

Flutter · Riverpod 3 · go_router · Android (iOS-ready abstractions) ·
Clean Architecture (domain / data / presentation)

---

## Status: iteration 1 — kerangka + data mock

The architecture is complete and the app runs end to end on **mock data**. Every
seam where real platform code will land already exists, so moving from mock to
production is a provider override — not a refactor.

What works today:

| Area | State |
| --- | --- |
| Beranda (6 blocks) | live, mock data |
| App Manager (daily limits) | live, limits persist to SharedPreferences |
| Settings (permissions, theme, tone, data) | live, theme persists |
| Motion & Feel principles | **enforced by custom lint** |
| Android `UsageStatsManager` | interface + documented landing site |
| Companion chat backend | interface + stub |

What is deliberately *not* here yet: real usage stats, real permission grants,
and limit enforcement (blocking/warn/breathe). See `FeatureFlags.useMockData`.

---

## The one rule that shapes everything

> **Motion & Feel is not a convention here — it is enforced by the compiler.**

ARIA has two interaction principles, and both are impossible to forget:

1. **Smooth transitions** — a sheet slides up from the bottom with a soft spring,
   landing light, never bouncy.
2. **Quiet haptics** — a light tap, like a fingernail on paper. Never a buzz.

---

## Visual system

The palette and surfaces follow three rules, encoded in `lib/core/theme/`:

1. **One accent hue.** Sage (`#4A7C6F`), desaturated. ARIA's own voice is a
   *tint* of that same sage rather than a second colour, so the companion card
   reads as distinct without introducing a second accent. No purple/blue
   "AI gradient" — it is the most recognisable generic-AI tell, and it works
   against an app whose job is to calm the user.
2. **Warm neutrals only.** Page background is ivory (`#FAF8F4`), never pure
   white; dark mode is espresso (`#141413`), never neutral charcoal or pure
   black. Every grey is tinted toward the same warm hue — mixing warm and cool
   greys is what makes a palette feel accidental.
3. **Nested surfaces (Double-Bezel).** Cards are a thin outer shell holding an
   inner core, the way a glass plate sits in a machined tray. The inner radius is
   derived from the outer (`shell - inset`), so the curves stay concentric. The
   shell is a whisper of tint plus a hairline, not a drawn border; the inner core
   carries a 1px top highlight, which is what makes the surface look lit rather
   than painted.

Supporting pieces:

- **Shadows** (`app_shadows.dart`) are tinted, never black-at-low-opacity, and
  all share one light direction.
- **Texture** (`aria_texture.dart`) adds two off-centre ambient washes and a 3%
  grain field over the whole app, so full-screen backgrounds do not read as flat
  vector fills. The grain is generated once into a tiled shader — no per-frame
  cost.
- **Type** (`app_typography.dart`) spreads weights across 400/500/600/700 rather
  than only 400/700, tightens tracking on display sizes, and applies tabular
  figures to numeric styles so screen-time and count columns line up.

Plus Jakarta Sans is vendored under `assets/fonts/` (OFL 1.1) and declared in
`pubspec.yaml`, so the app renders its first frame identically offline and the
reference renders below are deterministic. There is no runtime font fetch.

The theme reference renders live in `test/golden/` and run as part of
`flutter test`. They render a small fixed composition (nested card, ambient
wash, grain, shadow swatches) once per theme, so a palette, surface or shadow
regression surfaces as a diff. Regenerate after an intentional design change:

```bash
# Writes test/golden/reference_{light,dark}.png
flutter test test/golden/theme_render_test.dart --update-goldens
```

---

## Enforcement

These are enforced in three layers:

### 1. `AriaSheet.show()` — the only way to open a sheet

```dart
// ✅ correct
final choice = await AriaSheet.show<int>(
  context: context,
  builder: (ctx) => MyContent(),
);

// ❌ caught by lint: no_raw_bottom_sheet
showModalBottomSheet(context: context, builder: (_) => MyContent());
```

The spring, the top radius, the drag-to-dismiss, the light haptic on open — all
come from the wrapper, so every sheet added in future matches automatically.

### 2. `AriaTap` — the only way to make something tappable

```dart
// ✅ correct — press scale + light haptic + consistent ripple
AriaTap.button(onTap: save, child: Text('Simpan'))
AriaTap.card(onTap: openDetail, child: MyCard())

// ❌ caught by lint: no_raw_gesture_tap
GestureDetector(onTap: save, child: Text('Simpan'))
```

### 3. `AriaMotion` — the only source of timings

```dart
// ✅ correct
AnimatedContainer(duration: AriaMotion.medium, ...)

// ❌ caught by lint: prefer_aria_duration
AnimatedContainer(duration: Duration(milliseconds: 240), ...)
```

### How enforcement works

`custom_lint/aria_lint/` is a local lint plugin with three rules. It is registered
in `analysis_options.yaml`, so `flutter analyze` fails on violations:

| Rule | Catches |
| --- | --- |
| `no_raw_bottom_sheet` | `showModalBottomSheet`, `showBottomSheet`, `showGeneralDialog` |
| `no_raw_gesture_tap` | bare `GestureDetector`/`InkWell` with `onTap` inside `lib/features/` |
| `prefer_aria_duration` | `Duration(milliseconds: …)` passed to animation APIs |

Verify it is live:

```bash
# prints nothing when clean
dart run custom_lint
```

The `core/` layer is exempt from `no_raw_gesture_tap` and `no_raw_bottom_sheet`,
because `AriaTap` and `AriaSheet` *are* the implementations of the rule. The test
suite (`test/widget/motion_principles_test.dart`) asserts that no haptic call is
ever `heavyImpact` or `mediumImpact`.

---

## Project layout

```
lib/
├─ main.dart            bootstrap entry
├─ bootstrap.dart       one-time setup: locale, prefs, provider overrides
├─ app.dart             MaterialApp.router + theme wiring
├─ core/                cross-feature, depends on no feature
│  ├─ companion/        AriaTone — ARIA's voice
│  ├─ config/           AppConfig, FeatureFlags
│  ├─ constants/        PrefKeys, AssetPaths
│  ├─ di/               providers (prefs, clock, analytics, api)
│  ├─ error/            Failure, Result, exceptions
│  ├─ motion/           ★ AriaSheet, AriaTap, AriaHaptics, AriaMotion
│  ├─ presentation/     AriaCard, AriaScaffold, AriaBarChart, skeletons
│  ├─ routing/          go_router config, routes, shell
│  ├─ theme/            tokens, ThemeData, ThemeMode provider
│  └─ utils/            date/duration/platform helpers
└─ features/
   ├─ home/             Beranda
   ├─ app_manager/      Kelola Aplikasi
   └─ settings/         Pengaturan
```

Each feature has exactly three layers, always in the same shape:

```
features/<name>/
├─ domain/          pure Dart: entities, repository interfaces, use cases
│                   (no Flutter, unit-testable without a widget binding)
├─ data/            DTOs, mappers, datasources (interface + mock + real), repo impls
└─ presentation/    pages, Riverpod providers, widgets
```

Dependencies point inward: `presentation → domain ← data`. The UI never imports a
datasource, and the domain never imports Flutter.

Full tree with per-file notes: see the approved plan in
`.qoder/plans/` or ask the maintainer.

---

## Adding a feature

```bash
dart run dev/gen_clean_arch.dart diary
```

This scaffolds the three layers with correct imports, then:

1. Fill in the entity fields.
2. Register the page in `core/routing/app_router.dart` and add its path to
   `core/routing/routes.dart`.
3. `dart run build_runner build`
4. `flutter analyze && dart run custom_lint && flutter test`

The generator prints the same checklist. Scaffolding a feature is cheaper than
improvising one — that is the point.

---

## Mock → real: the swap

`FeatureFlags.useMockData` (in `core/config/feature_flags.dart`) selects mock
data sources. To go live for one feature, change the datasource provider in that
feature's `presentation/providers/` file:

```dart
final usageStatsSourceProvider = Provider<UsageStatsSource>((ref) {
  if (FeatureFlags.useMockData) return UsageStatsMockSource();
  return const UsageStatsAndroidSource();   // ← flip this
});
```

Nothing above that provider changes — not the repository, not the use case, not a
single widget.

The Android landing sites, with the exact steps each needs, are documented in:

- `features/app_manager/data/datasources/usage_stats_android_source.dart`
- `features/settings/data/datasources/permission_android_source.dart`

---

## Screens

### Beranda
1. Today's video count with a delta versus yesterday.
2. Social-app opens — Harian / Mingguan / Bulanan segmented.
3. ARIA's message + **"Ngobrol"** follow-up (opens the companion sheet via
   `AriaSheet.show`).
4. Today's wins, framed as choices made, not scores.
5. Seven-day screen-time trend with the daily target as reference.
6. Top-3 apps by screen time, busiest first.

Every block owns its own `FutureProvider`, so one failure never blanks the page.

### Kelola Aplikasi
Daily usage limit per app: progress ring against quota, quick presets,
enforcement mode, enable/disable. Limits persist to SharedPreferences.

### Pengaturan
Permissions with per-permission rationale and the right action (two of them can
only be granted in system Settings, so the row says "Buka pengaturan"), theme
mode (persisted), ARIA's tone, daily target, quiet hours, haptics, app-name
masking, and data deletion.

---

## Verified

```bash
flutter analyze          # 0 issues in lib/ (only an SDK plugin-deprecation note)
dart run custom_lint     # 0 issues
flutter test             # 32 tests pass
flutter build linux      # builds and runs
```

Tests cover the interaction principles (haptic level, press scale, sheet
resolution), the repository error boundary, mock-data mapping, and full
navigation across all three tabs including committing a limit.

---

## Roadmap (designed for, not yet built)

**App Manager** — schedules/focus windows, grace periods, category-level limits,
pause-a-day without breaking streaks, streak points, trigger-pattern detection,
presets (Kerja Fokus / Akhir Pekan / Ujian), emergency whitelist, weekly report
into the ARIA conversation.

**Settings** — local data export/erase, quiet hours, ARIA tone, nickname and
daily prayer time, app-name masking, recalibration, local backup/restore, about +
diagnostics, accessibility (text scale, reduce motion, high contrast), OS home
widget.

The entity shapes already hold room for most of these — `AppLimit.activeWeekdays`,
`AppLimit.activeFrom/Until`, `LimitEnforcement`, and `UsageSession` exist so the
features land without restructuring.
# aria
