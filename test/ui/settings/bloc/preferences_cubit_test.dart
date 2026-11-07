import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/ui/settings/bloc/preferences_cubit.dart';

const _alice = User(
    id: 'alice',
    email: 'alice@example.com',
    name: 'Alice',
    photoMail: null,
    isCheckMail: true);
const _bob = User(
    id: 'bob',
    email: 'bob@example.com',
    name: 'Bob',
    photoMail: null,
    isCheckMail: true);

void main() {
  late FakeFirebaseFirestore firestore;
  late StreamController<User> users;
  late PreferencesCubit cubit;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    users = StreamController<User>();
    cubit = PreferencesCubit(
      users: users.stream,
      firestore: (user) => FirestoreService.user(user, firestore),
    );
  });

  tearDown(() async {
    await cubit.close();
    await users.close();
  });

  const french = UserPreferences(language: AppLanguage.fr);

  test('signed-out users get the defaults', () async {
    users.add(User.empty);
    await pumpEventQueue();
    expect(cubit.state, UserPreferences.defaults);
  });

  test("follows the signed-in user's stored preferences", () async {
    await FirestoreService.user(_alice, firestore).savePreferences(french);

    users.add(_alice);
    await pumpEventQueue();
    expect(cubit.state, french);

    // Changed on another device.
    await FirestoreService.user(_alice, firestore)
        .savePreferences(french.copyWith(notesLayout: NotesLayout.grid));
    await pumpEventQueue();
    expect(cubit.state.notesLayout, NotesLayout.grid);
  });

  test('update shows the new preferences at once and saves them', () async {
    users.add(_alice);
    await pumpEventQueue();

    final saved = cubit.update(french);
    expect(cubit.state, french);
    await saved;

    final stored =
        await FirestoreService.user(_alice, firestore).watchPreferences().first;
    expect(stored, french);
  });

  test("switching account shows the other account's preferences", () async {
    await FirestoreService.user(_alice, firestore).savePreferences(french);
    users.add(_alice);
    await pumpEventQueue();
    expect(cubit.state, french);

    users.add(_bob);
    await pumpEventQueue();
    expect(cubit.state, UserPreferences.defaults);

    users.add(User.empty);
    await pumpEventQueue();
    expect(cubit.state, UserPreferences.defaults);
  });

  test('users who must verify their email are not read', () async {
    users.add(_alice.copyWith(isCheckMail: false));
    await pumpEventQueue();
    expect(cubit.state, UserPreferences.defaults);
    // Nothing to save to while signed out or unverified.
    await cubit.update(french);
    expect((await firestore.collectionGroup('settings').get()).docs, isEmpty);
  });
}
