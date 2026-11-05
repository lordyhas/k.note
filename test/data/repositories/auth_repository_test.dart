import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/domain/models/user.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

/// A signed-in Firebase user whose email is [verified] or not.
MockFirebaseUser firebaseUser({required bool verified}) {
  final user = MockFirebaseUser();
  final metadata = MockUserMetadata();
  when(() => user.uid).thenReturn('uid-1');
  when(() => user.email).thenReturn('new@example.com');
  when(() => user.emailVerified).thenReturn(verified);
  when(() => user.isAnonymous).thenReturn(false);
  when(() => user.metadata).thenReturn(metadata);
  when(() => user.reload()).thenAnswer((_) async {});
  when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');
  when(() => user.sendEmailVerification()).thenAnswer((_) async {});
  return user;
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late StreamController<firebase_auth.User?> authStateController;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    authStateController = StreamController<firebase_auth.User?>.broadcast();

    when(() => mockFirebaseAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
  });

  tearDown(() => authStateController.close());

  AuthRepository buildRepo() => AuthRepository(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

  group('AuthRepository - user stream', () {
    test('emits User.empty when auth state emits null', () async {
      final repo = buildRepo();
      final userFuture = repo.user.first;
      authStateController.add(null);

      expect(await userFuture, User.empty);
    });

    test('caches user so currentUser reflects latest emitted user', () async {
      final repo = buildRepo();
      final userFuture = repo.user.first;
      authStateController.add(null);

      await userFuture;

      expect(repo.currentUser, User.empty);
    });
  });

  group('AuthRepository - currentUser', () {
    test('returns User.empty when nothing is cached', () {
      expect(buildRepo().currentUser, User.empty);
    });
  });

  group('AuthRepository - logInWithEmailAndPassword', () {
    test('completes without error on success', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await expectLater(
        buildRepo().logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        completes,
      );
    });

    test('throws LogInWithEmailAndPasswordFailure on FirebaseAuthException',
        () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'wrong-password'),
      );

      await expectLater(
        buildRepo().logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsA(isA<LogInWithEmailAndPasswordFailure>()),
      );
    });

    test('thrown failure has the correct message for wrong-password', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'wrong-password'),
      );

      try {
        await buildRepo().logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrong',
        );
        fail('Expected LogInWithEmailAndPasswordFailure');
      } on LogInWithEmailAndPasswordFailure catch (e) {
        expect(e.message, 'Incorrect password, please try again.');
      }
    });

    test('throws LogInWithEmailAndPasswordFailure on unknown exception',
        () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('network error'));

      await expectLater(
        buildRepo().logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
        throwsA(isA<LogInWithEmailAndPasswordFailure>()),
      );
    });
  });

  group('AuthRepository - signUp', () {
    test('completes without error on success', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await expectLater(
        buildRepo().signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
        completes,
      );
    });

    test('throws SignUpWithEmailAndPasswordFailure on FirebaseAuthException',
        () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'network-request-failed'),
      );

      await expectLater(
        buildRepo().signUp(email: 'new@example.com', password: 'password123'),
        throwsA(
          isA<SignUpWithEmailAndPasswordFailure>()
              .having((e) => e.message, 'message', kNetworkErrorMessage),
        ),
      );
    });

    test('sends the verification email to the new account', () async {
      final user = firebaseUser(verified: false);
      final credential = MockUserCredential();
      when(() => credential.user).thenReturn(user);
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      await buildRepo()
          .signUp(email: 'new@example.com', password: 'password123');

      verify(() => user.sendEmailVerification()).called(1);
    });

    test('still succeeds when the verification email cannot be sent', () async {
      final user = firebaseUser(verified: false);
      when(() => user.sendEmailVerification()).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'network-request-failed'),
      );
      final credential = MockUserCredential();
      when(() => credential.user).thenReturn(user);
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      await expectLater(
        buildRepo().signUp(email: 'new@example.com', password: 'password123'),
        completes,
      );
    });
  });

  group('AuthRepository - sendEmailVerification', () {
    test('sends the email to the signed-in user', () async {
      final user = firebaseUser(verified: false);
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await buildRepo().sendEmailVerification();

      verify(() => user.sendEmailVerification()).called(1);
    });

    test('reports too many requests', () async {
      final user = firebaseUser(verified: false);
      when(() => user.sendEmailVerification()).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'too-many-requests'),
      );
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await expectLater(
        buildRepo().sendEmailVerification(),
        throwsA(isA<EmailVerificationFailure>()
            .having((e) => e.error, 'error', AuthError.tooManyRequests)),
      );
    });
  });

  group('AuthRepository - reloadUser', () {
    test('returns User.empty when nobody is signed in', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      expect(await buildRepo().reloadUser(), User.empty);
    });

    test('returns a still unverified user without refreshing the token',
        () async {
      final user = firebaseUser(verified: false);
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      final reloaded = await buildRepo().reloadUser();

      expect(reloaded.needsEmailVerification, isTrue);
      verify(() => user.reload()).called(1);
      verifyNever(() => user.getIdToken(true));
    });

    test('refreshes the token once the email is verified', () async {
      final user = firebaseUser(verified: true);
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);
      final repo = buildRepo();

      final reloaded = await repo.reloadUser();

      expect(reloaded.needsEmailVerification, isFalse);
      expect(repo.currentUser, reloaded);
      verify(() => user.getIdToken(true)).called(1);
    });

    test('reports a network error', () async {
      final user = firebaseUser(verified: false);
      when(() => user.reload()).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'network-request-failed'),
      );
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await expectLater(
        buildRepo().reloadUser(),
        throwsA(isA<EmailVerificationFailure>()
            .having((e) => e.error, 'error', AuthError.network)),
      );
    });
  });

  group('AuthRepository - logInWithGoogle', () {
    test('throws a canceled failure when the account picker is dismissed',
        () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      await expectLater(
        (buildRepo()..isWeb = false).logInWithGoogle(),
        throwsA(isA<LogInWithGoogleFailure>()
            .having((e) => e.isCanceled, 'isCanceled', true)),
      );
    });

    test('reports a network error when Google Sign-In is offline', () async {
      when(() => mockGoogleSignIn.signIn()).thenThrow(
        PlatformException(code: GoogleSignIn.kNetworkError),
      );

      await expectLater(
        (buildRepo()..isWeb = false).logInWithGoogle(),
        throwsA(isA<LogInWithGoogleFailure>()
            .having((e) => e.message, 'message', kNetworkErrorMessage)),
      );
    });
  });

  group('AuthRepository - logOut', () {
    test('calls signOut on both firebase and google', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await buildRepo().logOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('throws LogOutFailure on exception', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('sign out failed'));

      await expectLater(
        buildRepo().logOut(),
        throwsA(isA<LogOutFailure>()),
      );
    });
  });

  group('LogInWithEmailAndPasswordFailure.fromCode', () {
    test('invalid-email', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('invalid-email').message,
        'Email is not valid or badly formatted.',
      );
    });

    test('user-disabled', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('user-disabled').message,
        'This user has been disabled. Please contact support for help.',
      );
    });

    test('user-not-found', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('user-not-found').message,
        'Email is not found, please create an account.',
      );
    });

    test('wrong-password', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('wrong-password').message,
        'Incorrect password, please try again.',
      );
    });

    test('network-request-failed', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('network-request-failed')
            .message,
        kNetworkErrorMessage,
      );
    });

    test('invalid-credential', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('invalid-credential').message,
        'Incorrect email or password, please try again.',
      );
    });

    test('unknown code returns default message', () {
      expect(
        LogInWithEmailAndPasswordFailure.fromCode('unknown-code').message,
        'An unknown exception occurred.',
      );
    });
  });

  group('SignUpWithEmailAndPasswordFailure.fromCode', () {
    test('invalid-email', () {
      expect(
        SignUpWithEmailAndPasswordFailure.fromCode('invalid-email').message,
        'Email is not valid or badly formatted.',
      );
    });

    test('email-already-in-use', () {
      expect(
        SignUpWithEmailAndPasswordFailure.fromCode('email-already-in-use')
            .message,
        'An account already exists for that email.',
      );
    });

    test('operation-not-allowed', () {
      expect(
        SignUpWithEmailAndPasswordFailure.fromCode('operation-not-allowed')
            .message,
        'Operation is not allowed.  Please contact support.',
      );
    });

    test('weak-password', () {
      expect(
        SignUpWithEmailAndPasswordFailure.fromCode('weak-password').message,
        'Please enter a stronger password.',
      );
    });

    test('unknown code', () {
      expect(
        SignUpWithEmailAndPasswordFailure.fromCode('unknown').message,
        'An unknown exception occurred.',
      );
    });
  });

  group('LogInWithGoogleFailure.fromCode', () {
    test('account-exists-with-different-credential', () {
      expect(
        LogInWithGoogleFailure.fromCode(
                'account-exists-with-different-credential')
            .message,
        'Account exists with different credentials.',
      );
    });

    test('invalid-credential', () {
      expect(
        LogInWithGoogleFailure.fromCode('invalid-credential').message,
        'The credential received is malformed or has expired.',
      );
    });

    test('user-disabled', () {
      expect(
        LogInWithGoogleFailure.fromCode('user-disabled').message,
        'This user has been disabled. Please contact support for help.',
      );
    });

    test('wrong-password', () {
      expect(
        LogInWithGoogleFailure.fromCode('wrong-password').message,
        'Incorrect password, please try again.',
      );
    });

    test('invalid-verification-code', () {
      expect(
        LogInWithGoogleFailure.fromCode('invalid-verification-code').message,
        'The credential verification code received is invalid.',
      );
    });

    test('unknown code', () {
      expect(
        LogInWithGoogleFailure.fromCode('unknown').message,
        'An unknown exception occurred.',
      );
    });

    test('network-request-failed', () {
      expect(
        LogInWithGoogleFailure.fromCode('network-request-failed').message,
        kNetworkErrorMessage,
      );
    });
  });

  group('LogInWithGoogleFailure.fromPlatformException', () {
    test('sign_in_canceled is a cancellation', () {
      final failure = LogInWithGoogleFailure.fromPlatformException(
        PlatformException(code: GoogleSignIn.kSignInCanceledError),
      );
      expect(failure.isCanceled, isTrue);
    });

    test('ApiException 7 is a network error', () {
      expect(
        LogInWithGoogleFailure.fromPlatformException(
          PlatformException(
            code: 'sign_in_failed',
            message: 'com.google.android.gms.common.api.ApiException: 7: ',
          ),
        ).message,
        kNetworkErrorMessage,
      );
    });

    test('ApiException 10 points at the SHA configuration', () {
      expect(
        LogInWithGoogleFailure.fromPlatformException(
          PlatformException(
            code: 'sign_in_failed',
            message: 'com.google.android.gms.common.api.ApiException: 10: ',
          ),
        ).message,
        contains('SHA'),
      );
    });

    test('other errors fall back to the default message', () {
      final failure = LogInWithGoogleFailure.fromPlatformException(
        PlatformException(code: 'sign_in_failed'),
      );
      expect(failure.message, 'An unknown exception occurred.');
      expect(failure.isCanceled, isFalse);
    });
  });
}
