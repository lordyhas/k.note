
part of 'signup_and_login.dart';



class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) => BlocProvider.of<LoginCubit>(context).emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(FontAwesomeIcons.userAlt, color: Colors.white,),
            labelText: 'Enter your mail address',
            helperText: '',
            errorText: state.email.displayError != null ? 'invalid email' : null, // 231010-012084
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatefulWidget {
  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) => BlocProvider.of<LoginCubit>(context)
              .passwordChanged(password),
          obscureText: !showPassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(FontAwesomeIcons.lock, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(showPassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye,
                color: Colors.white,
              ),
              onPressed: (){
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
            labelText: 'Enter your password',
            helperText: '',
            errorText: state.password.displayError != null ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}



class _LoginButton extends StatelessWidget {
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
                key: const Key('loginForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: state.isValid
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.circleUser, color: Colors.white,),
                    Spacer(),
                    Text('Sign In', style: TextStyle(color: Colors.white),),
                    Spacer(),
                    Icon(FontAwesomeIcons.circleUser, color: Colors.transparent,),
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

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;

    Widget googleOutlineButton = OutlinedButton(
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      style: ElevatedButton.styleFrom(
        side: const BorderSide(
            width: 2.0,
            color: Colors.blue //theme.primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),

      //color: theme.accentColor,
      //textColor: theme.accentColor,
      //highlightedBorderColor: theme.primaryColor,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),

      child:  const Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(FontAwesomeIcons.google),
          Spacer(),
          Text("Sign in with Google"),
          Spacer(),
          Icon(FontAwesomeIcons.google, color: Colors.transparent,),
        ],
      ),

    );

    return SizedBox(width: width, child: googleOutlineButton);
  }
}

class _FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;

    Widget facebookOutlineButton = OutlinedButton(
      key: const Key('loginForm_facebookLogin_outlineButton'),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
            width: 2.0,
            color: Colors.blue //theme.primaryColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),

      onPressed: () {}, //=> context.bloc<LoginCubit>().logInWithFacebook(),

      child: const Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(FontAwesomeIcons.facebookF),
          Spacer(),
          Text("Sign in with Facebook"),
          Spacer(),
          Icon(FontAwesomeIcons.facebookF, color: Colors.transparent,),
        ],
      ),
    );

    return SizedBox(width: width, child: facebookOutlineButton);
  }
}


class _EmailSignInInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_emailInput_textField'),
          onChanged: (email) => BlocProvider.of<SignUpCubit>(context).emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(FontAwesomeIcons.user),
            labelText: 'email',
            helperText: '',
            errorText: state.email.displayError != null ? 'invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordSignInInput extends StatefulWidget {
  @override
  __PasswordSignInInputState createState() => __PasswordSignInInputState();
}


class __PasswordSignInInputState extends State<_PasswordSignInInput> {
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
            prefixIcon: const Icon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              icon: Icon(showPassword? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye),
              onPressed: (){
                setState(() {
                  showPassword = !showPassword;
                });

              },
            ),
            labelText: 'password',
            helperText: '',
            errorText: state.password.displayError != null ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
      previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_confirmedPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmPassword),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'confirm password',
            helperText: '',
            errorText: state.confirmedPassword.displayError != null
                ? 'passwords do not match'
                : null,
          ),
        );
      },
    );
  }
}

class _SignUpSignInButton extends StatelessWidget {

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
                  key: const Key('loginForm_continue_raisedButton'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: state.isValid
                      ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                      : null,
                  child: const SizedBox(
                    child:  Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          FontAwesomeIcons.circleUser,
                          color: Colors.white,
                        ),
                        Spacer(),
                        Text('Sign Up', style: TextStyle(color: Colors.white),),
                        Spacer(),
                      ],
                    ),
                  ),

          ),
        );
      },
    );
  }
}
