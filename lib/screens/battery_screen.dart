import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/unit_category.dart';
import '../widgets/numpad.dart';

/// Battery capacity converter: mAh/Ah/C (charge) <-> Wh/kWh/J (energy).
/// Crossing between charge and energy needs a voltage (energy = charge * voltage),
/// so unlike the other converters this screen carries its own voltage input.
class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  String _fromId = 'mah';
  String _input = '0';
  String _voltage = '3.7';
  late final TextEditingController _voltageController = TextEditingController(text: _voltage);

  static const _quickVoltages = [1.2, 1.5, 3.6, 3.7, 5.0, 12.0];

  @override
  void dispose() {
    _voltageController.dispose();
    super.dispose();
  }

  void _setVoltage(String v) {
    setState(() => _voltage = v);
    _voltageController.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
  }

  double? get _value {
    final v = double.tryParse(_input);
    return v;
  }

  double get _voltageValue => double.tryParse(_voltage) ?? 0;

  void _onDigit(String d) {
    setState(() {
      if (_input == '0' && d != '.') {
        _input = d;
      } else if (!(_input.contains('.') && d == '.') && _input.length < 14) {
        _input += d;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.length <= 1) {
        _input = '0';
      } else {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _onClear() => setState(() => _input = '0');

  String _fmt(double v) {
    if (v == 0) return '0';
    final abs = v.abs();
    if (abs >= 1e12 || (abs < 1e-5 && abs > 0)) {
      return v.toStringAsExponential(4);
    }
    final int decimals;
    if (abs >= 10000) {
      decimals = 1;
    } else if (abs >= 100) {
      decimals = 2;
    } else if (abs >= 1) {
      decimals = 4;
    } else {
      decimals = 6;
    }
    String s = v.toStringAsFixed(decimals);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  void _copy(String text, {String? label}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label != null ? 'Copied $text $label' : 'Copied'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = _value;
    final others = kBatteryUnits.where((u) => u.id != _fromId).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Battery', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // From unit selector (horizontal scroll)
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: kBatteryUnits.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final u = kBatteryUnits[i];
                final selected = u.id == _fromId;
                return GestureDetector(
                  onTap: () => setState(() => _fromId = u.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      u.symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: GestureDetector(
              onLongPress: () => _copy(_input),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _input,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Voltage picker
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text('Voltage', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: _voltageController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        suffixText: 'V',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() => _voltage = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickVoltages.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final v = _quickVoltages[i];
                final selected = _voltageValue == v;
                return GestureDetector(
                  onTap: () => _setVoltage(v.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${v}V',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: value != null
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: others.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final u = others[i];
                      final result = convertBattery(value, _fromId, u.id, _voltageValue);
                      return _ResultRow(symbol: u.symbol, label: u.label, value: _fmt(result), onCopy: _copy);
                    },
                  )
                : const SizedBox.shrink(),
          ),

          Numpad(
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onClear: _onClear,
            showDecimal: true,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String symbol;
  final String label;
  final String value;
  final void Function(String text, {String? label}) onCopy;

  const _ResultRow({required this.symbol, required this.label, required this.value, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () => onCopy(value, label: symbol),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                symbol,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
