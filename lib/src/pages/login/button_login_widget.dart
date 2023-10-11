
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
            errorText: state.email.invalid ? 'invalid email' : null, // 231010-012084
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
          onChanged: (password) =>
              BlocProvider.of<LoginCubit>(context).passwordChanged(password),
          obscureText: !showPassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(FontAwesomeIcons.lock, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(showPassword? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, color: Colors.white),
              onPressed: (){
                setState(() {
                  showPassword = !showPassword;
                });

              },
            ),
            labelText: 'Enter your password',
            helperText: '',
            errorText: state.password.invalid ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}



class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;
    final theme = Theme.of(context);
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : Container(
              width: width,
              child: ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: state.status.isValidated
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                child: Container(
                  child: const Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(FontAwesomeIcons.userCircle, color: Colors.white,),
                      Spacer(),
                      Text('Sign In', style: TextStyle(color: Colors.white),),
                      Spacer(),
                      Icon(FontAwesomeIcons.userCircle, color: Colors.transparent,),
                    ],
                  ),
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
    final theme = Theme.of(context);

    Widget googleOutlineButton = OutlinedButton(
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      //BlocProvider.of<LoginCubit>(context).logInWithGoogle(),

      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),

        /*borderSide: BorderSide(
          color: theme.accentColor,
        ),*/
      ),

      //color: theme.accentColor,
      //textColor: theme.accentColor,
      //highlightedBorderColor: theme.primaryColor,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),

      child:  Container(
        child: const Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(FontAwesomeIcons.google),
            Spacer(),
            Text("Sign in with Google"),
            Spacer(),
            Icon(FontAwesomeIcons.google, color: Colors.transparent,),
          ],
        ),
      ),

    );

    return Container(width: width, child: googleOutlineButton);
  }
}

class _FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *0.75;
    final theme = Theme.of(context);


    Widget facebookOutlineButton = OutlinedButton(
      key: const Key('loginForm_facebookLogin_outlineButton'),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
      //color: theme.accentColor,
      //textColor: theme.accentColor,
      //highlightedBorderColor: theme.primaryColor,

      /*borderSide: BorderSide(
        color: theme.accentColor,
      ),*/

      //icon: Icon(FontAwesomeIcons.facebookF),
      //label: Text("Sign in with Facebook"),
      onPressed: () {}, //=> context.bloc<LoginCubit>().logInWithFacebook(),

      child: Container(
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
      ),
    );

    return Container(width: width, child: facebookOutlineButton);
  }
}

class _GoToSignUpPageTextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var textSignUp = RichText(
      text: TextSpan(
        text: "Have you already an account? ",
        style: TextStyle(color: Colors.grey),
        children: [
          TextSpan(
            text: "Sign Up",
            style: TextStyle(color: theme.primaryColor),
          ),
        ],
      ) ,
    );
    Widget flatButton = TextButton(
      key: const Key('loginForm_createAccount_flatButton'),
      child: textSignUp,
      onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
    );

    return  flatButton;
  }
}


class _ContinueWithOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text1 = "SKIP";
    final text2 = "CONTINUE WITHOUT AN ACCOUNT";

    return TextButton(
      key: const Key('loginForm_createAccount_flatButton'),
      child: Text(
        text2,
        style: TextStyle(color: theme.primaryColor),
      ),
      onPressed: () => Navigator.of(context)
          .pushAndRemoveUntil<void>(NavigationHomeScreen.route(),(route) => false),
    );
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
            prefixIcon: Icon(FontAwesomeIcons.userAlt),
            labelText: 'email',
            helperText: '',
            errorText: state.email.invalid ? 'invalid email' : null,
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
            errorText: state.password.invalid ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _SignUpSignInButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width *0.75;

    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : Container(
                width: width,
                child: ElevatedButton(
                  key: const Key('loginForm_continue_raisedButton'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: state.status.isValidated
                      ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                      : null,
                  child: const SizedBox(
                    child:  Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          FontAwesomeIcons.userCircle,
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
