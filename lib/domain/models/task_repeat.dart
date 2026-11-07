/// How often a task repeats, stored in [CheckList.repeat] as a string.
///
/// Presets keep their historical values ("Daily", "Weekdays", "Weekly",
/// "Monthly", "Yearly"). A custom rule is stored as
/// `custom:<interval>:<unit>` or, for weeks, `custom:<interval>:week:<days>`
/// where days are ISO weekdays (1 = Monday ... 7 = Sunday), e.g.
/// `custom:2:week:1,3` for "every 2 weeks on Monday and Wednesday".
class TaskRepeat {
  const TaskRepeat._({
    required this.interval,
    required this.unit,
    this.weekdays = const {},
    this.preset,
  });

  const TaskRepeat.custom({
    required int interval,
    required RepeatUnit unit,
    Set<int> weekdays = const {},
  }) : this._(interval: interval, unit: unit, weekdays: weekdays);

  static const daily =
      TaskRepeat._(interval: 1, unit: RepeatUnit.day, preset: 'Daily');
  static const weekdaysOnly = TaskRepeat._(
      interval: 1,
      unit: RepeatUnit.week,
      weekdays: {1, 2, 3, 4, 5},
      preset: 'Weekdays');
  static const weekly =
      TaskRepeat._(interval: 1, unit: RepeatUnit.week, preset: 'Weekly');
  static const monthly =
      TaskRepeat._(interval: 1, unit: RepeatUnit.month, preset: 'Monthly');
  static const yearly =
      TaskRepeat._(interval: 1, unit: RepeatUnit.year, preset: 'Yearly');

  static const presets = [daily, weekdaysOnly, weekly, monthly, yearly];

  /// Repeat every [interval] [unit]s.
  final int interval;
  final RepeatUnit unit;

  /// ISO weekdays (1 = Monday) a weekly rule falls on; empty means "the same
  /// weekday as the task".
  final Set<int> weekdays;

  /// The stored name of a preset, null for a custom rule.
  final String? preset;

  bool get isCustom => preset == null;

  /// Parses a stored value. Returns null for null or unrecognised values.
  static TaskRepeat? parse(String? value) {
    if (value == null) return null;
    for (final preset in presets) {
      if (preset.preset == value) return preset;
    }
    final parts = value.split(':');
    if (parts.length < 3 || parts[0] != 'custom') return null;
    final interval = int.tryParse(parts[1]);
    final unit = RepeatUnit.values.asNameMap()[parts[2]];
    if (interval == null || interval < 1 || unit == null) return null;
    final weekdays = parts.length > 3 && parts[3].isNotEmpty
        ? parts[3]
            .split(',')
            .map(int.tryParse)
            .whereType<int>()
            .where((day) => day >= 1 && day <= 7)
            .toSet()
        : <int>{};
    return TaskRepeat.custom(
      interval: interval,
      unit: unit,
      weekdays: unit == RepeatUnit.week ? weekdays : const {},
    );
  }

  /// The next date the task falls on after [date], at the same time of day.
  ///
  /// Weekly rules with [weekdays] move to the next selected day of the same
  /// week, or to the first selected day [interval] weeks later. Months and
  /// years keep the day of the month, clamped to the length of the month
  /// (January 31 is followed by the last day of February).
  DateTime nextAfter(DateTime date) {
    switch (unit) {
      case RepeatUnit.day:
        return _addDays(date, interval);
      case RepeatUnit.week:
        if (weekdays.isEmpty) return _addDays(date, 7 * interval);
        final days = weekdays.toList()..sort();
        for (final day in days) {
          if (day > date.weekday) return _addDays(date, day - date.weekday);
        }
        // Monday of the week [interval] weeks later, then its first day.
        final monday = _addDays(date, 7 * interval - (date.weekday - 1));
        return _addDays(monday, days.first - 1);
      case RepeatUnit.month:
        return _withMonth(date, date.year, date.month + interval);
      case RepeatUnit.year:
        return _withMonth(date, date.year + interval, date.month);
    }
  }

  /// Calendar days, so that a daylight saving change keeps the time of day.
  static DateTime _addDays(DateTime date, int days) => DateTime(date.year,
      date.month, date.day + days, date.hour, date.minute, date.second);

  static DateTime _withMonth(DateTime date, int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  /// The value to store in [CheckList.repeat].
  String encode() {
    final preset = this.preset;
    if (preset != null) return preset;
    final base = 'custom:$interval:${unit.name}';
    if (unit != RepeatUnit.week || weekdays.isEmpty) return base;
    return '$base:${(weekdays.toList()..sort()).join(',')}';
  }
}

enum RepeatUnit { day, week, month, year }
