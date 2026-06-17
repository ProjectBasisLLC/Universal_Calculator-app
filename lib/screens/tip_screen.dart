import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/numpad.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});
  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  String _bill = '0';
  double _tipPct = 18;
  int _people = 1;

  static const _quickPcts = [10.0, 15.0, 18.0, 20.0, 25.0];

  void _onDigit(String d) {
    setState(() {
      if (_bill == '0' && d != '.') {
        _bill = d;
      } else if (!(_bill.contains('.') && d == '.') && _bill.length < 10) {
        _bill += d;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_bill.length <= 1) {
        _bill = '0';
      } else {
        _bill = _bill.substring(0, _bill.length - 1);
      }
    });
  }

  void _onClear() => setState(() {
    _bill = '0';
    _tipPct = 18;
    _people = 1;
  });

  String _money(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = double.tryParse(_bill) ?? 0;
    final tip = bill * _tipPct / 100;
    final total = bill + tip;
    final perPerson = _people > 1 ? total / _people : 0.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tip Calculator', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bill display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Amount',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$ $_bill',
                          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tip % quick select
                  Text(
                    'Tip Percentage',
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _quickPcts.map((pct) {
                      final selected = _tipPct == pct;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _tipPct = pct),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${pct.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // People stepper
                  Row(
                    children: [
                      Text(
                        'Split between',
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: _people > 1 ? () => setState(() => _people--) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_people',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _people++),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'people',
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Results
                  _TipRow(label: 'Tip (${_tipPct.toInt()}%)', value: '\$${_money(tip)}'),
                  const SizedBox(height: 8),
                  _TipRow(label: 'Total', value: '\$${_money(total)}', highlighted: true),
                  if (_people > 1) ...[
                    const SizedBox(height: 8),
                    _TipRow(label: 'Per Person', value: '\$${_money(perPerson)}'),
                  ],
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
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _TipRow({required this.label, required this.value, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $value'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlighted ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
