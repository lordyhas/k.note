part of 'password_reset_cubit.dart';

enum PasswordResetStatus { initial, sending, sent, failure }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.email = const Email.pure(),
    this.status = PasswordResetStatus.initial,
    this.error,
  });

  final Email email;
  final PasswordResetStatus status;

  /// Why the last request failed, when [status] is
  /// [PasswordResetStatus.failure].
  final AuthError? error;

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    AuthError? error,
  }) =>
      PasswordResetState(
          email: email, status: status ?? this.status, error: error);

  @override
  List<Object?> get props => [email, status, error];
}
