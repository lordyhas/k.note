import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/calendar/widgets/calendar_page.dart';
import 'package:knote/ui/core/themes/app_theme.dart';

import '../../../helpers/localized_app.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);
final _today = DateTime(2026, 3, 10);

void main() {
  late FirestoreService manager;

  setUp(() async {
    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
    await manager.addTaskInCloud(
        task: CheckList(
            id: 't1',
            title: 'Dentist',
            list: const [],
            dueDate: DateTime(2026, 3, 10)));
    await manager.addTaskInCloud(
        task: CheckList(
            id: 't2',
            title: 'Call the bank',
            list: const [],
            reminderTime: DateTime(2026, 3, 12, 9, 30)));
    await manager.addTaskInCloud(
        task: CheckList(id: 't3', title: 'Someday', list: const []));
  });

  Future<void> pumpPage(WidgetTester tester,
      {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: localizedApp(
        locale: locale,
        home: CalendarPage(firebaseManager: manager, today: _today),
      ),
    ));
    await tester.pumpAndSettle();
  }

  test('a task is placed on its due date, else on its reminder date', () {
    expect(
        CalendarPage.dayOf(CheckList(
            title: '',
            list: const [],
            dueDate: DateTime(2026, 3, 10, 18),
            reminderTime: DateTime(2026, 3, 9, 8))),
        DateTime(2026, 3, 10));
    expect(
        CalendarPage.dayOf(CheckList(
            title: '', list: const [], reminderTime: DateTime(2026, 3, 9, 8))),
        DateTime(2026, 3, 9));
    expect(CalendarPage.dayOf(CheckList(title: '', list: const [])), isNull);
  });

  testWidgets("shows today's tasks, and another day's when selected",
      (tester) async {
    await pumpPage(tester);

    expect(find.text('March 2026'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
    expect(find.text('Call the bank'), findsNothing);
    expect(find.text('Someday'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-3-12')));
    await tester.pumpAndSettle();

    expect(find.text('Call the bank'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    expect(find.text('Dentist'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-3-11')));
    await tester.pumpAndSettle();
    expect(find.text('Nothing planned on this day.'), findsOneWidget);
  });

  testWidgets('moves between months and back to today', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
  });

  testWidgets('is translated into French', (tester) async {
    await pumpPage(tester, locale: const Locale('fr'));

    expect(find.text('Calendrier'), findsOneWidget);
    expect(find.text('Mars 2026'), findsOneWidget);
    expect(find.byTooltip('Mois suivant'), findsOneWidget);
  });

  testWidgets('shows the month and the day side by side on wide screens',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpPage(tester);

    final month = tester.getCenter(find.text('March 2026'));
    final task = tester.getCenter(find.text('Dentist'));
    expect(task.dx, greaterThan(month.dx));
    expect(tester.takeException(), isNull);
  });
}
