---
name: r4t-io-app
description: >-
  Reference for the R4T.io Flutter app (formerly "Universal Calculator" / "Time Calculator";
  package name time_calculator) — a three-tab app combining time math, a standard calculator,
  and a 20-category unit converter. Use this skill whenever working on this app's codebase,
  including adding or editing converter categories, time tools, or calculator features;
  navigating lib/screens or lib/models; explaining how conversions (linear, temperature, fuel
  economy, battery) work; or answering any question about this app's structure, tabs, screens,
  or extension points. Trigger on mentions of "R4T.io," "Universal Calculator," "Time
  Calculator" (its original name), time_calculator package, or any file path under
  lib/screens/ or lib/models/unit_category.dart.
---

# R4T.io — App Reference

A Flutter app (marketed as **R4T.io**, formerly "Universal Calculator" / "Time Calculator";
package `time_calculator`, root widget `UniversalCalculatorApp`) with three tabs: Time,
Calculate, Convert. Targets Android, iOS, web, Windows, macOS, Linux.

> Naming note: the pubspec package name (`time_calculator`) and root widget
> (`UniversalCalculatorApp`) haven't been renamed to match the new brand yet — flag this if
> you're doing a full rebrand pass through the code, since the app-store listing name and
> in-code identifiers are currently out of sync.

Use this skill to orient quickly in the codebase before making changes, and to follow the
app's existing conventions when adding features rather than inventing new patterns.

## Navigation shell

Bottom nav (Material 3 `NavigationBar`), defined in `lib/screens/app_shell.dart`:

| Tab | Screen | Purpose |
|---|---|---|
| Time | `HomeScreen` | Time arithmetic, conversion, difference, age |
| Calculate | `CalculatorScreen` | Standard arithmetic calculator |
| Convert | `UnitConverterHome` | Unit converter category grid |

## Time tab

`lib/screens/home_screen.dart` — 5-mode tab bar:

1. Add / Subtract — `add_subtract_screen.dart`
2. Multiply / Divide — `multiply_divide_screen.dart`
3. Convert — `convert_screen.dart` (time units: d/h/m/s)
4. Time Diff — `time_diff_screen.dart`
5. Age Calc — `age_calculator_screen.dart` (date picker → age in y/m/d + total days, next
   birthday countdown)

Time math is backed by `lib/models/time_value.dart` (`TimeValue`, stores total seconds).

## Calculate tab

`lib/screens/calculator_screen.dart` — standard arithmetic (+ − × ÷ %), chained operations,
active-operator highlight, long-press-to-copy on the display.

## Convert tab

`lib/screens/unit_converter_home.dart` — 3-column category grid, dynamic from `kCategories`
in `lib/models/unit_category.dart`. Tapping a category opens either the generic
`UnitConverterScreen` (parametric: scrollable from-unit chips, live results for every other
unit, long-press-to-copy) or a dedicated screen for categories that don't fit that model (Tip,
Battery).

### Converter categories (20)

Length, Area, Temperature, Volume, Mass, Data, Speed, Time, Tip, Pressure, Energy, Power,
Voltage, Current, Resistance, Battery, Fuel Economy, Angle, Space, Atomic.

Most are linear (simple ratio to a base unit). Three are special:

- **Temperature** — non-linear, `isTemperature` flag routes to `_convertTemp` (handles C/F/K
  non-zero offsets).
- **Fuel Economy** — non-linear, `isFuelEconomy` flag routes to `_convertFuel` (handles
  L/100km's inverse relationship).
- **Battery** — needs an extra input (voltage), so it doesn't fit the two-unit `convert`
  signature at all. See below.

### Battery capacity conversion (mAh ↔ Wh)

mAh/Ah/C are **charge** units; Wh/kWh/J are **energy** units — not interchangeable by a fixed
ratio. Converting requires a voltage: `energy (J) = charge (C) × voltage (V)`.

So Battery has `units: []` in `kCategories` and is routed to its own
`lib/screens/battery_screen.dart` instead of the generic `UnitConverterScreen`. That screen
adds a voltage field (default 3.7 V, quick-select chips for 1.2 V NiMH, 1.5 V alkaline,
3.6/3.7 V Li-ion, 5 V USB, 12 V lead-acid) alongside the value input and unit chips.
Same-domain conversions (mAh ↔ Ah) stay linear; cross-domain conversions (mAh ↔ Wh) go
through the voltage. Logic lives in `lib/models/unit_category.dart`: `BatteryUnitDef`,
`kBatteryUnits`, `convertBattery(value, fromId, toId, voltage)`.
Example: 2000 mAh at 3.7 V ⇄ 7.4 Wh.

### Space & Atomic

Ordinary linear `UnitCategory` entries (base unit = meters), no special screen — just a much
wider dynamic range than Length. `_fmt` already switches to scientific notation outside
~1e-5–1e12, so both tiny atomic and huge astronomical values display sensibly.

- **Space**: km, light-seconds, light-minutes, AU, light-hours, light-years, parsecs,
  kiloparsecs, megaparsecs. 1 AU = 1.495978707e11 m; 1 ly = 9.4607304725808e15 m;
  1 pc ≈ 3.0856775815e16 m.
- **Atomic**: attometers, femtometers, picometers, Bohr radii, angstroms, nanometers. Bohr
  radius (a₀) = 5.29177210903e-11 m.

## Shared conversion model

`lib/models/unit_category.dart`:

- `UnitDef` — id, label, symbol, `toBase` (ratio to the category's base unit)
- `UnitCategory` — id, label, icon, `units`, plus `isTemperature` / `isFuelEconomy` flags
- `UnitCategory.convert(value, fromId, toId)`:
  - linear: `value * from.toBase / to.toBase`
  - `isTemperature` → `_convertTemp`
  - `isFuelEconomy` → `_convertFuel`
  - categories needing an extra input (Battery) don't use this signature — empty `units: []`
    plus a dedicated screen instead

## Shared UI polish

- Long-press-to-copy on: calculator display, converter input, every converter result row, tip
  result rows, battery input/results — each shows a SnackBar confirmation.
- `lib/widgets/numpad.dart` — shared `Numpad` widget (digits, backspace, clear, optional
  ±/unit-selector rows).

## Extending the app

Follow these existing patterns rather than introducing new ones:

- **New converter category (linear)**: add a `UnitCategory` to `kCategories`.
- **New converter category (non-linear, two units only)**: add a flag + static method to
  `UnitCategory.convert`, following `_convertTemp` / `_convertFuel`.
- **New converter category (needs an extra input, like voltage)**: give it `units: []` and a
  dedicated screen routed from `unit_converter_home.dart`, following `TipScreen` /
  `BatteryScreen`.
- **New time tool**: add a `_Mode` entry + screen in `home_screen.dart`.
- **New math tool**: extend or add a tab alongside `CalculatorScreen` under the Calculate tab.

When asked to add a feature, identify which of these five patterns it fits before writing
code, and match the existing style (long-press-to-copy, SnackBar confirmations, chip-based
unit selection) unless told otherwise.
