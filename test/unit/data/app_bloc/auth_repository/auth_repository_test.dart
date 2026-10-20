import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUserCredential extends Mock
    implements firebase_auth.UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

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

  AuthRepository _buildRepo() => AuthRepository(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

  group('AuthRepository - user stream', () {
    test('emits User.empty when auth state emits null', () async {
      final repo = _buildRepo();
      final userFuture = repo.user.first;
      authStateController.add(null);

      expect(await userFuture, User.empty);
    });

    test('caches user so currentUser reflects latest emitted user', () async {
      final repo = _buildRepo();
      final userFuture = repo.user.first;
      authStateController.add(null);

      await userFuture;

      expect(repo.currentUser, User.empty);
    });
  });

  group('AuthRepository - currentUser', () {
    test('returns User.empty when nothing is cached', () {
      expect(_buildRepo().currentUser, User.empty);
    });
  });

  group('AuthRepository - logInWithEmailAndPassword', () {
    test('completes without error on success', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await expectLater(
        _buildRepo().logInWithEmailAndPassword(
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
        _buildRepo().logInWithEmailAndPassword(
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
        await _buildRepo().logInWithEmailAndPassword(
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
        _buildRepo().logInWithEmailAndPassword(
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
        _buildRepo().signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
        completes,
      );
    });
  });

  group('AuthRepository - logOut', () {
    test('calls signOut on both firebase and google', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await _buildRepo().logOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('throws LogOutFailure on exception', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('sign out failed'));

      await expectLater(
        _buildRepo().logOut(),
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
  });
}
