import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback? onEquals;
  final bool showDecimal;
  final String? activeUnit;
  final void Function(String)? onUnit;

  const Numpad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    this.onEquals,
    this.showDecimal = false,
    this.activeUnit,
    this.onUnit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget num(String n) => _Btn(
          label: n,
          onTap: () => onDigit(n),
          bg: theme.colorScheme.surfaceContainerHighest,
          fg: theme.colorScheme.onSurface,
          fontSize: 22,
        );

    Widget empty() => const Expanded(child: SizedBox());

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // D / H / M / S unit selector row
          if (onUnit != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: ['d', 'h', 'm', 's'].map((u) {
                  final isActive = activeUnit == u;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Btn(
                        label: u.toUpperCase(),
                        onTap: () => onUnit!(u),
                        bg: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondaryContainer,
                        fg: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSecondaryContainer,
                        height: 40,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          Row(children: [
            num('7'), num('8'), num('9'),
            _Btn(
              label: 'AC',
              onTap: onClear,
              bg: theme.colorScheme.errorContainer,
              fg: theme.colorScheme.onErrorContainer,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ]),
          Row(children: [
            num('4'), num('5'), num('6'),
            _Btn(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              bg: theme.colorScheme.secondaryContainer,
              fg: theme.colorScheme.onSecondaryContainer,
            ),
          ]),
          Row(children: [
            num('1'), num('2'), num('3'),
            onEquals != null
                ? _Btn(
                    label: '=',
                    onTap: onEquals!,
                    bg: theme.colorScheme.primary,
                    fg: theme.colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  )
                : empty(),
          ]),
          Row(children: [
            showDecimal
                ? _Btn(
                    label: '.',
                    onTap: () => onDigit('.'),
                    bg: theme.colorScheme.surfaceContainerHighest,
                    fg: theme.colorScheme.onSurface,
                    fontSize: 22,
                  )
                : empty(),
            num('0'),
            empty(),
            empty(),
          ]),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;

  const _Btn({
    required this.onTap,
    required this.bg,
    required this.fg,
    this.label,
    this.icon,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              height: height,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: fg, size: 22)
                    : Text(
                        label!,
                        style: TextStyle(
                          color: fg,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
