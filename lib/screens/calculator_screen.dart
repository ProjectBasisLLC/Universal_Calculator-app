import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecond = false;
  bool _justEvaluated = false;

  void _onDigit(String digit) {
    setState(() {
      if (_waitingForSecond) {
        _display = digit == '.' ? '0.' : digit;
        _waitingForSecond = false;
      } else if (_display == '0' && digit != '.') {
        _display = digit;
      } else if (digit == '.' && _display.contains('.')) {
        return;
      } else {
        if (_display.replaceAll('-', '').replaceAll('.', '').length < 12) {
          _display += digit;
        }
      }
      _justEvaluated = false;
    });
  }

  void _onOperator(String op) {
    setState(() {
      final value = double.tryParse(_display) ?? 0;
      if (_firstOperand != null && !_waitingForSecond && !_justEvaluated) {
        _display = _fmt(_calculate(_firstOperand!, _operator!, value));
      }
      _firstOperand = double.tryParse(_display);
      _operator = op;
      _waitingForSecond = true;
      _justEvaluated = false;
    });
  }

  void _onEquals() {
    if (_firstOperand == null || _operator == null || _waitingForSecond) return;
    setState(() {
      final second = double.tryParse(_display) ?? 0;
      _display = _fmt(_calculate(_firstOperand!, _operator!, second));
      _firstOperand = null;
      _operator = null;
      _justEvaluated = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _waitingForSecond = false;
      _justEvaluated = false;
    });
  }

  void _onToggleSign() {
    setState(() {
      final v = double.tryParse(_display) ?? 0;
      _display = _fmt(-v);
    });
  }

  void _onPercent() {
    setState(() {
      final v = double.tryParse(_display) ?? 0;
      _display = _fmt(v / 100);
    });
  }

  double _calculate(double a, String op, double b) => switch (op) {
        '+' => a + b,
        '−' => a - b,
        '×' => a * b,
        '÷' => b == 0 ? double.nan : a / b,
        _ => b,
      };

  String _fmt(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String s = value.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final opBg = theme.colorScheme.primary;
    final opFg = theme.colorScheme.onPrimary;
    final funcBg = theme.colorScheme.secondaryContainer;
    final funcFg = theme.colorScheme.onSecondaryContainer;
    final numBg = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerLow;
    final numFg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _display));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operator != null)
                      Text(
                        '${_fmt(_firstOperand ?? 0)} $_operator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  _row([
                    _Btn(label: (_display == '0' && _firstOperand == null) ? 'AC' : 'C', bg: funcBg, fg: funcFg, onTap: _onClear),
                    _Btn(label: '+/−', bg: funcBg, fg: funcFg, onTap: _onToggleSign),
                    _Btn(label: '%', bg: funcBg, fg: funcFg, onTap: _onPercent),
                    _Btn(label: '÷', bg: opBg, fg: opFg, active: _operator == '÷', onTap: () => _onOperator('÷')),
                  ]),
                  _row([
                    _Btn(label: '7', bg: numBg, fg: numFg, onTap: () => _onDigit('7')),
                    _Btn(label: '8', bg: numBg, fg: numFg, onTap: () => _onDigit('8')),
                    _Btn(label: '9', bg: numBg, fg: numFg, onTap: () => _onDigit('9')),
                    _Btn(label: '×', bg: opBg, fg: opFg, active: _operator == '×', onTap: () => _onOperator('×')),
                  ]),
                  _row([
                    _Btn(label: '4', bg: numBg, fg: numFg, onTap: () => _onDigit('4')),
                    _Btn(label: '5', bg: numBg, fg: numFg, onTap: () => _onDigit('5')),
                    _Btn(label: '6', bg: numBg, fg: numFg, onTap: () => _onDigit('6')),
                    _Btn(label: '−', bg: opBg, fg: opFg, active: _operator == '−', onTap: () => _onOperator('−')),
                  ]),
                  _row([
                    _Btn(label: '1', bg: numBg, fg: numFg, onTap: () => _onDigit('1')),
                    _Btn(label: '2', bg: numBg, fg: numFg, onTap: () => _onDigit('2')),
                    _Btn(label: '3', bg: numBg, fg: numFg, onTap: () => _onDigit('3')),
                    _Btn(label: '+', bg: opBg, fg: opFg, active: _operator == '+', onTap: () => _onOperator('+')),
                  ]),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _Btn(label: '0', bg: numBg, fg: numFg, onTap: () => _onDigit('0'), alignLeft: true),
                        ),
                        Expanded(child: _Btn(label: '.', bg: numBg, fg: numFg, onTap: () => _onDigit('.'))),
                        Expanded(child: _Btn(label: '=', bg: opBg, fg: opFg, onTap: _onEquals)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> btns) => Expanded(
        child: Row(children: btns.map((b) => Expanded(child: b)).toList()),
      );
}

class _Btn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool active;
  final bool alignLeft;

  const _Btn({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.active = false,
    this.alignLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBg = active ? fg : bg;
    final effectiveFg = active ? bg : fg;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Align(
            alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: alignLeft ? 28 : 0),
              child: Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: effectiveFg,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
