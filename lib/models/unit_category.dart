import 'package:flutter/material.dart';

class UnitDef {
  final String id;
  final String label;
  final String symbol;
  final double toBase;
  const UnitDef({required this.id, required this.label, required this.symbol, required this.toBase});
}

class UnitCategory {
  final String id;
  final String label;
  final IconData icon;
  final List<UnitDef> units;
  final bool isTemperature;
  final bool isFuelEconomy;

  const UnitCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.units,
    this.isTemperature = false,
    this.isFuelEconomy = false,
  });

  double convert(double value, String fromId, String toId) {
    if (isTemperature) return _convertTemp(value, fromId, toId);
    if (isFuelEconomy) return _convertFuel(value, fromId, toId);
    final from = units.firstWhere((u) => u.id == fromId, orElse: () => units.first);
    final to = units.firstWhere((u) => u.id == toId, orElse: () => units.first);
    return value * from.toBase / to.toBase;
  }

  static double _convertTemp(double value, String from, String to) {
    if (from == to) return value;
    final c = switch (from) {
      'f' => (value - 32) * 5 / 9,
      'k' => value - 273.15,
      _ => value,
    };
    return switch (to) {
      'f' => c * 9 / 5 + 32,
      'k' => c + 273.15,
      _ => c,
    };
  }

  // Base unit: km/L. L/100km uses inverse relationship.
  static double _convertFuel(double value, String from, String to) {
    if (from == to) return value;
    final kmL = switch (from) {
      'l100km' => value == 0 ? 0.0 : 100 / value,
      'mpg_us'  => value * 0.425144,
      'mpg_uk'  => value * 0.354006,
      _         => value, // kml
    };
    return switch (to) {
      'l100km' => kmL == 0 ? 0.0 : 100 / kmL,
      'mpg_us'  => kmL / 0.425144,
      'mpg_uk'  => kmL / 0.354006,
      _         => kmL,
    };
  }
}

/// Battery capacity conversion (mAh/Ah/C are *charge*, Wh/kWh/J are *energy*).
/// Crossing domains requires a voltage: energy(J) = charge(C) * voltage(V).
/// This can't be expressed as a fixed toBase ratio like the other categories,
/// so it's handled separately (see BatteryScreen) instead of via UnitCategory.convert.
enum BatteryDomain { charge, energy }

class BatteryUnitDef {
  final String id;
  final String label;
  final String symbol;
  final BatteryDomain domain;
  final double toBase; // charge -> Coulombs, energy -> Joules
  const BatteryUnitDef({
    required this.id,
    required this.label,
    required this.symbol,
    required this.domain,
    required this.toBase,
  });
}

const kBatteryUnits = <BatteryUnitDef>[
  BatteryUnitDef(id: 'mah', label: 'Milliamp-hours', symbol: 'mAh', domain: BatteryDomain.charge, toBase: 3.6),
  BatteryUnitDef(id: 'ah',  label: 'Amp-hours',       symbol: 'Ah',  domain: BatteryDomain.charge, toBase: 3600),
  BatteryUnitDef(id: 'c',   label: 'Coulombs',        symbol: 'C',   domain: BatteryDomain.charge, toBase: 1),
  BatteryUnitDef(id: 'wh',  label: 'Watt-hours',      symbol: 'Wh',  domain: BatteryDomain.energy, toBase: 3600),
  BatteryUnitDef(id: 'kwh', label: 'Kilowatt-hours',  symbol: 'kWh', domain: BatteryDomain.energy, toBase: 3600000),
  BatteryUnitDef(id: 'j',   label: 'Joules',          symbol: 'J',   domain: BatteryDomain.energy, toBase: 1),
];

double convertBattery(double value, String fromId, String toId, double voltage) {
  final from = kBatteryUnits.firstWhere((u) => u.id == fromId, orElse: () => kBatteryUnits.first);
  final to = kBatteryUnits.firstWhere((u) => u.id == toId, orElse: () => kBatteryUnits.first);
  if (from.domain == to.domain) {
    return value * from.toBase / to.toBase;
  }
  if (from.domain == BatteryDomain.charge) {
    final coulombs = value * from.toBase;
    final joules = coulombs * voltage;
    return joules / to.toBase;
  } else {
    final joules = value * from.toBase;
    final coulombs = voltage == 0 ? 0.0 : joules / voltage;
    return coulombs / to.toBase;
  }
}

const kCategories = <UnitCategory>[
  UnitCategory(
    id: 'length',
    label: 'Length',
    icon: Icons.straighten,
    units: [
      UnitDef(id: 'mm', label: 'Millimeters', symbol: 'mm', toBase: 0.001),
      UnitDef(id: 'cm', label: 'Centimeters', symbol: 'cm', toBase: 0.01),
      UnitDef(id: 'm', label: 'Meters', symbol: 'm', toBase: 1),
      UnitDef(id: 'km', label: 'Kilometers', symbol: 'km', toBase: 1000),
      UnitDef(id: 'in', label: 'Inches', symbol: 'in', toBase: 0.0254),
      UnitDef(id: 'ft', label: 'Feet', symbol: 'ft', toBase: 0.3048),
      UnitDef(id: 'yd', label: 'Yards', symbol: 'yd', toBase: 0.9144),
      UnitDef(id: 'mi', label: 'Miles', symbol: 'mi', toBase: 1609.344),
      UnitDef(id: 'nmi', label: 'Nautical Mi', symbol: 'nmi', toBase: 1852),
    ],
  ),
  UnitCategory(
    id: 'area',
    label: 'Area',
    icon: Icons.aspect_ratio,
    units: [
      UnitDef(id: 'mm2', label: 'Sq Millimeters', symbol: 'mm²', toBase: 1e-6),
      UnitDef(id: 'cm2', label: 'Sq Centimeters', symbol: 'cm²', toBase: 1e-4),
      UnitDef(id: 'm2', label: 'Sq Meters', symbol: 'm²', toBase: 1),
      UnitDef(id: 'km2', label: 'Sq Kilometers', symbol: 'km²', toBase: 1e6),
      UnitDef(id: 'in2', label: 'Sq Inches', symbol: 'in²', toBase: 6.4516e-4),
      UnitDef(id: 'ft2', label: 'Sq Feet', symbol: 'ft²', toBase: 0.09290304),
      UnitDef(id: 'yd2', label: 'Sq Yards', symbol: 'yd²', toBase: 0.83612736),
      UnitDef(id: 'ac', label: 'Acres', symbol: 'ac', toBase: 4046.856),
      UnitDef(id: 'ha', label: 'Hectares', symbol: 'ha', toBase: 10000),
      UnitDef(id: 'mi2', label: 'Sq Miles', symbol: 'mi²', toBase: 2589988.11),
    ],
  ),
  UnitCategory(
    id: 'temp',
    label: 'Temperature',
    icon: Icons.thermostat,
    isTemperature: true,
    units: [
      UnitDef(id: 'c', label: 'Celsius', symbol: '°C', toBase: 1),
      UnitDef(id: 'f', label: 'Fahrenheit', symbol: '°F', toBase: 1),
      UnitDef(id: 'k', label: 'Kelvin', symbol: 'K', toBase: 1),
    ],
  ),
  UnitCategory(
    id: 'volume',
    label: 'Volume',
    icon: Icons.water_drop,
    units: [
      UnitDef(id: 'ml', label: 'Milliliters', symbol: 'mL', toBase: 0.001),
      UnitDef(id: 'l', label: 'Liters', symbol: 'L', toBase: 1),
      UnitDef(id: 'tsp', label: 'Teaspoons', symbol: 'tsp', toBase: 0.00492892),
      UnitDef(id: 'tbsp', label: 'Tablespoons', symbol: 'tbsp', toBase: 0.0147868),
      UnitDef(id: 'floz', label: 'Fl Ounces', symbol: 'fl oz', toBase: 0.0295735),
      UnitDef(id: 'cup', label: 'Cups', symbol: 'cup', toBase: 0.236588),
      UnitDef(id: 'pt', label: 'Pints', symbol: 'pt', toBase: 0.473176),
      UnitDef(id: 'qt', label: 'Quarts', symbol: 'qt', toBase: 0.946353),
      UnitDef(id: 'gal', label: 'Gallons', symbol: 'gal', toBase: 3.78541),
      UnitDef(id: 'm3', label: 'Cubic Meters', symbol: 'm³', toBase: 1000),
    ],
  ),
  UnitCategory(
    id: 'mass',
    label: 'Mass',
    icon: Icons.fitness_center,
    units: [
      UnitDef(id: 'mg', label: 'Milligrams', symbol: 'mg', toBase: 0.001),
      UnitDef(id: 'g', label: 'Grams', symbol: 'g', toBase: 1),
      UnitDef(id: 'kg', label: 'Kilograms', symbol: 'kg', toBase: 1000),
      UnitDef(id: 'mt', label: 'Metric Tons', symbol: 't', toBase: 1e6),
      UnitDef(id: 'oz', label: 'Ounces', symbol: 'oz', toBase: 28.3495),
      UnitDef(id: 'lb', label: 'Pounds', symbol: 'lb', toBase: 453.592),
      UnitDef(id: 'st', label: 'Stone', symbol: 'st', toBase: 6350.29),
      UnitDef(id: 'ton', label: 'Short Tons', symbol: 'ton', toBase: 907185),
    ],
  ),
  UnitCategory(
    id: 'data',
    label: 'Data',
    icon: Icons.storage,
    units: [
      UnitDef(id: 'bit', label: 'Bits', symbol: 'bit', toBase: 0.125),
      UnitDef(id: 'b', label: 'Bytes', symbol: 'B', toBase: 1),
      UnitDef(id: 'kb', label: 'Kilobytes', symbol: 'KB', toBase: 1024),
      UnitDef(id: 'mb', label: 'Megabytes', symbol: 'MB', toBase: 1048576),
      UnitDef(id: 'gb', label: 'Gigabytes', symbol: 'GB', toBase: 1073741824),
      UnitDef(id: 'tb', label: 'Terabytes', symbol: 'TB', toBase: 1099511627776),
      UnitDef(id: 'pb', label: 'Petabytes', symbol: 'PB', toBase: 1.12589990684e15),
    ],
  ),
  UnitCategory(
    id: 'speed',
    label: 'Speed',
    icon: Icons.speed,
    units: [
      UnitDef(id: 'mps', label: 'Meters/sec', symbol: 'm/s', toBase: 1),
      UnitDef(id: 'kmh', label: 'Km/hour', symbol: 'km/h', toBase: 0.277778),
      UnitDef(id: 'mph', label: 'Miles/hour', symbol: 'mph', toBase: 0.44704),
      UnitDef(id: 'kn', label: 'Knots', symbol: 'kn', toBase: 0.514444),
      UnitDef(id: 'fps', label: 'Feet/sec', symbol: 'ft/s', toBase: 0.3048),
    ],
  ),
  UnitCategory(
    id: 'time',
    label: 'Time',
    icon: Icons.schedule,
    units: [
      UnitDef(id: 'ms', label: 'Milliseconds', symbol: 'ms', toBase: 0.001),
      UnitDef(id: 's', label: 'Seconds', symbol: 's', toBase: 1),
      UnitDef(id: 'min', label: 'Minutes', symbol: 'min', toBase: 60),
      UnitDef(id: 'h', label: 'Hours', symbol: 'h', toBase: 3600),
      UnitDef(id: 'd', label: 'Days', symbol: 'd', toBase: 86400),
      UnitDef(id: 'wk', label: 'Weeks', symbol: 'wk', toBase: 604800),
      UnitDef(id: 'mo', label: 'Months', symbol: 'mo', toBase: 2629800),
      UnitDef(id: 'yr', label: 'Years', symbol: 'yr', toBase: 31557600),
    ],
  ),
  UnitCategory(
    id: 'tip',
    label: 'Tip',
    icon: Icons.receipt_outlined,
    units: [],
  ),
  UnitCategory(
    id: 'pressure',
    label: 'Pressure',
    icon: Icons.compress,
    units: [
      UnitDef(id: 'pa',   label: 'Pascals',      symbol: 'Pa',   toBase: 1),
      UnitDef(id: 'hpa',  label: 'Hectopascals', symbol: 'hPa',  toBase: 100),
      UnitDef(id: 'kpa',  label: 'Kilopascals',  symbol: 'kPa',  toBase: 1000),
      UnitDef(id: 'mpa',  label: 'Megapascals',  symbol: 'MPa',  toBase: 1e6),
      UnitDef(id: 'bar',  label: 'Bar',          symbol: 'bar',  toBase: 100000),
      UnitDef(id: 'mbar', label: 'Millibar',     symbol: 'mbar', toBase: 100),
      UnitDef(id: 'psi',  label: 'PSI',          symbol: 'psi',  toBase: 6894.76),
      UnitDef(id: 'atm',  label: 'Atmospheres',  symbol: 'atm',  toBase: 101325),
      UnitDef(id: 'mmhg', label: 'mmHg (Torr)',  symbol: 'mmHg', toBase: 133.322),
      UnitDef(id: 'inhg', label: 'inHg',         symbol: 'inHg', toBase: 3386.39),
    ],
  ),
  UnitCategory(
    id: 'energy',
    label: 'Energy',
    icon: Icons.electric_bolt,
    units: [
      UnitDef(id: 'j',    label: 'Joules',       symbol: 'J',    toBase: 1),
      UnitDef(id: 'kj',   label: 'Kilojoules',   symbol: 'kJ',   toBase: 1000),
      UnitDef(id: 'mj',   label: 'Megajoules',   symbol: 'MJ',   toBase: 1e6),
      UnitDef(id: 'cal',  label: 'Calories',     symbol: 'cal',  toBase: 4.184),
      UnitDef(id: 'kcal', label: 'Kilocalories', symbol: 'kcal', toBase: 4184),
      UnitDef(id: 'wh',   label: 'Watt-hours',   symbol: 'Wh',   toBase: 3600),
      UnitDef(id: 'kwh',  label: 'Kilowatt-hrs', symbol: 'kWh',  toBase: 3600000),
      UnitDef(id: 'btu',  label: 'BTU',          symbol: 'BTU',  toBase: 1055.06),
      UnitDef(id: 'ftlb', label: 'Foot-pounds',  symbol: 'ft·lb',toBase: 1.35582),
      UnitDef(id: 'ev',   label: 'Electronvolts',symbol: 'eV',   toBase: 1.60218e-19),
    ],
  ),
  UnitCategory(
    id: 'power',
    label: 'Power',
    icon: Icons.power,
    units: [
      UnitDef(id: 'w',    label: 'Watts',        symbol: 'W',    toBase: 1),
      UnitDef(id: 'kw',   label: 'Kilowatts',    symbol: 'kW',   toBase: 1000),
      UnitDef(id: 'mw',   label: 'Megawatts',    symbol: 'MW',   toBase: 1e6),
      UnitDef(id: 'hp',   label: 'Horsepower',   symbol: 'hp',   toBase: 745.7),
      UnitDef(id: 'btuh', label: 'BTU/hour',     symbol: 'BTU/h',toBase: 0.293071),
    ],
  ),
  UnitCategory(
    id: 'voltage',
    label: 'Voltage',
    icon: Icons.bolt,
    units: [
      UnitDef(id: 'mv', label: 'Millivolts', symbol: 'mV', toBase: 0.001),
      UnitDef(id: 'v',  label: 'Volts',      symbol: 'V',  toBase: 1),
      UnitDef(id: 'kv', label: 'Kilovolts',  symbol: 'kV', toBase: 1000),
    ],
  ),
  UnitCategory(
    id: 'current',
    label: 'Current',
    icon: Icons.electric_meter,
    units: [
      UnitDef(id: 'ua', label: 'Microamps', symbol: 'µA', toBase: 1e-6),
      UnitDef(id: 'ma', label: 'Milliamps', symbol: 'mA', toBase: 0.001),
      UnitDef(id: 'a',  label: 'Amps',      symbol: 'A',  toBase: 1),
      UnitDef(id: 'ka', label: 'Kiloamps',  symbol: 'kA', toBase: 1000),
    ],
  ),
  UnitCategory(
    id: 'resistance',
    label: 'Resistance',
    icon: Icons.electrical_services,
    units: [
      UnitDef(id: 'ohm',  label: 'Ohms',      symbol: 'Ω',  toBase: 1),
      UnitDef(id: 'kohm', label: 'Kilohms',   symbol: 'kΩ', toBase: 1000),
      UnitDef(id: 'mohm', label: 'Megohms',   symbol: 'MΩ', toBase: 1e6),
    ],
  ),
  UnitCategory(
    id: 'battery',
    label: 'Battery',
    icon: Icons.battery_charging_full,
    units: [], // handled by BatteryScreen (needs a voltage to cross charge<->energy)
  ),
  UnitCategory(
    id: 'fuel',
    label: 'Fuel Economy',
    icon: Icons.local_gas_station,
    isFuelEconomy: true,
    units: [
      UnitDef(id: 'kml',    label: 'km per Liter',  symbol: 'km/L',    toBase: 1),
      UnitDef(id: 'mpg_us', label: 'MPG (US)',       symbol: 'mpg',     toBase: 0.425144),
      UnitDef(id: 'mpg_uk', label: 'MPG (UK)',       symbol: 'mpg(UK)', toBase: 0.354006),
      UnitDef(id: 'l100km', label: 'L per 100 km',  symbol: 'L/100km', toBase: 0),
    ],
  ),
  UnitCategory(
    id: 'space',
    label: 'Space',
    icon: Icons.rocket_launch,
    units: [
      UnitDef(id: 'km',   label: 'Kilometers',       symbol: 'km',   toBase: 1000),
      UnitDef(id: 'ls',   label: 'Light-seconds',    symbol: 'ls',   toBase: 299792458),
      UnitDef(id: 'lmin', label: 'Light-minutes',    symbol: 'lmin', toBase: 1.798754748e10),
      UnitDef(id: 'au',   label: 'Astronomical Units', symbol: 'AU', toBase: 1.495978707e11),
      UnitDef(id: 'lh',   label: 'Light-hours',      symbol: 'lh',   toBase: 1.0791328488e12),
      UnitDef(id: 'ly',   label: 'Light-years',      symbol: 'ly',   toBase: 9.4607304725808e15),
      UnitDef(id: 'pc',   label: 'Parsecs',          symbol: 'pc',   toBase: 3.0856775815e16),
      UnitDef(id: 'kpc',  label: 'Kiloparsecs',      symbol: 'kpc',  toBase: 3.0856775815e19),
      UnitDef(id: 'mpc',  label: 'Megaparsecs',      symbol: 'Mpc',  toBase: 3.0856775815e22),
    ],
  ),
  UnitCategory(
    id: 'atomic',
    label: 'Atomic',
    icon: Icons.blur_circular,
    units: [
      UnitDef(id: 'am',   label: 'Attometers',  symbol: 'am', toBase: 1e-18),
      UnitDef(id: 'fm',   label: 'Femtometers', symbol: 'fm', toBase: 1e-15),
      UnitDef(id: 'pm',   label: 'Picometers',  symbol: 'pm', toBase: 1e-12),
      UnitDef(id: 'bohr', label: 'Bohr Radii',  symbol: 'a₀', toBase: 5.29177210903e-11),
      UnitDef(id: 'ang',  label: 'Angstroms',   symbol: 'Å',  toBase: 1e-10),
      UnitDef(id: 'nm',   label: 'Nanometers',  symbol: 'nm', toBase: 1e-9),
    ],
  ),
  UnitCategory(
    id: 'angle',
    label: 'Angle',
    icon: Icons.rotate_right,
    units: [
      UnitDef(id: 'deg',    label: 'Degrees',     symbol: '°',    toBase: 1),
      UnitDef(id: 'rad',    label: 'Radians',     symbol: 'rad',  toBase: 57.29578),
      UnitDef(id: 'grad',   label: 'Gradians',    symbol: 'grad', toBase: 0.9),
      UnitDef(id: 'arcmin', label: 'Arc Minutes', symbol: '\'',   toBase: 1 / 60),
      UnitDef(id: 'arcsec', label: 'Arc Seconds', symbol: '"',    toBase: 1 / 3600),
    ],
  ),
];
