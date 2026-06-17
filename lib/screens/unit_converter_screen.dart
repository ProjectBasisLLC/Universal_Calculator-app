import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/unit_category.dart';
import '../widgets/numpad.dart';

class UnitConverterScreen extends StatefulWidget {
  final UnitCategory category;
  const UnitConverterScreen({super.key, required this.category});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  late String _fromId;
  String _input = '0';
  bool _negative = false;

  @override
  void initState() {
    super.initState();
    _fromId = widget.category.units.first.id;
  }

  double? get _value {
    final v = double.tryParse(_input);
    if (v == null) return null;
    return _negative ? -v : v;
  }

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

  void _onClear() => setState(() {
    _input = '0';
    _negative = false;
  });

  void _onPlusMinus() => setState(() => _negative = !_negative);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = widget.category;
    final value = _value;
    final others = cat.units.where((u) => u.id != _fromId).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
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
              itemCount: cat.units.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final u = cat.units[i];
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
              onLongPress: () {
                final text = '${_negative ? '-' : ''}$_input';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_negative ? '−' : ''}$_input',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: value != null
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: others.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final u = others[i];
                      final result = cat.convert(value, _fromId, u.id);
                      return _ResultRow(symbol: u.symbol, label: u.label, value: _fmt(result));
                    },
                  )
                : const SizedBox.shrink(),
          ),

          Numpad(
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onClear: _onClear,
            showDecimal: true,
            onPlusMinus: cat.isTemperature ? _onPlusMinus : null,
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

  const _ResultRow({required this.symbol, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $value $symbol'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
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
