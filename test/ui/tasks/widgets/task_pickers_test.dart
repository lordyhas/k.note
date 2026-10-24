import 'package:flutter_test/flutter_test.dart';

import 'package:knote/ui/tasks/widgets/task_pickers.dart';

void main() {
  // Friday, October 23rd 2026, in the afternoon.
  final friday = DateTime(2026, 10, 23, 15, 30);

  DateTime due(DueDateShortcut shortcut, DateTime now, {int firstDay = 0}) =>
      dueDateFor(shortcut, now: now, firstDayOfWeekIndex: firstDay);

  group('dueDateFor', () {
    test('today and tomorrow are at midnight', () {
      expect(due(DueDateShortcut.today, friday), DateTime(2026, 10, 23));
      expect(due(DueDateShortcut.tomorrow, friday), DateTime(2026, 10, 24));
    });

    test('next week starts on Sunday for Sunday-first locales', () {
      expect(due(DueDateShortcut.nextWeek, friday), DateTime(2026, 10, 25));
    });

    test('next week starts on Monday for Monday-first locales', () {
      expect(due(DueDateShortcut.nextWeek, friday, firstDay: 1),
          DateTime(2026, 10, 26));
    });

    test('on the first day of the week, next week is 7 days later', () {
      final sunday = DateTime(2026, 10, 25, 9);
      expect(due(DueDateShortcut.nextWeek, sunday), DateTime(2026, 11, 1));
    });

    test('crosses month and year boundaries', () {
      final newYearsEve = DateTime(2026, 12, 31, 23, 59);
      expect(due(DueDateShortcut.tomorrow, newYearsEve), DateTime(2027, 1, 1));
      expect(due(DueDateShortcut.nextWeek, newYearsEve, firstDay: 1),
          DateTime(2027, 1, 4));
    });
  });

  group('reminderFor', () {
    DateTime? remind(ReminderShortcut shortcut, DateTime now,
            {int firstDay = 0}) =>
        reminderFor(shortcut, now: now, firstDayOfWeekIndex: firstDay);

    test('later today is three hours later, rounded up to the hour', () {
      expect(remind(ReminderShortcut.laterToday, DateTime(2026, 10, 23, 0, 52)),
          DateTime(2026, 10, 23, 4));
      expect(remind(ReminderShortcut.laterToday, DateTime(2026, 10, 23, 13)),
          DateTime(2026, 10, 23, 16));
    });

    test('later today is unavailable when it would fall tomorrow', () {
      expect(remind(ReminderShortcut.laterToday, DateTime(2026, 10, 23, 21)),
          isNull);
      expect(
          remind(ReminderShortcut.laterToday, DateTime(2026, 10, 23, 20, 30)),
          isNull,
          reason: 'rounds up to midnight');
      expect(remind(ReminderShortcut.laterToday, DateTime(2026, 10, 23, 20)),
          DateTime(2026, 10, 23, 23));
    });

    test('tomorrow and next week are at 9 a.m.', () {
      expect(remind(ReminderShortcut.tomorrow, friday),
          DateTime(2026, 10, 24, reminderMorningHour));
      expect(remind(ReminderShortcut.nextWeek, friday),
          DateTime(2026, 10, 25, reminderMorningHour));
      expect(remind(ReminderShortcut.nextWeek, friday, firstDay: 1),
          DateTime(2026, 10, 26, reminderMorningHour));
    });
  });
}
