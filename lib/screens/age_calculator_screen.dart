import 'package:flutter/material.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _birthDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Map<String, int> _computeAge(DateTime born, DateTime now) {
    int years = now.year - born.year;
    int months = now.month - born.month;
    int days = now.day - born.day;

    if (days < 0) {
      months--;
      final daysInPrevMonth = DateTime(now.year, now.month, 0).day;
      days += daysInPrevMonth;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date of birth picker
          Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.cake_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Birth',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _birthDate == null
                                ? 'Tap to select'
                                : _formatDate(_birthDate!),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: _birthDate == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_calendar_outlined,
                        color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),

          if (_birthDate != null) ...[
            const SizedBox(height: 24),
            _buildResults(theme, now),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, DateTime now) {
    final born = _birthDate!;
    final age = _computeAge(born, now);
    final totalDays = now.difference(born).inDays;

    DateTime nextBirthday = DateTime(now.year, born.month, born.day);
    if (!nextBirthday.isAfter(now)) {
      nextBirthday = DateTime(now.year + 1, born.month, born.day);
    }
    final daysUntilBirthday = nextBirthday.difference(
      DateTime(now.year, now.month, now.day),
    ).inDays;
    final isBirthdayToday = daysUntilBirthday == 0;

    return Column(
      children: [
        // Primary age display
        _Card(
          theme: theme,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AgeUnit(value: age['years']!, label: 'Years', theme: theme),
              _Divider(theme: theme),
              _AgeUnit(value: age['months']!, label: 'Months', theme: theme),
              _Divider(theme: theme),
              _AgeUnit(value: age['days']!, label: 'Days', theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stats row
        Row(
          children: [
            Expanded(
              child: _Card(
                theme: theme,
                child: _StatTile(
                  label: 'Total Days',
                  value: _commas(totalDays),
                  icon: Icons.today_outlined,
                  theme: theme,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Card(
                theme: theme,
                child: _StatTile(
                  label: 'Total Months',
                  value: _commas(age['years']! * 12 + age['months']!),
                  icon: Icons.calendar_month_outlined,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Card(
          theme: theme,
          child: _StatTile(
            label: isBirthdayToday ? 'Happy Birthday!' : 'Next Birthday',
            value: isBirthdayToday
                ? _formatDate(nextBirthday)
                : 'in $daysUntilBirthday day${daysUntilBirthday == 1 ? '' : 's'}',
            icon: Icons.celebration_outlined,
            theme: theme,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${_monthName(d.month)} ${d.day}, ${d.year}';

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  String _commas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Card extends StatelessWidget {
  final ThemeData theme;
  final Widget child;

  const _Card({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}

class _AgeUnit extends StatelessWidget {
  final int value;
  final String label;
  final ThemeData theme;

  const _AgeUnit({required this.value, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}

class _Divider extends StatelessWidget {
  final ThemeData theme;
  const _Divider({required this.theme});

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        color: theme.colorScheme.outlineVariant,
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
