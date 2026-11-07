import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/domain/models/user_preferences.dart';

/// The signed-in user's [UserPreferences], live: they change when the user
/// edits them on this device or another one. Signed-out users, and users who
/// must verify their email, get [UserPreferences.defaults].
///
/// Provided above the app (`main.dart`) because the language comes from it.
class PreferencesCubit extends Cubit<UserPreferences> {
  PreferencesCubit({
    required Stream<User> users,
    required FirestoreService Function(User user) firestore,
  })  : _firestore = firestore,
        super(UserPreferences.defaults) {
    _users = users.listen(_onUser);
  }

  final FirestoreService Function(User user) _firestore;
  late final StreamSubscription<User> _users;
  StreamSubscription<UserPreferences>? _preferences;
  FirestoreService? _service;
  String? _userId;

  void _onUser(User user) {
    final canRead = user.isNotEmpty && !user.needsEmailVerification;
    final id = canRead ? user.id : null;
    if (id == _userId) return;
    _userId = id;
    _preferences?.cancel();
    _preferences = null;
    _service = null;
    if (!canRead) {
      emit(UserPreferences.defaults);
      return;
    }
    final service = _service = _firestore(user);
    _preferences = service.watchPreferences().listen(
          emit,
          onError: (Object e) => debugPrint('Watching preferences: $e'),
        );
  }

  /// Shows [preferences] at once and saves them. Returns the Firestore
  /// write, which completes once the server has it (never while offline):
  /// callers pass it to `saveInBackground` rather than awaiting it.
  Future<void> update(UserPreferences preferences) {
    emit(preferences);
    return _service?.savePreferences(preferences) ?? Future.value();
  }

  @override
  Future<void> close() async {
    await _users.cancel();
    await _preferences?.cancel();
    return super.close();
  }
}
