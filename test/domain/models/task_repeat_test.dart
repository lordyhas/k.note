import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/task_repeat.dart';

void main() {
  group('TaskRepeat presets', () {
    test('keep their historical stored values', () {
      expect(TaskRepeat.presets.map((r) => r.encode()),
          ['Daily', 'Weekdays', 'Weekly', 'Monthly', 'Yearly']);
    });

    test('parse back to the same preset', () {
      for (final preset in TaskRepeat.presets) {
        expect(TaskRepeat.parse(preset.encode()), same(preset));
      }
    });

    test('are not custom', () {
      expect(TaskRepeat.weekly.isCustom, isFalse);
    });
  });

  group('TaskRepeat custom rules', () {
    test('round-trip through encode and parse', () {
      const rule = TaskRepeat.custom(
          interval: 2, unit: RepeatUnit.week, weekdays: {3, 1});
      expect(rule.encode(), 'custom:2:week:1,3');

      final parsed = TaskRepeat.parse(rule.encode())!;
      expect(parsed.isCustom, isTrue);
      expect(parsed.interval, 2);
      expect(parsed.unit, RepeatUnit.week);
      expect(parsed.weekdays, {1, 3});
    });

    test('only weekly rules keep weekdays', () {
      expect(TaskRepeat.parse('custom:3:month:1,2')!.weekdays, isEmpty);
      expect(
          const TaskRepeat.custom(
              interval: 3, unit: RepeatUnit.day, weekdays: {1}).encode(),
          'custom:3:day');
    });
  });

  group('TaskRepeat.parse', () {
    test('rejects null and malformed values', () {
      for (final value in [
        null,
        '',
        'Hourly',
        'custom',
        'custom:0:day',
        'custom:x:day',
        'custom:2:fortnight',
      ]) {
        expect(TaskRepeat.parse(value), isNull, reason: '$value');
      }
    });

    test('ignores invalid weekdays', () {
      expect(TaskRepeat.parse('custom:1:week:0,2,9,x')!.weekdays, {2});
    });
  });
}
