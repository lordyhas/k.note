import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

class MockUserInfo extends Mock implements firebase_auth.UserInfo {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

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
  setUpAll(() => registerFallbackValue(FakeAuthCredential()));

  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late StreamController<firebase_auth.User?> authStateController;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    authStateController = StreamController<firebase_auth.User?>.broadcast();

    when(() => mockFirebaseAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);
    when(() => mockGoogleSignIn.initialize()).thenAnswer((_) async {});
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
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
    test('signs in to Firebase with the Google ID token', () async {
      final account = MockGoogleSignInAccount();
      when(() => account.authentication)
          .thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => account);
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());

      await (buildRepo()..isWeb = false).logInWithGoogle();

      verify(() => mockGoogleSignIn.initialize()).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('throws a canceled failure when the account picker is dismissed',
        () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      await expectLater(
        (buildRepo()..isWeb = false).logInWithGoogle(),
        throwsA(isA<LogInWithGoogleFailure>()
            .having((e) => e.isCanceled, 'isCanceled', true)),
      );
    });

    test('reports a network error when Google Sign-In is offline', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'A network error occurred.',
        ),
      );

      await expectLater(
        (buildRepo()..isWeb = false).logInWithGoogle(),
        throwsA(isA<LogInWithGoogleFailure>()
            .having((e) => e.message, 'message', kNetworkErrorMessage)),
      );
    });
  });

  group('AuthRepository - sendPasswordResetEmail', () {
    test('sends the link to the trimmed address', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'))).thenAnswer((_) async {});

      await buildRepo().sendPasswordResetEmail(email: ' me@example.com ');

      verify(() =>
              mockFirebaseAuth.sendPasswordResetEmail(email: 'me@example.com'))
          .called(1);
    });

    test('reports an invalid address', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email')))
          .thenThrow(
              firebase_auth.FirebaseAuthException(code: 'invalid-email'));

      await expectLater(
        buildRepo().sendPasswordResetEmail(email: 'nope'),
        throwsA(isA<PasswordResetFailure>()
            .having((e) => e.error, 'error', AuthError.invalidEmail)),
      );
    });
  });

  group('AuthRepository - signedInWithPassword', () {
    MockUserInfo provider(String id) {
      final info = MockUserInfo();
      when(() => info.providerId).thenReturn(id);
      return info;
    }

    test('is true for an email/password account', () {
      final user = firebaseUser(verified: true);
      final providers = [provider('password')];
      when(() => user.providerData).thenReturn(providers);
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      expect(buildRepo().signedInWithPassword, isTrue);
    });

    test('is false for a Google account and when signed out', () {
      final user = firebaseUser(verified: true);
      final providers = [provider('google.com')];
      when(() => user.providerData).thenReturn(providers);
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);
      expect(buildRepo().signedInWithPassword, isFalse);

      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      expect(buildRepo().signedInWithPassword, isFalse);
    });
  });

  group('AuthRepository - reauthenticate', () {
    test('uses the password for an email account', () async {
      final user = firebaseUser(verified: true);
      when(() => user.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await buildRepo().reauthenticate(password: 'secret');

      final credential =
          verify(() => user.reauthenticateWithCredential(captureAny()))
              .captured
              .single as firebase_auth.AuthCredential;
      expect(credential.providerId, 'password');
    });

    test('uses Google when there is no password', () async {
      final user = firebaseUser(verified: true);
      final account = MockGoogleSignInAccount();
      when(() => account.authentication)
          .thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => account);
      when(() => user.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await (buildRepo()..isWeb = false).reauthenticate();

      final credential =
          verify(() => user.reauthenticateWithCredential(captureAny()))
              .captured
              .single as firebase_auth.AuthCredential;
      expect(credential.providerId, 'google.com');
    });

    test('reports a wrong password', () async {
      final user = firebaseUser(verified: true);
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'invalid-credential'));
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await expectLater(
        buildRepo().reauthenticate(password: 'wrong'),
        throwsA(isA<DeleteAccountFailure>()
            .having((e) => e.error, 'error', AuthError.wrongPassword)),
      );
    });

    test('is canceled when the Google picker is dismissed', () async {
      final user = firebaseUser(verified: true);
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await expectLater(
        (buildRepo()..isWeb = false).reauthenticate(),
        throwsA(isA<DeleteAccountFailure>()
            .having((e) => e.isCanceled, 'isCanceled', true)),
      );
    });
  });

  group('AuthRepository - deleteAccount', () {
    test('deletes the Firebase user and signs out of Google', () async {
      final user = firebaseUser(verified: true);
      when(() => user.delete()).thenAnswer((_) async {});
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await (buildRepo()..isWeb = false).deleteAccount();

      verify(() => user.delete()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('reports a failure', () async {
      final user = firebaseUser(verified: true);
      when(() => user.delete()).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'requires-recent-login'));
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      await expectLater(
        buildRepo().deleteAccount(),
        throwsA(isA<DeleteAccountFailure>()),
      );
    });
  });

  group('AuthRepository - logOut', () {
    test('calls signOut on both firebase and google', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await (buildRepo()..isWeb = false).logOut();

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

  group('LogInWithGoogleFailure.fromGoogleSignInException', () {
    LogInWithGoogleFailure failure(GoogleSignInExceptionCode code,
            [String? description]) =>
        LogInWithGoogleFailure.fromGoogleSignInException(
            GoogleSignInException(code: code, description: description));

    test('canceled and interrupted are cancellations', () {
      expect(failure(GoogleSignInExceptionCode.canceled).isCanceled, isTrue);
      expect(failure(GoogleSignInExceptionCode.interrupted).isCanceled, isTrue);
    });

    test('configuration errors point at the setup', () {
      expect(failure(GoogleSignInExceptionCode.clientConfigurationError).error,
          AuthError.googleNotConfigured);
      expect(
          failure(GoogleSignInExceptionCode.unknownError,
                  '[28444] Developer console is not set up correctly.')
              .error,
          AuthError.googleNotConfigured);
    });

    test('a network failure is reported as such', () {
      expect(
          failure(GoogleSignInExceptionCode.unknownError, 'Network error')
              .error,
          AuthError.network);
    });

    test('other errors fall back to the default message', () {
      final other = failure(GoogleSignInExceptionCode.unknownError);
      expect(other.message, 'An unknown exception occurred.');
      expect(other.isCanceled, isFalse);
    });
  });
}
