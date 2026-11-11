import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/preferences_scope.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/tasks/widgets/task_text.dart';

/// The user's preferences, saved to their account (see [UserPreferences]).
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});
  static const routeName = "preferences";

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final preferences = PreferencesScope.of(context);
    void update(UserPreferences value) =>
        PreferencesScope.update(context, value);

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              Card(
                color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                margin: EdgeInsets.zero,
                child: Column(children: children),
              ),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.preferencesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  section(l10n.preferencesGeneral, [
                    ListTile(
                      key: const Key('__preferences_language__'),
                      leading: Icon(Icons.language, color: colors.text),
                      title: Text(l10n.preferencesLanguage),
                      subtitle: Text(_languageText(l10n, preferences.language)),
                      onTap: () async {
                        final choice = await _choose<AppLanguage>(
                          context,
                          title: l10n.preferencesLanguage,
                          values: AppLanguage.values,
                          selected: preferences.language,
                          label: (value) => _languageText(l10n, value),
                        );
                        if (choice != null && context.mounted) {
                          update(preferences.copyWith(language: choice));
                        }
                      },
                    ),
                  ]),
                  section(l10n.navNotes, [
                    ListTile(
                      leading:
                          Icon(Icons.dashboard_outlined, color: colors.text),
                      title: Text(l10n.preferencesNotesLayout),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SegmentedButton<NotesLayout>(
                          key: const Key('__preferences_layout__'),
                          segments: [
                            ButtonSegment(
                              value: NotesLayout.list,
                              icon: const Icon(Icons.view_agenda_outlined),
                              label: Text(l10n.preferencesLayoutList),
                            ),
                            ButtonSegment(
                              value: NotesLayout.grid,
                              icon: const Icon(Icons.grid_view),
                              label: Text(l10n.preferencesLayoutGrid),
                            ),
                          ],
                          selected: {preferences.notesLayout},
                          onSelectionChanged: (selection) => update(preferences
                              .copyWith(notesLayout: selection.single)),
                        ),
                      ),
                    ),
                  ]),
                  section(l10n.navTasks, [
                    SwitchListTile(
                      key: const Key('__preferences_reminders__'),
                      secondary: Icon(Icons.notifications_outlined,
                          color: colors.text),
                      title: Text(l10n.preferencesReminders),
                      subtitle: Text(kIsWeb
                          ? l10n.preferencesRemindersWeb
                          : l10n.preferencesRemindersSubtitle),
                      value: preferences.remindersEnabled,
                      onChanged: (value) =>
                          update(preferences.copyWith(remindersEnabled: value)),
                    ),
                    ListTile(
                      key: const Key('__preferences_reminder_hour__'),
                      leading: Icon(Icons.schedule, color: colors.text),
                      title: Text(l10n.preferencesReminderHour),
                      subtitle: Text(
                          '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay(hour: preferences.reminderHour, minute: 0))}'
                          ' · ${l10n.preferencesReminderHourSubtitle}'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: preferences.reminderHour, minute: 0),
                          initialEntryMode: TimePickerEntryMode.dial,
                          helpText: l10n.preferencesReminderHour,
                        );
                        if (time != null && context.mounted) {
                          update(preferences.copyWith(reminderHour: time.hour));
                        }
                      },
                    ),
                    ListTile(
                      key: const Key('__preferences_first_day__'),
                      leading:
                          Icon(Icons.calendar_view_week, color: colors.text),
                      title: Text(l10n.preferencesFirstDay),
                      subtitle: Text(
                          _firstDayText(context, preferences.firstDayOfWeek)),
                      onTap: () async {
                        final choice = await _choose<FirstDayOfWeek>(
                          context,
                          title: l10n.preferencesFirstDay,
                          values: FirstDayOfWeek.values,
                          selected: preferences.firstDayOfWeek,
                          label: (value) => _firstDayText(context, value),
                        );
                        if (choice != null && context.mounted) {
                          update(preferences.copyWith(firstDayOfWeek: choice));
                        }
                      },
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.preferencesSynced,
                      style: TextStyle(color: colors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _languageText(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => l10n.preferencesLanguageSystem,
        // Each language is written in its own language.
        AppLanguage.en => 'English',
        AppLanguage.fr => 'Français',
      };

  static String _firstDayText(BuildContext context, FirstDayOfWeek day) {
    final l10n = context.l10n;
    final days = MaterialLocalizations.of(context);
    String name(int index) => _capitalize(_weekdayNames(l10n)[index]);
    return switch (day) {
      FirstDayOfWeek.system =>
        l10n.preferencesFirstDaySystem(name(days.firstDayOfWeekIndex)),
      FirstDayOfWeek.sunday => name(0),
      FirstDayOfWeek.monday => name(1),
      FirstDayOfWeek.saturday => name(6),
    };
  }

  /// Full weekday names, Sunday first, in the app's language.
  static List<String> _weekdayNames(AppLocalizations l10n) => [
        // 2023-01-01 was a Sunday.
        for (var i = 0; i < 7; i++) weekdayName(l10n, DateTime(2023, 1, 1 + i)),
      ];

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// A dialog listing [values] as radio buttons; returns the one picked.
  static Future<T?> _choose<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T value) label,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<T>(
            groupValue: selected,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in values)
                  RadioListTile<T>(value: value, title: Text(label(value))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
