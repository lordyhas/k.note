
part of 'signup_and_login.dart';


class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {

        if (state.status.isFailure) {
          FocusScope.of(context).requestFocus(FocusNode());
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                backgroundColor: Colors.grey,
                  behavior: SnackBarBehavior.floating,
                  content: Text('Authentication Failure'),
              ),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(top: 32.0),
              child:Image.asset(
                imageLogoApp,
                height: 120,
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Welcome to K.NOTE",
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor),
                    ),
                    const Text("Sign in to continue"),

                  ],
                )
            ),

            const SizedBox(height: 16.0),

            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25.0, top: 2.0),
              child: _EmailInput(),
            ),

            //_EmailInput(),



            const SizedBox(height: 8.0),

            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25.0, top: 2.0),
              child: _PasswordInput(),
            ),

            //_PasswordInput(),
            Expanded(
              child: Column(children: [
                const Spacer(),
                _LoginButton(),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  //color: Colors.green,
                  //width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 70, color: Colors.grey,),
                      const SizedBox(width: 4.0,),
                      const Text("OR"),
                      const SizedBox(width: 4.0,),

                      Container(height: 1, width: 70, color: Colors.grey,),
                    ],
                  ),
                ),
                _GoogleLoginButton(),
                _FacebookLoginButton(),
                const Spacer(flex: 2,),
              ],),
            ),

            //_GoToSignUpPageTextButton(),
            //_ContinueWithOutButton(),

          ],
        ),
      ),
    );
  }
}