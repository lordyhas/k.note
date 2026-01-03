import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:knote/data/app_bloc/login_bloc/login_cubit.dart';
import 'package:knote/data/app_bloc/login_bloc/login_models.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:mocktail/mocktail.dart';

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
    });
  });
}
