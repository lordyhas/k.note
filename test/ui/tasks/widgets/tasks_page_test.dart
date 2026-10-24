import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';
import 'package:knote/utils/save_in_background.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

void main() {
  late FirestoreService manager;

  setUp(() async {
    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
    await manager.addTaskInCloud(
        task: CheckList(id: 't1', title: 'Buy milk', list: const []));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
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
}
