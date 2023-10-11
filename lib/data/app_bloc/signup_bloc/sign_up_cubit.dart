
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../auth_repository/repository.dart';
import '../login_bloc/login_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:formz/formz.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository)
      : /*assert(_authenticationRepository != null),*/
        super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;
  User? _user = FirebaseAuth.instance.currentUser;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String value, {bool second = false}) {

    final password = Password.dirty(value);
    final password2 = Password2.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));

    /**
    if(second)
      emit(state.copyWith(
        password2: password2,
        status: Formz.validate([state.email, password]),
      ));
    else
      emit(state.copyWith(
        password: password,
        status: Formz.validate([state.email, password]),
      ));*/
  }

  Future<void> signUpFormSubmitted() async {

    if (!state.status.isValidated) return;
    if(state.password.value == state.password2.value){
      emit(state.copyWith(
          status: FormzStatus.submissionFailure,
          messageError: "Password Failure"
      ));
      return;
    }
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );

      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      print("Exception 2 : signUpFormSubmitted() => $Exception");
      emit(state.copyWith(
          status: FormzStatus.submissionFailure,
          messageError: "Sign Up Failure"
      ));
    }
  }
}
