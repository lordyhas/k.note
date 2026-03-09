import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:knote/data/app_bloc/login_bloc/login_models.dart';
import 'package:knote/data/app_bloc/signup_bloc/sign_up_cubit.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('SignUpCubit', () {
    test('initial state is correct', () {
      expect(SignUpCubit(authRepository).state, const SignUpState());
    });

    group('emailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email is invalid',
        build: () => SignUpCubit(authRepository),
        act: (cubit) => cubit.emailChanged('invalid'),
        expect: () => const [
          SignUpState(email: Email.dirty('invalid'), isValid: false),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email is valid and other fields are valid',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          password: Password.dirty('password1'),
          confirmedPassword: ConfirmedPassword.dirty(
            password: 'password1',
            value: 'password1',
          ),
        ),
        act: (cubit) => cubit.emailChanged('test@example.com'),
        expect: () => const [
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when password is invalid',
        build: () => SignUpCubit(authRepository),
        act: (cubit) => cubit.passwordChanged('weak'),
        expect: () => [
          isA<SignUpState>()
              .having((s) => s.password.value, 'password value', 'weak')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when password is valid and other fields are valid',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          email: Email.dirty('test@example.com'),
          confirmedPassword: ConfirmedPassword.dirty(
            password: '',
            value: 'password1',
          ),
        ),
        act: (cubit) => cubit.passwordChanged('password1'),
        expect: () => [
          isA<SignUpState>()
              .having((s) => s.password.value, 'password value', 'password1')
              .having(
                (s) => s.confirmedPassword.password,
                'confirmed password matches',
                'password1',
              ),
        ],
      );
    });

    group('confirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when confirmed password does not match',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          password: Password.dirty('password1'),
        ),
        act: (cubit) => cubit.confirmedPasswordChanged('different'),
        expect: () => [
          isA<SignUpState>()
              .having(
                (s) => s.confirmedPassword.value,
                'confirmed value',
                'different',
              )
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when confirmed password matches and all fields valid',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password1'),
        ),
        act: (cubit) => cubit.confirmedPasswordChanged('password1'),
        expect: () => const [
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
          ),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      setUp(() {
        when(
          () => authRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
      });

      blocTest<SignUpCubit, SignUpState>(
        'does nothing when state is not valid',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(isValid: false),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[],
        verify: (_) {
          verifyNever(
            () => authRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          );
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, success] when sign up succeeds',
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password1'),
          confirmedPassword: ConfirmedPassword.dirty(
            password: 'password1',
            value: 'password1',
          ),
          isValid: true,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const [
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            status: FormzSubmissionStatus.success,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, failure] when sign up throws '
        'SignUpWithEmailAndPasswordFailure',
        setUp: () {
          when(
            () => authRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const SignUpWithEmailAndPasswordFailure('Sign up failed'),
          );
        },
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password1'),
          confirmedPassword: ConfirmedPassword.dirty(
            password: 'password1',
            value: 'password1',
          ),
          isValid: true,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const [
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            errorMessage: 'Sign up failed',
            status: FormzSubmissionStatus.failure,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, failure] when sign up throws generic exception',
        setUp: () {
          when(
            () => authRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('unexpected'));
        },
        build: () => SignUpCubit(authRepository),
        seed: () => const SignUpState(
          email: Email.dirty('test@example.com'),
          password: Password.dirty('password1'),
          confirmedPassword: ConfirmedPassword.dirty(
            password: 'password1',
            value: 'password1',
          ),
          isValid: true,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const [
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          SignUpState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password1'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password1',
              value: 'password1',
            ),
            isValid: true,
            status: FormzSubmissionStatus.failure,
          ),
        ],
      );
    });
  });
}
