import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/login_models.dart';

part 'password_reset_state.dart';

/// Sends the link to choose a new password ("Forgot password?" on the login
/// page, "Change password" in the settings).
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit(this._authRepository, {String email = ''})
      : super(PasswordResetState(email: Email.dirty(email.trim())));

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(PasswordResetState(email: Email.dirty(value.trim())));
  }

  Future<void> send() async {
    if (state.email.isNotValid || state.status == PasswordResetStatus.sending) {
      return;
    }
    emit(state.copyWith(status: PasswordResetStatus.sending));
    try {
      await _authRepository.sendPasswordResetEmail(email: state.email.value);
      if (!isClosed) emit(state.copyWith(status: PasswordResetStatus.sent));
    } on PasswordResetFailure catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
            status: PasswordResetStatus.failure, error: e.error));
      }
    }
  }
}
