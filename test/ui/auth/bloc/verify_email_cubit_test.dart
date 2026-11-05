import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/verify_email_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _unverified = User(
  id: 'uid-1',
  email: 'new@example.com',
  name: null,
  photoMail: null,
  isCheckMail: false,
);

void main() {
  late AuthRepository authRepository;
  late List<User> reloadedUsers;

  setUp(() {
    authRepository = MockAuthRepository();
    reloadedUsers = [];
  });

  VerifyEmailCubit build() =>
      VerifyEmailCubit(authRepository, onUserReloaded: reloadedUsers.add);

  group('resend', () {
    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'reports that the email was sent',
      setUp: () => when(() => authRepository.sendEmailVerification())
          .thenAnswer((_) async {}),
      build: build,
      act: (cubit) => cubit.resend(),
      expect: () => const [
        VerifyEmailState(status: VerifyEmailStatus.sending),
        VerifyEmailState(status: VerifyEmailStatus.sent),
      ],
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'reports why it failed',
      setUp: () => when(() => authRepository.sendEmailVerification())
          .thenThrow(EmailVerificationFailure.fromCode('too-many-requests')),
      build: build,
      act: (cubit) => cubit.resend(),
      expect: () => const [
        VerifyEmailState(status: VerifyEmailStatus.sending),
        VerifyEmailState(
          status: VerifyEmailStatus.failure,
          error: AuthError.tooManyRequests,
        ),
      ],
    );
  });

  group('checkVerified', () {
    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'hands the verified user over to the session',
      setUp: () => when(() => authRepository.reloadUser())
          .thenAnswer((_) async => _unverified.copyWith(isCheckMail: true)),
      build: build,
      act: (cubit) => cubit.checkVerified(),
      expect: () => const [
        VerifyEmailState(status: VerifyEmailStatus.checking),
      ],
      verify: (_) =>
          expect(reloadedUsers, [_unverified.copyWith(isCheckMail: true)]),
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'says the email is not verified yet',
      setUp: () => when(() => authRepository.reloadUser())
          .thenAnswer((_) async => _unverified),
      build: build,
      act: (cubit) => cubit.checkVerified(),
      expect: () => const [
        VerifyEmailState(status: VerifyEmailStatus.checking),
        VerifyEmailState(status: VerifyEmailStatus.notVerifiedYet),
      ],
      verify: (_) => expect(reloadedUsers, isEmpty),
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'a silent check reports nothing while offline',
      setUp: () => when(() => authRepository.reloadUser()).thenThrow(
          EmailVerificationFailure.fromCode('network-request-failed')),
      build: build,
      act: (cubit) => cubit.checkVerified(silent: true),
      expect: () => const <VerifyEmailState>[],
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'a silent check still hands over a verified user',
      setUp: () => when(() => authRepository.reloadUser())
          .thenAnswer((_) async => _unverified.copyWith(isCheckMail: true)),
      build: build,
      act: (cubit) => cubit.checkVerified(silent: true),
      expect: () => const <VerifyEmailState>[],
      verify: (_) => expect(reloadedUsers, hasLength(1)),
    );
  });
}
