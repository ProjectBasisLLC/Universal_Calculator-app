import 'package:flutter/material.dart';
import '../models/time_value.dart';
import '../widgets/time_row.dart';
import '../widgets/numpad.dart';

class AddSubtractScreen extends StatefulWidget {
  const AddSubtractScreen({super.key});
  @override
  State<AddSubtractScreen> createState() => _AddSubtractScreenState();
}

class _AddSubtractScreenState extends State<AddSubtractScreen> {
  int _d1 = 0, _h1 = 0, _m1 = 0, _s1 = 0;
  int _d2 = 0, _h2 = 0, _m2 = 0, _s2 = 0;
  String _op = '+';
  int _activeRow = 1;
  String _activeField = 'h';
  String _currentInput = '0';
  TimeValue? _result;

  int _get(int row, String f) {
    if (row == 1) {
      return switch (f) { 'd' => _d1, 'h' => _h1, 'm' => _m1, _ => _s1 };
    }
    return switch (f) { 'd' => _d2, 'h' => _h2, 'm' => _m2, _ => _s2 };
  }

  void _set(int row, String f, int v) {
    if (row == 1) {
      switch (f) {
        case 'd': _d1 = v;
        case 'h': _h1 = v;
        case 'm': _m1 = v;
        case 's': _s1 = v;
      }
    } else {
      switch (f) {
        case 'd': _d2 = v;
        case 'h': _h2 = v;
        case 'm': _m2 = v;
        case 's': _s2 = v;
      }
    }
  }

  void _activateField(int row, String field) {
    setState(() {
      _activeRow = row;
      _activeField = field;
      _currentInput = _get(row, field).toString();
      _result = null;
    });
  }

  void _onDigit(String d) {
    setState(() {
      if (_currentInput == '0') {
        _currentInput = d;
      } else if (_currentInput.length < 5) {
        _currentInput += d;
      }
      _set(_activeRow, _activeField, int.tryParse(_currentInput) ?? 0);
      _result = null;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_currentInput.length <= 1) {
        _currentInput = '0';
      } else {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      }
      _set(_activeRow, _activeField, int.tryParse(_currentInput) ?? 0);
      _result = null;
    });
  }

  void _onClear() {
    setState(() {
      _d1 = _h1 = _m1 = _s1 = 0;
      _d2 = _h2 = _m2 = _s2 = 0;
      _activeRow = 1;
      _activeField = 'h';
      _currentInput = '0';
      _result = null;
    });
  }

  void _onEquals() {
    final v1 = TimeValue.fromParts(_d1, _h1, _m1, _s1);
    final v2 = TimeValue.fromParts(_d2, _h2, _m2, _s2);
    setState(() => _result = _op == '+' ? v1 + v2 : v1 - v2);
  }

  void _selectOp(String op) {
    setState(() {
      _op = op;
      _activeRow = 2;
      _currentInput = _get(2, _activeField).toString();
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
                _sectionLabel(context, 'First time', isActive: _activeRow == 1),
                TimeRow(
                  days: _d1, hours: _h1, mins: _m1, secs: _s1,
                  activeField: _activeRow == 1 ? _activeField : null,
                  onFieldTap: (f) => _activateField(1, f),
                ),

                // Operator selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text('Operation:', style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                      const SizedBox(width: 12),
                      _OpBtn(label: '+', selected: _op == '+', onTap: () => _selectOp('+')),
                      const SizedBox(width: 8),
                      _OpBtn(label: '−', selected: _op == '-', onTap: () => _selectOp('-')),
                    ],
                  ),
                ),

                _sectionLabel(context, 'Second time', isActive: _activeRow == 2),
                TimeRow(
                  days: _d2, hours: _h2, mins: _m2, secs: _s2,
                  activeField: _activeRow == 2 ? _activeField : null,
                  onFieldTap: (f) => _activateField(2, f),
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
                  if (_result!.isNegative)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Negative result — end time is before start time',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
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
          activeUnit: _activeField,
          onUnit: (u) => _activateField(_activeRow, u),
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
