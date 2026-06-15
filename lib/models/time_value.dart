class TimeValue {
  final int totalSeconds;
  const TimeValue(this.totalSeconds);

  factory TimeValue.fromParts(int d, int h, int m, int s) =>
      TimeValue(d * 86400 + h * 3600 + m * 60 + s);

  int get days => totalSeconds.abs() ~/ 86400;
  int get hours => (totalSeconds.abs() % 86400) ~/ 3600;
  int get mins => (totalSeconds.abs() % 3600) ~/ 60;
  int get secs => totalSeconds.abs() % 60;
  bool get isNegative => totalSeconds < 0;

  double get inMinutes => totalSeconds / 60.0;
  double get inHours => totalSeconds / 3600.0;
  double get inDays => totalSeconds / 86400.0;

  TimeValue operator +(TimeValue o) => TimeValue(totalSeconds + o.totalSeconds);
  TimeValue operator -(TimeValue o) => TimeValue(totalSeconds - o.totalSeconds);
  TimeValue scale(double f) => TimeValue((totalSeconds * f).round());

  static const zero = TimeValue(0);
}
