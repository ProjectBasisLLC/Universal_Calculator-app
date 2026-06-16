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

  const UnitCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.units,
    this.isTemperature = false,
  });

  double convert(double value, String fromId, String toId) {
    if (isTemperature) return _convertTemp(value, fromId, toId);
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
];
