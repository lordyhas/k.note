import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/settings/bloc/profile_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _user = User(
    id: 'uid-1',
    email: 'me@example.com',
    name: null,
    photoMail: null,
    isCheckMail: true);

void main() {
  late AuthRepository authRepository;
  late FakeFirebaseFirestore firestore;
  late List<User> updated;

  setUp(() {
    authRepository = MockAuthRepository();
    firestore = FakeFirebaseFirestore();
    updated = [];
  });

  ProfileCubit build() => ProfileCubit(
        authRepository,
        user: _user,
        onUserUpdated: updated.add,
        firestore: (user) => FirestoreService.user(user, firestore),
      );

  test('starts with the current name; an empty name cannot be saved', () {
    final cubit = build();
    expect(cubit.state.name, '');
    expect(cubit.state.canSave, isFalse);
    cubit.nameChanged('   ');
    expect(cubit.state.canSave, isFalse);
    cubit.nameChanged('x' * 101);
    expect(cubit.state.isNameValid, isFalse);
    cubit.close();
  });

  blocTest<ProfileCubit, ProfileState>(
    'saves the trimmed name, updates the session and the profile document',
    setUp: () => when(() => authRepository.updateDisplayName(any()))
        .thenAnswer((_) async => _user.copyWith(name: 'Hassan Kajila')),
    build: build,
    act: (cubit) async {
      cubit.nameChanged('  Hassan Kajila ');
      await cubit.save();
    },
    expect: () => const [
      ProfileState(savedName: '', name: '  Hassan Kajila '),
      ProfileState(
          savedName: '',
          name: '  Hassan Kajila ',
          status: ProfileStatus.saving),
      ProfileState(
          savedName: 'Hassan Kajila',
          name: 'Hassan Kajila',
          status: ProfileStatus.saved),
    ],
    verify: (cubit) async {
      verify(() => authRepository.updateDisplayName('Hassan Kajila')).called(1);
      expect(updated.single.name, 'Hassan Kajila');
      await pumpEventQueue();
      final profile =
          (await firestore.collection('users').doc('uid-1').get()).data();
      expect(profile?['name'], 'Hassan Kajila');
      expect(cubit.state.canSave, isFalse);
    },
  );

  blocTest<ProfileCubit, ProfileState>(
    'reports why it failed and keeps the name typed',
    setUp: () => when(() => authRepository.updateDisplayName(any()))
        .thenThrow(ProfileUpdateFailure.fromCode('network-request-failed')),
    build: build,
    act: (cubit) async {
      cubit.nameChanged('Hassan');
      await cubit.save();
    },
    skip: 2,
    expect: () => const [
      ProfileState(
        savedName: '',
        name: 'Hassan',
        status: ProfileStatus.failure,
        error: AuthError.network,
      ),
    ],
    verify: (_) => expect(updated, isEmpty),
  );
}
