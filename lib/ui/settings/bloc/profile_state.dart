part of 'profile_cubit.dart';

enum ProfileStatus { editing, saving, saved, failure }

class ProfileState extends Equatable {
  const ProfileState({
    required this.savedName,
    required this.name,
    this.status = ProfileStatus.editing,
    this.error,
  });

  /// The name currently saved on the account.
  final String savedName;

  /// The name in the field.
  final String name;

  final ProfileStatus status;

  /// Why the last save failed, when [status] is [ProfileStatus.failure].
  final AuthError? error;

  bool get isNameValid {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && trimmed.length <= ProfileCubit.maxNameLength;
  }

  bool get canSave =>
      isNameValid && name.trim() != savedName && status != ProfileStatus.saving;

  ProfileState copyWith({
    String? savedName,
    String? name,
    ProfileStatus? status,
    AuthError? error,
  }) =>
      ProfileState(
        savedName: savedName ?? this.savedName,
        name: name ?? this.name,
        status: status ?? this.status,
        error: error,
      );

  @override
  List<Object?> get props => [savedName, name, status, error];
}
