import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';
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
}
