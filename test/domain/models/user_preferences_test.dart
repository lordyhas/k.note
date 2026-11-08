import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/user_preferences.dart';

void main() {
  const custom = UserPreferences(
    language: AppLanguage.fr,
    notesLayout: NotesLayout.grid,
    remindersEnabled: false,
    reminderHour: 7,
    firstDayOfWeek: FirstDayOfWeek.monday,
  );

  test('defaults keep the app as it was', () {
    const defaults = UserPreferences.defaults;
    expect(defaults.language, AppLanguage.system);
    expect(defaults.languageCode, isNull);
    expect(defaults.notesLayout, NotesLayout.list);
    expect(defaults.remindersEnabled, isTrue);
    expect(defaults.reminderHour, 9);
    expect(defaults.firstDayOfWeekIndex, isNull);
  });

  test('round-trips through a Firestore map', () {
    expect(UserPreferences.fromMap(custom.asMap()), custom);
    expect(custom.asMap(), {
      'language': 'fr',
      'notes_layout': 'grid',
      'reminders_enabled': false,
      'reminder_hour': 7,
      'first_day_of_week': 'monday',
    });
  });

  test('missing, unknown or malformed values fall back to the defaults', () {
    expect(UserPreferences.fromMap(null), UserPreferences.defaults);
    expect(UserPreferences.fromMap(const {}), UserPreferences.defaults);
    expect(
      UserPreferences.fromMap(const {
        'language': 'de',
        'notes_layout': 42,
        'reminders_enabled': 'yes',
        'reminder_hour': 25,
        'first_day_of_week': 'friday',
        'theme': 'light',
      }),
      UserPreferences.defaults,
    );
  });

  test('exposes the language code and first day of the week index', () {
    expect(custom.languageCode, 'fr');
    expect(custom.firstDayOfWeekIndex, 1);
    expect(
        const UserPreferences(firstDayOfWeek: FirstDayOfWeek.sunday)
            .firstDayOfWeekIndex,
        0);
    expect(
        const UserPreferences(firstDayOfWeek: FirstDayOfWeek.saturday)
            .firstDayOfWeekIndex,
        6);
  });

  test('copyWith changes only what it is given', () {
    final changed =
        UserPreferences.defaults.copyWith(notesLayout: NotesLayout.grid);
    expect(changed.notesLayout, NotesLayout.grid);
    expect(changed.copyWith(notesLayout: NotesLayout.list),
        UserPreferences.defaults);
  });
}
