import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/app_bloc/authentication/authentication_bloc.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _testUser = User(
  id: 'test-id',
  email: 'test@example.com',
  name: 'Test User',
  photoMail: 'https://example.com/photo.png',
);

void main() {
  late AuthRepository authRepository;
  late StreamController<User> userStreamController;

  setUp(() {
    authRepository = MockAuthRepository();
    userStreamController = StreamController<User>();

    when(() => authRepository.user)
        .thenAnswer((_) => userStreamController.stream);
    when(() => authRepository.currentUser).thenReturn(User.empty);
    when(() => authRepository.logOut()).thenAnswer((_) async {});
  });

  tearDown(() {
    userStreamController.close();
  });

  group('AuthenticationBloc', () {
    test('initial state is unauthenticated when user is empty', () {
      final bloc = AuthenticationBloc(authRepository: authRepository);
      expect(bloc.state, const AuthState.unauthenticated());
      bloc.close();
    });

    test('initial state is authenticated when user is not empty', () {
      when(() => authRepository.currentUser).thenReturn(_testUser);
      final bloc = AuthenticationBloc(authRepository: authRepository);
      expect(bloc.state.status, AuthenticationStatus.authenticated);
      expect(bloc.state.user, _testUser);
      bloc.close();
    });

    test('isAuthenticated returns true when authenticated', () {
      when(() => authRepository.currentUser).thenReturn(_testUser);
      final bloc = AuthenticationBloc(authRepository: authRepository);
      expect(bloc.isAuthenticated(), isTrue);
      bloc.close();
    });

    test('isAuthenticated returns false when unauthenticated', () {
      final bloc = AuthenticationBloc(authRepository: authRepository);
      expect(bloc.isAuthenticated(), isFalse);
      bloc.close();
    });

    group('AuthUserChanged', () {
      blocTest<AuthenticationBloc, AuthState>(
        'emits authenticated when user stream emits a non-empty user',
        build: () => AuthenticationBloc(authRepository: authRepository),
        act: (bloc) => userStreamController.add(_testUser),
        expect: () => [
          const AuthState.authenticated(_testUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthState>(
        'emits unauthenticated when user stream emits User.empty',
        build: () {
          when(() => authRepository.currentUser).thenReturn(_testUser);
          return AuthenticationBloc(authRepository: authRepository);
        },
        act: (bloc) => userStreamController.add(User.empty),
        expect: () => [
          const AuthState.unauthenticated(),
        ],
      );
    });

    group('updateUser', () {
      blocTest<AuthenticationBloc, AuthState>(
        'emits authenticated state when updateUser is called with valid user',
        build: () => AuthenticationBloc(authRepository: authRepository),
        act: (bloc) => bloc.updateUser(_testUser),
        expect: () => [
          const AuthState.authenticated(_testUser),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthenticationBloc, AuthState>(
        'calls logOut on repository when logout is called',
        build: () => AuthenticationBloc(authRepository: authRepository),
        act: (bloc) => bloc.logout(),
        verify: (_) {
          verify(() => authRepository.logOut()).called(1);
        },
      );
    });
  });

  group('AuthState', () {
    test('unknown state is unauthenticated with empty user', () {
      const state = AuthState.unknown();
      expect(state.status, AuthenticationStatus.unauthenticated);
      expect(state.user, User.empty);
    });

    test('authenticated state has correct status and user', () {
      const state = AuthState.authenticated(_testUser);
      expect(state.status, AuthenticationStatus.authenticated);
      expect(state.user, _testUser);
      expect(state.isAuthenticated, isTrue);
      expect(state.isNotAuthenticated, isFalse);
    });

    test('unauthenticated state has correct status and empty user', () {
      const state = AuthState.unauthenticated();
      expect(state.status, AuthenticationStatus.unauthenticated);
      expect(state.user, User.empty);
      expect(state.isAuthenticated, isFalse);
      expect(state.isNotAuthenticated, isTrue);
    });

    test('two states with same props are equal', () {
      const state1 = AuthState.authenticated(_testUser);
      const state2 = AuthState.authenticated(_testUser);
      expect(state1, equals(state2));
    });
  });
}
