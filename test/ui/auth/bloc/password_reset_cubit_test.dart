import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/login_models.dart';
import 'package:knote/ui/auth/bloc/password_reset_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;

  setUp(() => authRepository = MockAuthRepository());

  const email = Email.dirty('me@example.com');

  test('starts with the prefilled email', () {
    expect(
      PasswordResetCubit(authRepository, email: ' me@example.com ').state,
      const PasswordResetState(email: email),
    );
  });

  blocTest<PasswordResetCubit, PasswordResetState>(
    'sends the link',
    setUp: () => when(() =>
            authRepository.sendPasswordResetEmail(email: any(named: 'email')))
        .thenAnswer((_) async {}),
    build: () => PasswordResetCubit(authRepository),
    act: (cubit) => cubit
      ..emailChanged('me@example.com')
      ..send(),
    expect: () => const [
      PasswordResetState(email: email),
      PasswordResetState(email: email, status: PasswordResetStatus.sending),
      PasswordResetState(email: email, status: PasswordResetStatus.sent),
    ],
    verify: (_) => verify(() =>
            authRepository.sendPasswordResetEmail(email: 'me@example.com'))
        .called(1),
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'does nothing for an invalid email',
    build: () => PasswordResetCubit(authRepository, email: 'nope'),
    act: (cubit) => cubit.send(),
    expect: () => const <PasswordResetState>[],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'reports why it failed',
    setUp: () => when(() =>
            authRepository.sendPasswordResetEmail(email: any(named: 'email')))
        .thenThrow(PasswordResetFailure.fromCode('too-many-requests')),
    build: () => PasswordResetCubit(authRepository, email: 'me@example.com'),
    act: (cubit) => cubit.send(),
    expect: () => const [
      PasswordResetState(email: email, status: PasswordResetStatus.sending),
      PasswordResetState(
        email: email,
        status: PasswordResetStatus.failure,
        error: AuthError.tooManyRequests,
      ),
    ],
  );
}
