import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/domain/models/user.dart';

part 'verify_email_state.dart';

/// Resends the verification email and checks whether the user opened it.
class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(this._authRepository, {required this.onUserReloaded})
      : super(const VerifyEmailState());

  final AuthRepository _authRepository;

  /// Called with the reloaded user once they no longer need to verify their
  /// email (or are signed out), so the session and the router follow.
  final void Function(User user) onUserReloaded;

  Future<void> resend() async {
    if (state.status == VerifyEmailStatus.sending) return;
    emit(const VerifyEmailState(status: VerifyEmailStatus.sending));
    try {
      await _authRepository.sendEmailVerification();
      if (!isClosed) {
        emit(const VerifyEmailState(status: VerifyEmailStatus.sent));
      }
    } on EmailVerificationFailure catch (e) {
      if (!isClosed) {
        emit(VerifyEmailState(
            status: VerifyEmailStatus.failure, error: e.error));
      }
    }
  }

  /// Asks Firebase whether the email is verified. A [silent] check (the
  /// periodic one) neither shows progress nor reports "not verified yet" or
  /// errors.
  Future<void> checkVerified({bool silent = false}) async {
    if (state.status == VerifyEmailStatus.checking) return;
    if (!silent) {
      emit(const VerifyEmailState(status: VerifyEmailStatus.checking));
    }
    try {
      final user = await _authRepository.reloadUser();
      if (isClosed) return;
      if (!user.needsEmailVerification) {
        onUserReloaded(user);
        return;
      }
      if (!silent) {
        emit(const VerifyEmailState(status: VerifyEmailStatus.notVerifiedYet));
      }
    } on EmailVerificationFailure catch (e) {
      if (!silent && !isClosed) {
        emit(VerifyEmailState(
            status: VerifyEmailStatus.failure, error: e.error));
      }
    }
  }
}
