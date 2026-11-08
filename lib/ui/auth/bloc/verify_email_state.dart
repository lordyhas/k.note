part of 'verify_email_cubit.dart';

enum VerifyEmailStatus {
  initial,
  sending,
  sent,
  checking,
  notVerifiedYet,
  failure,
}

class VerifyEmailState extends Equatable {
  const VerifyEmailState({
    this.status = VerifyEmailStatus.initial,
    this.error,
  });

  final VerifyEmailStatus status;

  /// Why the last request failed, when [status] is
  /// [VerifyEmailStatus.failure].
  final AuthError? error;

  @override
  List<Object?> get props => [status, error];
}
