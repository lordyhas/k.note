import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';

import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/bloc/sign_up_cubit.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

/// The icon at the start of a field. [FaIcon] does not center itself in the
/// 48 dp square a prefix icon is given, so it would sit in its corner.
class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      child: FaIcon(icon, size: 18, color: AppColors.of(context).text),
    );
  }
}

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('__loginForm_emailInput_textField__'),
          onChanged: (email) =>
              BlocProvider.of<LoginCubit>(context).emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            prefixIcon: _FieldIcon(FontAwesomeIcons.user),
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
          onChanged: (password) =>
              BlocProvider.of<LoginCubit>(context).passwordChanged(password),
          // The keyboard covers the button on phones: "Done" logs in.
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => context.read<LoginCubit>().logInWithCredentials(),
          obscureText: !showPassword,
          //focusNode: FocusNode(),
          decoration: InputDecoration(
            prefixIcon: _FieldIcon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              tooltip: showPassword
                  ? context.l10n.hidePassword
                  : context.l10n.showPassword,
              icon: FaIcon(
                showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                color: AppColors.of(context).text,
              ),
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
            labelText: context.l10n.passwordLabel,
            helperText: '',
            errorText: state.password.displayError != null
                ? context.l10n.passwordRequired
                : null,
          ),
        );
      },
    );
  }
}

/// Width of the buttons of the login and sign-up forms: three quarters of a
/// phone screen, without growing across a desktop window.
double authButtonWidth(BuildContext context) =>
    math.min(MediaQuery.sizeOf(context).width * 0.75, 320);

/// The main button of the login and sign-up forms: the app's accent color
/// when it can be pressed, faded (and its label dimmed) until the form is
/// valid, so that the two states cannot be mistaken for each other.
ButtonStyle primaryAuthButtonStyle(BuildContext context) {
  final colors = AppColors.of(context);
  return ElevatedButton.styleFrom(
    backgroundColor: colors.accent,
    foregroundColor: colors.onAccent,
    iconColor: colors.onAccent,
    disabledBackgroundColor: colors.disabled.withValues(alpha: 0.35),
    disabledForegroundColor: colors.textMuted,
    disabledIconColor: colors.textMuted,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
    side: BorderSide.none,
    minimumSize: const Size(64, 44),
  );
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = authButtonWidth(context);
    return BlocBuilder<LoginCubit, LoginState>(
      // isValid too: the button turns on as soon as the form is filled in.
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: width,
                child: ElevatedButton(
                  key: const Key('__loginForm_continue_raisedButton__'),
                  style: primaryAuthButtonStyle(context),
                  onPressed: state.isValid
                      ? () => context.read<LoginCubit>().logInWithCredentials()
                      : null,
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.circleUser),
                      const Spacer(),
                      Text(context.l10n.logIn),
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
    final width = authButtonWidth(context);

    Widget googleOutlineButton = OutlinedButton(
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 44)),
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

class EmailSignInInput extends StatelessWidget {
  const EmailSignInInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('__signUpForm_emailInput_textField__'),
          onChanged: (email) =>
              BlocProvider.of<SignUpCubit>(context).emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const _FieldIcon(FontAwesomeIcons.user),
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
            prefixIcon: const _FieldIcon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              tooltip: showPassword
                  ? context.l10n.hidePassword
                  : context.l10n.showPassword,
              icon: FaIcon(showPassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye),
              onPressed: () {
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
    final width = authButtonWidth(context);
    return BlocBuilder<SignUpCubit, SignUpState>(
      // isValid too: the button turns on as soon as the form is filled in.
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: width,
                child: ElevatedButton(
                  key: const Key('__loginForm_continue_raisedButton__'),
                  style: primaryAuthButtonStyle(context),
                  onPressed: state.isValid
                      ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                      : null,
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.circleUser),
                      const Spacer(),
                      Text(context.l10n.signUp),
                      const Spacer(),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
