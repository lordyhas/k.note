part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const LoginPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.error,
  });

  final Email email;
  final LoginPassword password;
  final FormzSubmissionStatus status;
  final bool isValid;

  /// English, for logs; [error] is what the UI shows, translated.
  final String? errorMessage;
  final AuthError? error;

  @override
  List<Object?> get props =>
      [email, password, status, isValid, errorMessage, error];

  LoginState copyWith({
    Email? email,
    LoginPassword? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    AuthError? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
    );
  }
}
