import 'package:equatable/equatable.dart';

import 'package:knote/domain/models/document_model.dart';

/// The app's language: the device's, or one chosen by the user.
enum AppLanguage { system, en, fr }

/// How the notes list is laid out.
enum NotesLayout { grid, list }

/// The first day of the week in the calendar and the "Next week" shortcuts:
/// the language's, or one chosen by the user.
enum FirstDayOfWeek { system, monday, sunday, saturday }

/// The signed-in user's settings, stored in Firestore so they follow the
/// account to every device (`users/{uid}/settings/preferences`).
///
/// Adding a field: give it a default, read it defensively in [fromMap] (old
/// documents and newer app versions both exist), and add its key to
/// `preferenceKeys()` in `firestore.rules`.
class UserPreferences extends Equatable implements DataToMap {
  const UserPreferences({
    this.language = AppLanguage.system,
    this.notesLayout = NotesLayout.list,
    this.remindersEnabled = true,
    this.reminderHour = defaultReminderHour,
    this.firstDayOfWeek = FirstDayOfWeek.system,
  });

  /// What a new account, or a signed-out user, gets.
  static const defaults = UserPreferences();

  static const defaultReminderHour = 9;

  final AppLanguage language;
  final NotesLayout notesLayout;

  /// Whether task reminders show notifications on this account's devices.
  final bool remindersEnabled;

  /// Hour of the day (0-23) of the "Tomorrow" and "Next week" reminders.
  final int reminderHour;

  final FirstDayOfWeek firstDayOfWeek;

  /// [MaterialLocalizations.firstDayOfWeekIndex] for [firstDayOfWeek] (0 =
  /// Sunday), or null to keep the language's.
  int? get firstDayOfWeekIndex => switch (firstDayOfWeek) {
        FirstDayOfWeek.system => null,
        FirstDayOfWeek.sunday => 0,
        FirstDayOfWeek.monday => 1,
        FirstDayOfWeek.saturday => 6,
      };

  /// The language code to force, or null to follow the device.
  String? get languageCode =>
      language == AppLanguage.system ? null : language.name;

  UserPreferences copyWith({
    AppLanguage? language,
    NotesLayout? notesLayout,
    bool? remindersEnabled,
    int? reminderHour,
    FirstDayOfWeek? firstDayOfWeek,
  }) =>
      UserPreferences(
        language: language ?? this.language,
        notesLayout: notesLayout ?? this.notesLayout,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      );

  /// Reads a stored document; missing or unknown values fall back to
  /// [defaults], so a damaged document never breaks the app.
  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;
    T pick<T extends Enum>(List<T> values, Object? value, T fallback) =>
        values.asNameMap()[value] ?? fallback;
    final hour = map['reminder_hour'];
    return UserPreferences(
      language: pick(AppLanguage.values, map['language'], defaults.language),
      notesLayout:
          pick(NotesLayout.values, map['notes_layout'], defaults.notesLayout),
      remindersEnabled: map['reminders_enabled'] is bool
          ? map['reminders_enabled'] as bool
          : defaults.remindersEnabled,
      reminderHour:
          hour is int && hour >= 0 && hour <= 23 ? hour : defaults.reminderHour,
      firstDayOfWeek: pick(FirstDayOfWeek.values, map['first_day_of_week'],
          defaults.firstDayOfWeek),
    );
  }

  @override
  Map<String, dynamic> asMap() => {
        'language': language.name,
        'notes_layout': notesLayout.name,
        'reminders_enabled': remindersEnabled,
        'reminder_hour': reminderHour,
        'first_day_of_week': firstDayOfWeek.name,
      };

  @override
  void toDisplay() {}

  @override
  List<Object?> get props =>
      [language, notesLayout, remindersEnabled, reminderHour, firstDayOfWeek];
}
