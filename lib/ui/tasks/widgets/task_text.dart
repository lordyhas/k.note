import 'package:intl/intl.dart';

import 'package:knote/domain/models/task_repeat.dart';
import 'package:knote/ui/core/localization/l10n.dart';

/// How [repeat] reads in the app's language, e.g. "Every 2 weeks on Mon,
/// Wed" or "Toutes les 2 semaines, le lun., mer.".
String repeatText(AppLocalizations l10n, TaskRepeat repeat) {
  switch (repeat) {
    case TaskRepeat.daily:
      return l10n.repeatDaily;
    case TaskRepeat.weekdaysOnly:
      return l10n.repeatWeekdays;
    case TaskRepeat.weekly:
      return l10n.repeatWeekly;
    case TaskRepeat.monthly:
      return l10n.repeatMonthly;
    case TaskRepeat.yearly:
      return l10n.repeatYearly;
  }
  final count = repeat.interval;
  final rule = switch (repeat.unit) {
    RepeatUnit.day => l10n.repeatEveryDays(count),
    RepeatUnit.week => l10n.repeatEveryWeeks(count),
    RepeatUnit.month => l10n.repeatEveryMonths(count),
    RepeatUnit.year => l10n.repeatEveryYears(count),
  };
  if (repeat.weekdays.isEmpty) return rule;
  final days = (repeat.weekdays.toList()..sort())
      .map((day) => _weekdayName(l10n, day))
      .join(', ');
  return l10n.repeatOnDays(rule, days);
}

/// [repeatText] for a stored [CheckList.repeat] value; values the app does
/// not know are shown as they are.
String repeatValueText(AppLocalizations l10n, String value) {
  final repeat = TaskRepeat.parse(value);
  return repeat == null ? value : repeatText(l10n, repeat);
}

/// The unit of a custom rule after its [count], e.g. "weeks".
String repeatUnitText(AppLocalizations l10n, RepeatUnit unit, int count) {
  return switch (unit) {
    RepeatUnit.day => l10n.unitDays(count),
    RepeatUnit.week => l10n.unitWeeks(count),
    RepeatUnit.month => l10n.unitMonths(count),
    RepeatUnit.year => l10n.unitYears(count),
  };
}

/// A date without the year, e.g. "Fri, Oct 31" or "ven. 31 oct.".
String shortDate(AppLocalizations l10n, DateTime date) =>
    DateFormat.MMMEd(l10n.localeName).format(date);

/// The day of the week, e.g. "Friday" or "vendredi".
String weekdayName(AppLocalizations l10n, DateTime date) =>
    DateFormat.EEEE(l10n.localeName).format(date);

/// A task's due date in the task list: Yesterday, Today, Tomorrow or a
/// [shortDate].
String dueDateText(AppLocalizations l10n, DateTime dueDate,
    {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dueDate.year, dueDate.month, dueDate.day);
  // Rounded: a day can last 23 or 25 hours when the clocks change.
  final days = (day.difference(today).inHours / 24).round();
  return switch (days) {
    -1 => l10n.dateYesterday,
    0 => l10n.dateToday,
    1 => l10n.dateTomorrow,
    _ => shortDate(l10n, dueDate),
  };
}

/// Abbreviated name of an ISO weekday (1 = Monday ... 7 = Sunday).
String _weekdayName(AppLocalizations l10n, int isoWeekday) {
  // 2024-01-01 was a Monday.
  return DateFormat.E(l10n.localeName).format(DateTime(2024, 1, isoWeekday));
}
