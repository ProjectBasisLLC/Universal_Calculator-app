import 'package:flutter/material.dart';
import '../models/time_value.dart';
import '../widgets/numpad.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});
  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  String _input = '0';
  String _unit = 'h';

  TimeValue? get _result {
    final val = double.tryParse(_input);
    if (val == null || val == 0) return null;
    return switch (_unit) {
      'd' => TimeValue((val * 86400).round()),
      'h' => TimeValue((val * 3600).round()),
      'm' => TimeValue((val * 60).round()),
      _ => TimeValue(val.round()),
    };
  }

  void _onDigit(String d) {
    setState(() {
      if (_input == '0' && d != '.') {
        _input = d;
      } else if (!(_input.contains('.') && d == '.') && _input.length < 12) {
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

  String _fmt(double v, int decimals) {
    final s = v.toStringAsFixed(decimals);
    return s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;

    const units = [
      ('d', 'Days'),
      ('h', 'Hours'),
      ('m', 'Minutes'),
      ('s', 'Seconds'),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter a value and select its unit to convert:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Input display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _input,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Unit chips
                Row(
                  children: units.map((u) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _UnitChip(
                        label: u.$2,
                        selected: _unit == u.$1,
                        onTap: () => setState(() => _unit = u.$1),
                      ),
                    ),
                  )).toList(),
                ),

                if (result != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Converted to:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ConvRow('Normalized', '${result.days}d  ${result.hours}h  ${result.mins}m  ${result.secs}s', highlighted: true),
                  const SizedBox(height: 6),
                  _ConvRow('Total Days', '${_fmt(result.inDays, 8)} days'),
                  const SizedBox(height: 6),
                  _ConvRow('Total Hours', '${_fmt(result.inHours, 6)} hours'),
                  const SizedBox(height: 6),
                  _ConvRow('Total Minutes', '${_fmt(result.inMinutes, 4)} minutes'),
                  const SizedBox(height: 6),
                  _ConvRow('Total Seconds', '${result.totalSeconds} seconds'),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Numpad(
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onClear: _onClear,
          showDecimal: true,
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConvRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _ConvRow(this.label, this.value, {this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlighted ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: highlighted ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
