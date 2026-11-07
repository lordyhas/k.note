import 'package:flutter/material.dart';

import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/utils/save_in_background.dart';

/// Gives every page the user's [UserPreferences] and a way to change them.
///
/// `main.dart` places it above the app with the preferences of
/// `PreferencesCubit`. Pages read it through [of] rather than the cubit, so
/// widget tests that pump a page alone get [UserPreferences.defaults].
class PreferencesScope extends InheritedWidget {
  const PreferencesScope({
    super.key,
    required this.preferences,
    this.onChanged,
    required super.child,
  });

  final UserPreferences preferences;

  /// Saves new preferences; returns the Firestore write. Null when nothing
  /// stores them (tests).
  final Future<void> Function(UserPreferences preferences)? onChanged;

  /// The preferences of the signed-in user, or the defaults.
  static UserPreferences of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PreferencesScope>()
          ?.preferences ??
      UserPreferences.defaults;

  /// Saves [preferences] without waiting for the server, and reports a
  /// failure in a snack bar (see [saveInBackground]).
  static void update(BuildContext context, UserPreferences preferences) {
    final onChanged =
        context.getInheritedWidgetOfExactType<PreferencesScope>()?.onChanged;
    if (onChanged == null) return;
    saveInBackground(
      () => onChanged(preferences),
      failureMessage: context.l10n.preferencesSaveFailed,
    );
  }

  /// [MaterialLocalizations.firstDayOfWeekIndex] (0 = Sunday), unless the
  /// user chose another first day of the week.
  static int firstDayOfWeekIndex(BuildContext context) =>
      of(context).firstDayOfWeekIndex ??
      MaterialLocalizations.of(context).firstDayOfWeekIndex;

  @override
  bool updateShouldNotify(PreferencesScope oldWidget) =>
      preferences != oldWidget.preferences;
}
