import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';
import 'package:knote/utils/save_in_background.dart';

import '../../../helpers/localized_app.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

void main() {
  late FirestoreService manager;

  setUp(() async {
    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
    await manager.addTaskInCloud(
        task: CheckList(id: 't1', title: 'Buy milk', list: const []));
  });

  Future<void> pumpPage(WidgetTester tester,
      {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(localizedApp(
      locale: locale,
      scaffoldMessengerKey: appMessengerKey,
      home: TasksPage(firebaseManager: manager),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a swiped task can be restored with Undo', (tester) async {
    await pumpPage(tester);

    await tester.drag(find.text('Buy milk'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsNothing);
    expect(await manager.getTasksInCloud(), isEmpty);
    expect(find.text('"Buy milk" deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);
    expect((await manager.getTasksInCloud()).single.title, 'Buy milk');
  });

  testWidgets('follows the device language', (tester) async {
    final today = DateTime.now();
    await manager.addTaskInCloud(
        task: CheckList(
            id: 't2',
            title: 'Call mom',
            list: const [],
            dueDate: DateTime(today.year, today.month, today.day)));
    await pumpPage(tester, locale: const Locale('fr'));

    expect(find.text('Tâches'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text("Aujourd'hui"), findsOneWidget);
    expect(find.byTooltip('Nouvelle tâche'), findsOneWidget);
  });

  testWidgets('the completion circle is a labelled 48 dp target',
      (tester) async {
    await pumpPage(tester);

    final circle = find.bySemanticsLabel('Mark as completed');
    expect(circle, findsOneWidget);
    expect(tester.getSize(circle).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(circle).height, greaterThanOrEqualTo(48));

    await tester.tap(circle);
    await tester.pumpAndSettle();

    expect((await manager.getTasksInCloud()).single.isAllChecked, isTrue);
    await tester.tap(find.text('Completed 1')); // the section starts collapsed
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Mark as not completed'), findsOneWidget);
  });

  testWidgets('completing a repeating task adds its next occurrence',
      (tester) async {
    await manager.deleteTask(taskId: 't1');
    await manager.addTaskInCloud(
        task: CheckList(
            id: 't1',
            title: 'Water the plants',
            list: const [],
            dueDate: DateTime(2026, 3, 2),
            repeat: 'Weekly'));
    await pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('Mark as completed'));
    await tester.pumpAndSettle();

    final tasks = await manager.getTasksInCloud();
    expect(tasks, hasLength(2));
    final done = tasks.singleWhere((task) => task.id == 't1');
    final next = tasks.singleWhere((task) => task.id != 't1');
    expect(done.isAllChecked, isTrue);
    expect(next.isAllChecked, isFalse);
    expect(next.dueDate, DateTime(2026, 3, 9));
    expect(next.repeat, 'Weekly');
  });

  testWidgets('active tasks are sorted by due date, undated ones last',
      (tester) async {
    // 'Buy milk' (t1) has no due date and no creation time.
    final tasks = [
      CheckList(
          id: 'a',
          title: 'Undated, old',
          list: const [],
          creationTime: DateTime(2026, 1, 1)),
      CheckList(
          id: 'b',
          title: 'Due later',
          list: const [],
          dueDate: DateTime(2026, 5, 1),
          creationTime: DateTime(2026, 1, 1)),
      CheckList(
          id: 'c',
          title: 'Due soon, new',
          list: const [],
          dueDate: DateTime(2026, 4, 1),
          creationTime: DateTime(2026, 2, 1)),
      CheckList(
          id: 'd',
          title: 'Due soon, old',
          list: const [],
          dueDate: DateTime(2026, 4, 1),
          creationTime: DateTime(2026, 1, 1)),
      CheckList(
          id: 'e',
          title: 'Undated, new',
          list: const [],
          creationTime: DateTime(2026, 3, 1)),
    ];
    for (final task in tasks) {
      await manager.addTaskInCloud(task: task);
    }
    await pumpPage(tester);

    final order = [
      'Due soon, old',
      'Due soon, new',
      'Due later',
      'Undated, old',
      'Undated, new',
      'Buy milk',
    ];
    final tops = [
      for (final title in order) tester.getTopLeft(find.text(title)).dy
    ];
    expect(tops, orderedEquals([...tops]..sort()));
  });

  testWidgets('completed tasks show the last completed first', (tester) async {
    await manager.deleteTask(taskId: 't1');
    for (final (id, day) in [('old', 1), ('new', 3), ('mid', 2)]) {
      await manager.addTaskInCloud(
          task: CheckList(
              id: id,
              title: 'Done $id',
              list: const [],
              isAllChecked: true,
              modificationTime: DateTime(2026, 1, day)));
    }
    await pumpPage(tester);
    await tester.tap(find.text('Completed 3'));
    await tester.pumpAndSettle();

    final tops = [
      for (final id in ['new', 'mid', 'old'])
        tester.getTopLeft(find.text('Done $id')).dy
    ];
    expect(tops, orderedEquals([...tops]..sort()));
  });

  testWidgets('due dates are red when late and highlighted today',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await manager.addTaskInCloud(
        task: CheckList(
            id: 'late',
            title: 'Late',
            list: const [],
            dueDate: today.subtract(const Duration(days: 3))));
    await manager.addTaskInCloud(
        task: CheckList(
            id: 'today', title: 'Today task', list: const [], dueDate: today));
    await manager.addTaskInCloud(
        task: CheckList(
            id: 'later',
            title: 'Later',
            list: const [],
            dueDate: DateTime(now.year + 1, 1, 1)));
    await pumpPage(tester);

    final colors = AppColors.of(tester.element(find.text('Late')));
    Color? dueColor(String title) {
      final card =
          find.ancestor(of: find.text(title), matching: find.byType(Card));
      final date = find.descendant(
          of: find.descendant(of: card, matching: find.byType(Row)),
          matching: find.byType(Text));
      return tester.widget<Text>(date.last).style?.color;
    }

    expect(dueColor('Late'), colors.danger);
    expect(dueColor('Today task'), colors.link);
    expect(dueColor('Later'), isNot(anyOf(colors.danger, colors.link)));
  });
}
