import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:pedantic/pedantic.dart';

import '../../authentication_repository.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthEvent, AuthState> {
  AuthenticationBloc({required AuthRepository authRepository}):
        _authenticationRepository = authRepository,
        super(authRepository.currentUser.isNotEmpty
          ? AuthState.authenticated(authRepository.currentUser)
          : const AuthState.unauthenticated(),
      ) {

    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user
        .listen((user) => add(AuthUserChanged(user)),
    );

  }

  final AuthRepository _authenticationRepository;
  StreamSubscription<User>? _userSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(event.user.isNotEmpty
        ? AuthState.authenticated(event.user)
        : const AuthState.unauthenticated(),
    );
  }

  void updateUser(User user) {
    add(AuthUserChanged(user));
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  void logout() {
    add(AuthLogoutRequested());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
