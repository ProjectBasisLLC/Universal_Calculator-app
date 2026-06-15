import 'package:flutter/material.dart';
import 'add_subtract_screen.dart';
import 'multiply_divide_screen.dart';
import 'convert_screen.dart';
import 'time_diff_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _mode = 0;

  static const _modes = [
    _Mode(symbol: '+ / −', title: 'Add / Subtract', icon: Icons.add_circle_outline),
    _Mode(symbol: '× / ÷', title: 'Multiply / Divide', icon: Icons.close),
    _Mode(symbol: '↔', title: 'Convert', icon: Icons.swap_horiz_rounded),
    _Mode(symbol: 'Δt', title: 'Time Difference', icon: Icons.date_range_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Time Calculator',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mode selector
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: List.generate(_modes.length, (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ModeTab(
                    mode: _modes[i],
                    isSelected: _mode == i,
                    onTap: () => setState(() => _mode = i),
                  ),
                ),
              )),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),

          // Screen content
          Expanded(
            child: IndexedStack(
              index: _mode,
              children: const [
                AddSubtractScreen(),
                MultiplyDivideScreen(),
                ConvertScreen(),
                TimeDiffScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mode {
  final String symbol;
  final String title;
  final IconData icon;
  const _Mode({required this.symbol, required this.title, required this.icon});
}

class _ModeTab extends StatelessWidget {
  final _Mode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({required this.mode, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mode.symbol,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              mode.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                height: 1.2,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
