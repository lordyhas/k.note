import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/utils/save_in_background.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late FirestoreService manager;
  late AuthenticationBloc authBloc;

  setUp(() async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.currentUser).thenReturn(_user);
    when(() => authRepository.user).thenAnswer((_) => const Stream.empty());
    authBloc = AuthenticationBloc(authRepository: authRepository);

    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
    await manager.addNoteInCloud(
        note: NoteModel(id: 'n1', title: 'Été à Paris', text: 'Le Louvre'));
    await manager.addNoteInCloud(
        note: NoteModel(id: 'n2', title: 'Groceries', text: 'Milk'));
  });

  tearDown(() => authBloc.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        scaffoldMessengerKey: appMessengerKey,
        home: NotesPage(firebaseManager: manager),
      ),
    ));
    await tester.pump(); // first snapshot
    await tester.pump(const Duration(seconds: 1)); // cards fade in
  }

  Finder searchField() => find.byKey(const Key('homePage_search_textField'));

  testWidgets('filters notes while typing, ignoring accents',
      (tester) async {
    await pumpPage(tester);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.enterText(searchField(), 'ete');
    await tester.pump();

    expect(find.text('Été à Paris'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
  });

  testWidgets('says when nothing matches, and clears the search',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(searchField(), 'zzz');
    await tester.pump();
    expect(find.text('No notes match "zzz"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('homePage_search_clear')));
    await tester.pump();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Été à Paris'), findsOneWidget);
  });

  testWidgets('back clears the search before leaving', (tester) async {
    await pumpPage(tester);

    await tester.enterText(searchField(), 'milk');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Été à Paris'), findsOneWidget);
    expect(find.byType(NotesPage), findsOneWidget);
  });

  testWidgets('a note moved to the bin can be restored with Undo',
      (tester) async {
    await pumpPage(tester);

    // The card's InkWell is stacked over its text and takes the gesture.
    await tester.longPress(find.text('Groceries'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to bin'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsNothing);
    expect(find.text('"Groceries" moved to the bin'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(await manager.getAllDeletedNoteInCloud(), isEmpty);
  });
}
