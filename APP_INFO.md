# R4T.io — App Info

A Flutter app (marketed as **R4T.io**, formerly "Universal Calculator" / "Time Calculator")
providing time math, a standard calculator, and a unit converter in one three-tab shell.
Targets Android, iOS, web, Windows, macOS, and Linux.

- Package name: `r4t_io_app` (pubspec)
- App/root widget: `R4TIoApp`
- Version: 1.0.0+1
- Platform application/bundle identifiers (Android `applicationId`, iOS/macOS bundle ID, Linux
  `APPLICATION_ID`) were deliberately **left as `com.projectbasis.time_calculator`** during the
  2026-08-17 rename pass — changing those changes the app's identity on every store/platform, so
  that's a separate decision from renaming the package, widget, and display names.

## Navigation

Bottom nav bar (Material 3 `NavigationBar`), three tabs, defined in `lib/screens/app_shell.dart`:

| Tab | Screen | Purpose |
|---|---|---|
| **Time** | `HomeScreen` | Time arithmetic, conversion, difference, age |
| **Calculate** | `CalculatorScreen` | Standard arithmetic calculator |
| **Convert** | `UnitConverterHome` | Unit converter category grid |

## Time tab

`lib/screens/home_screen.dart` — 5-mode tab bar:

1. **Add / Subtract** — `add_subtract_screen.dart`
2. **Multiply / Divide** — `multiply_divide_screen.dart`
3. **Convert** — `convert_screen.dart` (time units: d/h/m/s)
4. **Time Diff** — `time_diff_screen.dart`
5. **Age Calc** — `age_calculator_screen.dart` (date picker → age in y/m/d + total days, next birthday countdown)

Time math is backed by `lib/models/time_value.dart` (`TimeValue`, stores total seconds).

## Calculate tab

`lib/screens/calculator_screen.dart` — standard arithmetic (+ − × ÷ %), chained operations,
active-operator highlight, long-press-to-copy on the display.

## Convert tab

`lib/screens/unit_converter_home.dart` — 3-column category grid, dynamic from `kCategories`
in `lib/models/unit_category.dart`. Tapping a category opens either the generic
`UnitConverterScreen` (parametric: scrollable from-unit chips, live results for every other
unit, long-press-to-copy) or a dedicated screen for categories that don't fit that model
(Tip, Battery).

### Converter categories (20)

| Category | Units | Notes |
|---|---|---|
| Length | mm, cm, m, km, in, ft, yd, mi, nmi | linear |
| Area | mm², cm², m², km², in², ft², yd², ac, ha, mi² | linear |
| Temperature | °C, °F, K | non-linear (`_convertTemp`) |
| Volume | mL, L, tsp, tbsp, fl oz, cup, pt, qt, gal, m³ | linear |
| Mass | mg, g, kg, t, oz, lb, st, ton | linear |
| Data | bit, B, KB, MB, GB, TB, PB | linear, binary (1024) |
| Speed | m/s, km/h, mph, kn, ft/s | linear |
| Time | ms, s, min, h, d, wk, mo, yr | linear |
| Tip | — | dedicated `TipScreen`: bill / tip % / split-by-people |
| Pressure | Pa, hPa, kPa, MPa, bar, mbar, psi, atm, mmHg, inHg | linear |
| Energy | J, kJ, MJ, cal, kcal, Wh, kWh, BTU, ft·lb, eV | linear |
| Power | W, kW, MW, hp, BTU/h | linear |
| Voltage | mV, V, kV | linear |
| Current | µA, mA, A, kA | linear |
| Resistance | Ω, kΩ, MΩ | linear |
| **Battery** | mAh, Ah, C, Wh, kWh, J | dedicated `BatteryScreen` — see below |
| Fuel Economy | km/L, MPG (US), MPG (UK), L/100km | non-linear (`_convertFuel`, inverse relation) |
| Angle | °, rad, grad, arcmin, arcsec | linear |
| Space | km, light-seconds, light-minutes, AU, light-hours, light-years, parsecs, kiloparsecs, megaparsecs | linear (base: meters) |
| Atomic | attometers, femtometers, picometers, Bohr radii, angstroms, nanometers | linear (base: meters) |

### Battery capacity conversion (mAh ↔ Wh, added 2026-08-17)

mAh/Ah/C are units of **electric charge**; Wh/kWh/J are units of **energy**. They aren't
interchangeable by a fixed ratio — converting between them requires a voltage:

```
energy (J) = charge (C) × voltage (V)
```

So Battery is not a normal `UnitCategory` entry: it has an empty `units: []` list and is
routed to its own `BatteryScreen` (`lib/screens/battery_screen.dart`) instead of the generic
`UnitConverterScreen`. That screen adds a voltage field (default 3.7 V, with quick-select
chips for 1.2 V NiMH, 1.5 V alkaline, 3.6/3.7 V Li-ion, 5 V USB, 12 V lead-acid) alongside the
usual value input and unit chips. Same-domain conversions (e.g. mAh ↔ Ah) stay linear;
cross-domain conversions (e.g. mAh ↔ Wh) go through the voltage.

The conversion table and logic live in `lib/models/unit_category.dart`:
`BatteryUnitDef`, `kBatteryUnits`, `convertBattery(value, fromId, toId, voltage)`.

Example: 2000 mAh at 3.7 V ⇄ 7.4 Wh.

### Space & Atomic (added 2026-08-17)

Both are ordinary linear `UnitCategory` entries with base unit = meters — no special screen
needed, just a much wider dynamic range than Length (`_fmt` already switches to scientific
notation outside ~1e-5–1e12, so both the tiny atomic values and huge astronomical ones display
sensibly).

- **Space**: km, light-seconds, light-minutes, AU, light-hours, light-years, parsecs,
  kiloparsecs, megaparsecs. 1 AU = 1.495978707e11 m; 1 ly = 9.4607304725808e15 m;
  1 pc ≈ 3.0856775815e16 m.
- **Atomic**: attometers, femtometers, picometers, Bohr radii, angstroms, nanometers.
  Bohr radius (a₀) = 5.29177210903e-11 m — the natural atomic unit of length, included
  alongside the plain metric prefixes since it's how atomic radii are usually expressed.

## Shared conversion model

`lib/models/unit_category.dart`:

- `UnitDef` — id, label, symbol, `toBase` (ratio to the category's base unit)
- `UnitCategory` — id, label, icon, `units`, plus `isTemperature` / `isFuelEconomy` flags
- `UnitCategory.convert(value, fromId, toId)`:
  - linear categories: `value * from.toBase / to.toBase`
  - `isTemperature`: routes to `_convertTemp` (handles C/F/K's non-zero offsets)
  - `isFuelEconomy`: routes to `_convertFuel` (handles L/100km's inverse relationship)
  - categories needing an extra input (Battery's voltage) don't fit this signature at all —
    they get empty `units: []` and a dedicated screen instead

## Shared UI polish

- Long-press-to-copy on: calculator display, converter input, every converter result row,
  tip result rows, battery input/results — each shows a SnackBar confirmation.
- `lib/widgets/numpad.dart` — shared `Numpad` widget (digits, backspace, clear, optional
  ±/unit-selector rows).

## Extending the app

- **New converter category** (linear): add a `UnitCategory` to `kCategories`.
- **New converter category** (non-linear, two units only): add a flag + static method to
  `UnitCategory.convert`, following `_convertTemp` / `_convertFuel`.
- **New converter category** (needs an extra input, like voltage): give it `units: []` and a
  dedicated screen routed from `unit_converter_home.dart`, following `TipScreen` / `BatteryScreen`.
- **New time tool**: add a `_Mode` entry + screen in `home_screen.dart`.
- **New math tool**: extend or add a tab alongside `CalculatorScreen` under the Calculate tab.
