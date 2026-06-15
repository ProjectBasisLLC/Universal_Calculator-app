import 'package:flutter/material.dart';
import '../models/time_value.dart';
import '../widgets/time_row.dart';
import '../widgets/numpad.dart';

class MultiplyDivideScreen extends StatefulWidget {
  const MultiplyDivideScreen({super.key});
  @override
  State<MultiplyDivideScreen> createState() => _MultiplyDivideScreenState();
}

class _MultiplyDivideScreenState extends State<MultiplyDivideScreen> {
  int _d = 0, _h = 0, _m = 0, _s = 0;
  String _op = '×';
  String _scalar = '1';
  bool _editingTime = true;
  String _activeField = 'h';
  String _currentInput = '0';
  TimeValue? _result;
  bool _divByZero = false;

  int _getField(String f) => switch (f) { 'd' => _d, 'h' => _h, 'm' => _m, _ => _s };

  void _setField(String f, int v) {
    switch (f) {
      case 'd': _d = v;
      case 'h': _h = v;
      case 'm': _m = v;
      case 's': _s = v;
    }
  }

  void _onDigit(String d) {
    setState(() {
      if (_editingTime) {
        if (_currentInput == '0') {
          _currentInput = d;
        } else if (_currentInput.length < 5) {
          _currentInput += d;
        }
        _setField(_activeField, int.tryParse(_currentInput) ?? 0);
      } else {
        if (_scalar == '0' && d != '.') {
          _scalar = d;
        } else if (!(_scalar.contains('.') && d == '.') && _scalar.length < 10) {
          _scalar += d;
        }
      }
      _result = null;
      _divByZero = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_editingTime) {
        if (_currentInput.length <= 1) {
          _currentInput = '0';
        } else {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        }
        _setField(_activeField, int.tryParse(_currentInput) ?? 0);
      } else {
        if (_scalar.length <= 1) {
          _scalar = '0';
        } else {
          _scalar = _scalar.substring(0, _scalar.length - 1);
        }
      }
      _result = null;
      _divByZero = false;
    });
  }

  void _onClear() {
    setState(() {
      _d = _h = _m = _s = 0;
      _scalar = '1';
      _editingTime = true;
      _activeField = 'h';
      _currentInput = '0';
      _result = null;
      _divByZero = false;
    });
  }

  void _onEquals() {
    final scalar = double.tryParse(_scalar) ?? 1;
    if (scalar == 0 && _op == '÷') {
      setState(() => _divByZero = true);
      return;
    }
    final tv = TimeValue.fromParts(_d, _h, _m, _s);
    setState(() {
      _result = _op == '×' ? tv.scale(scalar) : tv.scale(1 / scalar);
      _divByZero = false;
    });
  }

  void _activateTimeField(String f) {
    setState(() {
      _editingTime = true;
      _activeField = f;
      _currentInput = _getField(f).toString();
      _result = null;
    });
  }

  void _selectOp(String op) {
    setState(() {
      _op = op;
      _editingTime = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(context, 'Time value', isActive: _editingTime),
                TimeRow(
                  days: _d, hours: _h, mins: _m, secs: _s,
                  activeField: _editingTime ? _activeField : null,
                  onFieldTap: _activateTimeField,
                ),

                // Operator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text('Operation:', style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                      const SizedBox(width: 12),
                      _OpBtn(label: '×', selected: _op == '×', onTap: () => _selectOp('×')),
                      const SizedBox(width: 8),
                      _OpBtn(label: '÷', selected: _op == '÷', onTap: () => _selectOp('÷')),
                    ],
                  ),
                ),

                // Scalar input
                _sectionLabel(context, 'Number', isActive: !_editingTime),
                GestureDetector(
                  onTap: () => setState(() {
                    _editingTime = false;
                    _result = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: !_editingTime
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _scalar,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: !_editingTime
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!_editingTime)
                          Icon(Icons.edit, size: 18,
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6)),
                      ],
                    ),
                  ),
                ),

                if (_divByZero)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Cannot divide by zero',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),

                if (_result != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(),
                  ),
                  _sectionLabel(context, 'Result'),
                  TimeRow(
                    days: _result!.days,
                    hours: _result!.hours,
                    mins: _result!.mins,
                    secs: _result!.secs,
                    isResult: true,
                  ),
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
          onEquals: _onEquals,
          showDecimal: !_editingTime,
          activeUnit: _editingTime ? _activeField : null,
          onUnit: _editingTime ? _activateTimeField : null,
        ),
      ],
    );
  }
}

Widget _sectionLabel(BuildContext context, String text, {bool isActive = false}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 16, 2),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
      ),
    ),
  );
}

class _OpBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OpBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
