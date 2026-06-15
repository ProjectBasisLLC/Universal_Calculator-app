import 'package:flutter/material.dart';
import '../models/time_value.dart';

class TimeDiffScreen extends StatefulWidget {
  const TimeDiffScreen({super.key});
  @override
  State<TimeDiffScreen> createState() => _TimeDiffScreenState();
}

class _TimeDiffScreenState extends State<TimeDiffScreen> {
  DateTime? _start;
  DateTime? _end;

  TimeValue? get _diff {
    if (_start == null || _end == null) return null;
    return TimeValue(_end!.difference(_start!).inSeconds.abs());
  }

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? (_start ?? now) : (_end ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) { _start = combined; } else { _end = combined; }
    });
  }

  String _fmtDateTime(DateTime dt) {
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d  $h:$mi';
  }

  String _fmtDouble(double v, int dec) {
    final s = v.toStringAsFixed(dec);
    return s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = _diff;
    final endBeforeStart = _start != null && _end != null && _end!.isBefore(_start!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a start and end date/time to calculate the difference:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          _DateTimeTile(
            label: 'Start',
            value: _start,
            formatted: _start != null ? _fmtDateTime(_start!) : null,
            onTap: () => _pick(true),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.arrow_downward_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  if (diff != null && !endBeforeStart)
                    Text(
                      '${diff.days}d  ${diff.hours}h  ${diff.mins}m  ${diff.secs}s',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),

          _DateTimeTile(
            label: 'End',
            value: _end,
            formatted: _end != null ? _fmtDateTime(_end!) : null,
            onTap: () => _pick(false),
            hasError: endBeforeStart,
          ),

          if (endBeforeStart)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'End is before start — showing absolute difference',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),

          if (diff != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Difference',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Big result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DiffUnit(diff.days, 'Days', theme),
                      _divider(theme),
                      _DiffUnit(diff.hours, 'Hours', theme),
                      _divider(theme),
                      _DiffUnit(diff.mins, 'Mins', theme),
                      _divider(theme),
                      _DiffUnit(diff.secs, 'Secs', theme),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _ConvRow('Total seconds', '${diff.totalSeconds}'),
            const SizedBox(height: 6),
            _ConvRow('Total minutes', _fmtDouble(diff.inMinutes, 4)),
            const SizedBox(height: 6),
            _ConvRow('Total hours', _fmtDouble(diff.inHours, 6)),
            const SizedBox(height: 6),
            _ConvRow('Total days', _fmtDouble(diff.inDays, 8)),
          ],

          if (_start != null || _end != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() { _start = null; _end = null; }),
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) => Container(
    width: 1,
    height: 48,
    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
  );
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? formatted;
  final VoidCallback onTap;
  final bool hasError;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.formatted,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = hasError
        ? theme.colorScheme.errorContainer
        : value != null
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest;
    final Color fg = hasError
        ? theme.colorScheme.onErrorContainer
        : value != null
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: fg, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.7))),
                    const SizedBox(height: 2),
                    Text(
                      formatted ?? 'Tap to select date & time',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: fg.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffUnit extends StatelessWidget {
  final int value;
  final String unit;
  final ThemeData theme;

  const _DiffUnit(this.value, this.unit, this.theme);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '$value',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      Text(
        unit,
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      ),
    ],
  );
}

class _ConvRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConvRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
