import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/bloc/login_models.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('LoginCubit', () {
    test('initial state is correct', () {
      expect(LoginCubit(authRepository).state, const LoginState());
    });

    group('emailChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits [invalid] when email is invalid',
        build: () => LoginCubit(authRepository),
        act: (cubit) => cubit.emailChanged('invalid'),
        expect: () => const [
          LoginState(email: Email.dirty('invalid'), isValid: false),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [valid] when email is valid and password is valid',
        build: () => LoginCubit(authRepository),
        seed: () => const LoginState(password: Password.dirty('password123')),
        act: (cubit) => cubit.emailChanged('test@example.com'),
        expect: () => const [
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits [valid] when password is valid and email is valid',
        build: () => LoginCubit(authRepository),
        seed: () => const LoginState(email: Email.dirty('test@example.com')),
        act: (cubit) => cubit.passwordChanged('password123'),
        expect: () => const [
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
          ),
        ],
      );
    });

    group('logInWithCredentials', () {
      setUp(() {
        when(() => authRepository.logInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});
      });

      blocTest<LoginCubit, LoginState>(
        'emits [submissionInProgress, submissionSuccess] when login succeeds',
        build: () => LoginCubit(authRepository),
        seed: () => const LoginState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password123'),
          isValid: true,
        ),
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => const [
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
            status: FormzSubmissionStatus.success,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [submissionInProgress, submissionFailure] when login fails',
        setUp: () {
          when(() => authRepository.logInWithEmailAndPassword(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('oops'));
        },
        build: () => LoginCubit(authRepository),
        seed: () => const LoginState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password123'),
          isValid: true,
        ),
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => const [
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
            status: FormzSubmissionStatus.failure,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'exposes the repository error message on failure',
        setUp: () {
          when(() => authRepository.logInWithEmailAndPassword(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(
            const LogInWithEmailAndPasswordFailure(kNetworkErrorMessage),
          );
        },
        build: () => LoginCubit(authRepository),
        seed: () => const LoginState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password123'),
          isValid: true,
        ),
        act: (cubit) => cubit.logInWithCredentials(),
        skip: 1,
        expect: () => const [
          LoginState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
            status: FormzSubmissionStatus.failure,
            errorMessage: kNetworkErrorMessage,
          ),
        ],
      );
    });

    group('logInWithGoogle', () {
      blocTest<LoginCubit, LoginState>(
        'returns to initial without an error when the user cancels',
        setUp: () {
          when(() => authRepository.logInWithGoogle())
              .thenThrow(const LogInWithGoogleFailure.canceled());
        },
        build: () => LoginCubit(authRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => const [
          LoginState(status: FormzSubmissionStatus.inProgress),
          LoginState(status: FormzSubmissionStatus.initial),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits failure with the network message when offline',
        setUp: () {
          when(() => authRepository.logInWithGoogle())
              .thenThrow(const LogInWithGoogleFailure(kNetworkErrorMessage));
        },
        build: () => LoginCubit(authRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => const [
          LoginState(status: FormzSubmissionStatus.inProgress),
          LoginState(
            status: FormzSubmissionStatus.failure,
            errorMessage: kNetworkErrorMessage,
          ),
        ],
      );
    });
  });
}
