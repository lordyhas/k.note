import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';

import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/bloc/sign_up_cubit.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';




class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('__loginForm_emailInput_textField__'),
          onChanged: (email) => BlocProvider.of<LoginCubit>(context)
              .emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.of(context).text),
            ),
            prefixIcon: FaIcon(FontAwesomeIcons.user,
              color: AppColors.of(context).text,
            ),
            labelText: context.l10n.emailLabel,
            helperText: '',
            errorText: state.email.displayError != null
                ? context.l10n.invalidEmail
                : null,
          ),
        );
      },
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        //FocusScope.of(context).requestFocus(FocusNode());
        return TextField(
          key: const Key('__loginForm_passwordInput_textField__'),
          onChanged: (password) => BlocProvider.of<LoginCubit>(context)
              .passwordChanged(password),
          obscureText: !showPassword,
          //focusNode: FocusNode(),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.of(context).text),
            ),
            prefixIcon: FaIcon(FontAwesomeIcons.lock,
                color: AppColors.of(context).text),
            suffixIcon: IconButton(
              tooltip: showPassword
                  ? context.l10n.hidePassword
                  : context.l10n.showPassword,
              icon: FaIcon(showPassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye,
                color: AppColors.of(context).text,
              ),
              onPressed: (){
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
            labelText: context.l10n.passwordLabel,
            helperText: '',
            errorText: state.password.displayError != null
                ? context.l10n.invalidPassword
                : null,
          ),
        );
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
              width: width,
              child: ElevatedButton(
                key: const Key('__loginForm_continue_raisedButton__'),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.of(context).disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: state.isValid
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.circleUser,
                        color: AppColors.of(context).text),
                    const Spacer(),
                    Text(context.l10n.logIn,
                        style: TextStyle(color: AppColors.of(context).text)),
                    const Spacer(),
                    const FaIcon(FontAwesomeIcons.circleUser,
                        color: Colors.transparent),
                  ],
                ),

                //color: theme.primaryColor,

        ),
            );
        //ProgressButton(child: const Text('LOGIN'),);

      },
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;

    Widget googleOutlineButton = OutlinedButton(
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      style: ElevatedButton.styleFrom(
        side: BorderSide(width: 2.0, color: AppColors.of(context).link),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),

      //color: theme.accentColor,
      //textColor: theme.accentColor,
      //highlightedBorderColor: theme.primaryColor,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),

      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.google),
          const Spacer(),
          Text(context.l10n.signInWithGoogle),
          const Spacer(),
          const FaIcon(FontAwesomeIcons.google, color: Colors.transparent),
        ],
      ),

    );

    return SizedBox(width: width, child: googleOutlineButton);
  }
}

class FacebookLoginButton extends StatelessWidget {
  const FacebookLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;

    Widget facebookOutlineButton = OutlinedButton(
      key: const Key('__loginForm_facebookLogin_outlineButton__'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 2.0, color: AppColors.of(context).link),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),

      onPressed: () {}, //=> context.bloc<LoginCubit>().logInWithFacebook(),

      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.facebookF),
          const Spacer(),
          Text(context.l10n.signInWithFacebook),
          const Spacer(),
          const FaIcon(FontAwesomeIcons.facebookF, color: Colors.transparent),
        ],
      ),
    );

    return SizedBox(width: width, child: facebookOutlineButton);
  }
}


class EmailSignInInput extends StatelessWidget {
  const EmailSignInInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('__signUpForm_emailInput_textField__'),
          onChanged: (email) => BlocProvider.of<SignUpCubit>(context)
              .emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const FaIcon(FontAwesomeIcons.user),
            labelText: context.l10n.emailLabel,
            helperText: '',
            errorText: state.email.displayError != null
                ? context.l10n.invalidEmail
                : null,
          ),
        );
      },
    );
  }
}

class PasswordSignInInput extends StatefulWidget {
  const PasswordSignInInput({super.key});

  @override
  State<PasswordSignInInput> createState() => _PasswordSignInInputState();
}


class _PasswordSignInInputState extends State<PasswordSignInInput> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          onChanged: (password) =>
              BlocProvider.of<SignUpCubit>(context).passwordChanged(password),
          obscureText: !showPassword,
          decoration: InputDecoration(
            prefixIcon: const FaIcon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              tooltip: showPassword
                  ? context.l10n.hidePassword
                  : context.l10n.showPassword,
              icon: FaIcon(showPassword? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye),
              onPressed: (){
                setState(() {
                  showPassword = !showPassword;
                });

              },
            ),
            labelText: context.l10n.passwordLabel,
            helperText: '',
            errorText: state.password.displayError != null
                ? context.l10n.invalidPassword
                : null,
          ),
        );
      },
    );
  }
}

// class _ConfirmPasswordInput extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SignUpCubit, SignUpState>(
//       buildWhen: (previous, current) =>
//       previous.password != current.password ||
//           previous.confirmedPassword != current.confirmedPassword,
//       builder: (context, state) {
//         return TextField(
//           key: const Key('__signUpForm_confirmedPasswordInput_textField__'),
//           onChanged: (confirmPassword) => context
//               .read<SignUpCubit>()
//               .confirmedPasswordChanged(confirmPassword),
//           obscureText: true,
//           decoration: InputDecoration(
//             labelText: 'confirm password',
//             helperText: '',
//             errorText: state.confirmedPassword.displayError != null
//                 ? 'passwords do not match'
//                 : null,
//           ),
//         );
//       },
//     );
//   }
// }

class SignUpSignInButton extends StatelessWidget {
  const SignUpSignInButton({super.key});


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: width,
                child: ElevatedButton(
                  key: const Key('__loginForm_continue_raisedButton__'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: state.isValid
                      ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                      : null,
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleUser,
                        color: AppColors.of(context).text,
                      ),
                      const Spacer(),
                      Text(context.l10n.signUp,
                          style: TextStyle(color: AppColors.of(context).text)),
                      const Spacer(),
                    ],
                  ),

          ),
        );
      },
    );
  }
}
