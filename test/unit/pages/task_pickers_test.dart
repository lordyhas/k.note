import 'package:flutter_test/flutter_test.dart';
import 'package:knote/src/pages/pages/task_pickers.dart';

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
}
