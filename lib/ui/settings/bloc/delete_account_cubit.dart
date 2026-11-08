import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';

part 'delete_account_state.dart';

/// Deletes the signed-in user's account and everything stored for them.
///
/// Firebase only deletes an account after a recent sign-in, so the user
/// first confirms who they are ([AuthRepository.reauthenticate]); their data
/// is then deleted while the rules still let them, and the auth account
/// last. Deleting it signs them out, which sends them to the login page.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(
    this._authRepository,
    this._firestoreService, {
    this.beforeAccountDeleted,
  }) : super(const DeleteAccountState());

  final AuthRepository _authRepository;
  final FirestoreService _firestoreService;

  /// Clean-up done on this device once the data is gone (e.g. cancelling
  /// reminders).
  final Future<void> Function()? beforeAccountDeleted;

  /// [password] confirms the identity of email accounts; Google accounts
  /// pick their account again instead.
  Future<void> deleteAccount({String? password}) async {
    if (state.status == DeleteAccountStatus.inProgress) return;
    emit(const DeleteAccountState(status: DeleteAccountStatus.inProgress));
    try {
      await _authRepository.reauthenticate(password: password);
      await _firestoreService.deleteAllUserData();
      await beforeAccountDeleted?.call();
      await _authRepository.deleteAccount();
      if (!isClosed) {
        emit(const DeleteAccountState(status: DeleteAccountStatus.deleted));
      }
    } on DeleteAccountFailure catch (e) {
      if (isClosed) return;
      emit(e.isCanceled
          ? const DeleteAccountState()
          : DeleteAccountState(
              status: DeleteAccountStatus.failure, error: e.error));
    } catch (e) {
      debugPrint('Deleting the account data failed: $e');
      if (!isClosed) {
        emit(const DeleteAccountState(
            status: DeleteAccountStatus.failure, error: AuthError.unknown));
      }
    }
  }
}
