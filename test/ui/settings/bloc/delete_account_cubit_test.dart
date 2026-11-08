import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/ui/settings/bloc/delete_account_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late AuthRepository authRepository;
  late FirestoreService firestoreService;
  late List<String> calls;

  setUp(() {
    authRepository = MockAuthRepository();
    firestoreService = MockFirestoreService();
    calls = [];
    when(() => authRepository.reauthenticate(password: any(named: 'password')))
        .thenAnswer((_) async => calls.add('reauthenticate'));
    when(() => firestoreService.deleteAllUserData())
        .thenAnswer((_) async => calls.add('deleteData'));
    when(() => authRepository.deleteAccount())
        .thenAnswer((_) async => calls.add('deleteAccount'));
  });

  DeleteAccountCubit build() => DeleteAccountCubit(
        authRepository,
        firestoreService,
        beforeAccountDeleted: () async => calls.add('cleanUp'),
      );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'confirms the identity, then deletes the data, then the account',
    build: build,
    act: (cubit) => cubit.deleteAccount(password: 'secret'),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.inProgress),
      DeleteAccountState(status: DeleteAccountStatus.deleted),
    ],
    verify: (_) {
      expect(
          calls, ['reauthenticate', 'deleteData', 'cleanUp', 'deleteAccount']);
      verify(() => authRepository.reauthenticate(password: 'secret')).called(1);
    },
  );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'keeps everything when the password is wrong',
    setUp: () => when(() =>
            authRepository.reauthenticate(password: any(named: 'password')))
        .thenThrow(DeleteAccountFailure.fromCode('wrong-password')),
    build: build,
    act: (cubit) => cubit.deleteAccount(password: 'wrong'),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.inProgress),
      DeleteAccountState(
        status: DeleteAccountStatus.failure,
        error: AuthError.wrongPassword,
      ),
    ],
    verify: (_) => expect(calls, isEmpty),
  );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'goes back to the start when the Google picker is dismissed',
    setUp: () => when(() =>
            authRepository.reauthenticate(password: any(named: 'password')))
        .thenThrow(const DeleteAccountFailure.canceled()),
    build: build,
    act: (cubit) => cubit.deleteAccount(),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.inProgress),
      DeleteAccountState(),
    ],
  );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'does not delete the account when the data could not be deleted',
    setUp: () => when(() => firestoreService.deleteAllUserData())
        .thenThrow(Exception('offline')),
    build: build,
    act: (cubit) => cubit.deleteAccount(password: 'secret'),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.inProgress),
      DeleteAccountState(
        status: DeleteAccountStatus.failure,
        error: AuthError.unknown,
      ),
    ],
    verify: (_) => verifyNever(() => authRepository.deleteAccount()),
  );
}
