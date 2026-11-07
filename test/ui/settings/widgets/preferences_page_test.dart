import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/ui/core/preferences_scope.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/settings/widgets/preferences_page.dart';

import '../../../helpers/localized_app.dart';

/// The page under a [PreferencesScope] that stores what it receives, like
/// the app does through `PreferencesCubit`.
class _Harness extends StatefulWidget {
  const _Harness({required this.saved, this.locale = const Locale('en')});

  final List<UserPreferences> saved;
  final Locale locale;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  var _preferences = UserPreferences.defaults;

  @override
  Widget build(BuildContext context) {
    return PreferencesScope(
      preferences: _preferences,
      onChanged: (preferences) async {
        widget.saved.add(preferences);
        setState(() => _preferences = preferences);
      },
      child: Theme(
        data: AppTheme.dark,
        child: localizedApp(
          locale: widget.locale,
          home: const PreferencesPage(),
        ),
      ),
    );
  }
}

void main() {
  late List<UserPreferences> saved;

  setUp(() => saved = []);

  testWidgets('shows the current preferences', (tester) async {
    await tester.pumpWidget(_Harness(saved: saved));

    expect(find.text('Device language'), findsOneWidget);
    expect(find.text('Task reminders'), findsOneWidget);
    expect(
        tester
            .widget<SwitchListTile>(
                find.byKey(const Key('__preferences_reminders__')))
            .value,
        isTrue);
    expect(find.textContaining('9:00 AM'), findsOneWidget);
  });

  testWidgets('choosing a language saves it', (tester) async {
    await tester.pumpWidget(_Harness(saved: saved));

    await tester.tap(find.byKey(const Key('__preferences_language__')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(saved.single.language, AppLanguage.fr);
    expect(find.text('Français'), findsOneWidget);
  });

  testWidgets('layout, reminders and first day of the week are saved',
      (tester) async {
    await tester.pumpWidget(_Harness(saved: saved));

    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    expect(saved.last.notesLayout, NotesLayout.grid);

    await tester.tap(find.byKey(const Key('__preferences_reminders__')));
    await tester.pumpAndSettle();
    expect(saved.last.remindersEnabled, isFalse);

    await tester.tap(find.byKey(const Key('__preferences_first_day__')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monday'));
    await tester.pumpAndSettle();
    expect(saved.last.firstDayOfWeek, FirstDayOfWeek.monday);
    // Each change keeps the earlier ones.
    expect(saved.last.notesLayout, NotesLayout.grid);
    expect(saved.last.remindersEnabled, isFalse);
  });

  testWidgets('is translated into French', (tester) async {
    await tester.pumpWidget(_Harness(saved: saved, locale: const Locale('fr')));

    expect(find.text('Préférences'), findsOneWidget);
    expect(find.text("Langue de l'appareil"), findsOneWidget);
    expect(find.text('Rappels des tâches'), findsOneWidget);
  });
}
