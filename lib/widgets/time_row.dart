import 'package:flutter/material.dart';

class TimeRow extends StatelessWidget {
  final int days;
  final int hours;
  final int mins;
  final int secs;
  final String? activeField;
  final void Function(String field)? onFieldTap;
  final bool isResult;

  const TimeRow({
    super.key,
    required this.days,
    required this.hours,
    required this.mins,
    required this.secs,
    this.activeField,
    this.onFieldTap,
    this.isResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isResult ? 2 : 0,
      color: isResult
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            _Field('d', days, activeField == 'd', isResult, onFieldTap != null ? () => onFieldTap!('d') : null),
            _Field('h', hours, activeField == 'h', isResult, onFieldTap != null ? () => onFieldTap!('h') : null),
            _Field('m', mins, activeField == 'm', isResult, onFieldTap != null ? () => onFieldTap!('m') : null),
            _Field('s', secs, activeField == 's', isResult, onFieldTap != null ? () => onFieldTap!('s') : null),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String unit;
  final int value;
  final bool isActive;
  final bool isResult;
  final VoidCallback? onTap;

  const _Field(this.unit, this.value, this.isActive, this.isResult, this.onTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color valueColor;
    final Color unitColor;
    final Color? bgColor;

    if (isActive) {
      bgColor = theme.colorScheme.primary;
      valueColor = theme.colorScheme.onPrimary;
      unitColor = theme.colorScheme.onPrimary.withValues(alpha: 0.8);
    } else if (isResult) {
      bgColor = null;
      valueColor = theme.colorScheme.onPrimaryContainer;
      unitColor = theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7);
    } else {
      bgColor = null;
      valueColor = theme.colorScheme.onSurface;
      unitColor = theme.colorScheme.onSurfaceVariant;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: bgColor != null
              ? BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                  height: 1.1,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: unitColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
