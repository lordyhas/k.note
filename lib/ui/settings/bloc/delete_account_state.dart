part of 'delete_account_cubit.dart';

enum DeleteAccountStatus { initial, inProgress, deleted, failure }

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.error,
  });

  final DeleteAccountStatus status;

  /// Why it failed, when [status] is [DeleteAccountStatus.failure].
  final AuthError? error;

  @override
  List<Object?> get props => [status, error];
}
