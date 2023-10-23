part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState( {
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.password2 = const Password2.pure(),
    this.status = FormzStatus.pure,
    this.messageError= '',
  });

  final Email email;
  final Password password;
  final Password2 password2;
  final FormzStatus status;
  final String messageError;

  @override
  List<Object> get props => [email, password, status];

  SignUpState copyWith({
    Email? email,
    Password? password,
    Password2? password2,
    FormzStatus? status,
    String? messageError,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      password2: password2 ?? this.password2,
      status: status ?? this.status,
      messageError: messageError ?? this.messageError,
    );
  }
}
