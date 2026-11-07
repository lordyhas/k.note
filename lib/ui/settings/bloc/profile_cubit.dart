import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';

part 'profile_state.dart';

/// Edits the signed-in user's profile: for now, their display name.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._authRepository, {
    required User user,
    required this.onUserUpdated,
    FirestoreService Function(User user)? firestore,
  })  : _firestore = firestore ?? FirestoreService.user,
        super(ProfileState(
          savedName: user.name?.trim() ?? '',
          name: user.name?.trim() ?? '',
        ));

  /// Longest name accepted, as in `firestore.rules`.
  static const maxNameLength = 100;

  final AuthRepository _authRepository;
  final FirestoreService Function(User user) _firestore;

  /// Called with the updated user, so the session and every page follow.
  final void Function(User user) onUserUpdated;

  void nameChanged(String value) {
    emit(state.copyWith(name: value, status: ProfileStatus.editing));
  }

  /// Saves the name in Firebase Auth (where the app reads it), then copies
  /// it to the Firestore profile document.
  Future<void> save() async {
    if (!state.canSave) return;
    final name = state.name.trim();
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final user = await _authRepository.updateDisplayName(name);
      if (isClosed) return;
      onUserUpdated(user);
      emit(state.copyWith(
          savedName: name, name: name, status: ProfileStatus.saved));
      // A copy for the profile document; the name itself is already saved.
      unawaited(_firestore(user).saveUserProfile().catchError(
          (Object e) => debugPrint('Saving the profile document failed: $e')));
    } on ProfileUpdateFailure catch (e) {
      if (!isClosed) {
        emit(state.copyWith(status: ProfileStatus.failure, error: e.error));
      }
    }
  }
}
