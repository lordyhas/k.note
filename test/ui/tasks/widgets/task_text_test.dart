import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:knote/domain/models/task_repeat.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/tasks/widgets/task_text.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));

  // In the app, GlobalMaterialLocalizations loads the date symbols.
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('fr');
  });

  group('repeatText', () {
    test('names the presets', () {
      expect(repeatText(en, TaskRepeat.weekdaysOnly), 'Weekdays');
      expect(repeatText(fr, TaskRepeat.weekly), 'Toutes les semaines');
    });

    test('describes custom rules with plurals', () {
      expect(repeatText(en, TaskRepeat.parse('custom:1:day')!), 'Every day');
      expect(repeatText(en, TaskRepeat.parse('custom:3:month')!),
          'Every 3 months');
      expect(repeatText(fr, TaskRepeat.parse('custom:3:month')!),
          'Tous les 3 mois');
      expect(
          repeatText(fr, TaskRepeat.parse('custom:2:year')!), 'Tous les 2 ans');
    });

    test('lists the weekdays of a weekly rule', () {
      final rule = TaskRepeat.parse('custom:2:week:1,3')!;
      expect(repeatText(en, rule), 'Every 2 weeks on Mon, Wed');
      expect(repeatText(fr, rule), 'Toutes les 2 semaines, le lun., mer.');
      expect(repeatText(en, TaskRepeat.parse('custom:1:week:7')!),
          'Every week on Sun');
    });
  });

  test('repeatValueText shows unknown stored values as they are', () {
    expect(repeatValueText(en, 'custom:2:year'), 'Every 2 years');
    expect(repeatValueText(fr, 'Hourly'), 'Hourly');
  });

  test('repeatUnitText agrees with the count', () {
    expect(repeatUnitText(en, RepeatUnit.week, 1), 'week');
    expect(repeatUnitText(en, RepeatUnit.week, 2), 'weeks');
    expect(repeatUnitText(fr, RepeatUnit.year, 3), 'ans');
  });

  group('dueDateText', () {
    final now = DateTime(2026, 10, 23, 18, 30); // Friday

    test('names the days around today', () {
      expect(dueDateText(en, DateTime(2026, 10, 22), now: now), 'Yesterday');
      expect(dueDateText(en, DateTime(2026, 10, 23), now: now), 'Today');
      expect(dueDateText(fr, DateTime(2026, 10, 24), now: now), 'Demain');
    });

    test('shows other days as a short date in the app language', () {
      expect(dueDateText(en, DateTime(2026, 10, 30), now: now), 'Fri, Oct 30');
      expect(dueDateText(fr, DateTime(2026, 10, 30), now: now), 'ven. 30 oct.');
    });

    test('is not thrown off by a daylight saving change', () {
      // Clocks go back in Europe on 2026-10-25: that day lasts 25 hours.
      final saturday = DateTime(2026, 10, 24, 12);
      expect(
          dueDateText(en, DateTime(2026, 10, 25), now: saturday), 'Tomorrow');
    });
  });
}
