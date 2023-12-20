
part of 'signup_and_login.dart';


class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>(
      debugLabel: "__LoginFormBlocListener__",
    );

    return BlocListener<LoginCubit, LoginState>(
      key: navigatorKey,
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
        } else if (state.status.isSuccess){
          FocusScope.of(context).requestFocus(FocusNode());
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.grey,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                content: const Text('Authenticated Successfully'),
              ),
            );
          //GoRouter.of(context).pushReplacement(HomeScreen.routeName);

        }
      },

      child: SizedBox(
        //height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(top: 58.0),
                  child:Image.asset(
                    imageLogoApp,
                    height: 120,
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: Column(
                      children: <Widget>[
                        BlocBuilder<AuthenticationBloc, AuthState>(
                          builder: (context, state){
                            return Text("Welcome to K.NOTE"
                                "${state.isAuthenticated ? " # " : "" }",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            );
                          },
                        ),
                        const Text("Sign in to continue"),
                      ],
                    )
                ),
              ],
            ),

            const Spacer(),
            BlocBuilder<AuthenticationBloc, AuthState>(
              builder: (context, state){
                switch(state.status){
                  case AuthenticationStatus.authenticated:
                    //GoRouter.of(context).pushReplacement(HomeScreen.routeName);
                    return Center(
                      child: Column(
                        children: [
                          //const Spacer(),
                          const SizedBox(height: 32.0),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Text("You're already signed in with mail \n"
                                "[${state.user.email}]",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: (){
                                GoRouter.of(context)
                                    .replaceNamed(HomeScreen.routeName,);
                                    //.pushReplacement(HomeScreen.routeName);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Text('Continue'),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                          //const Spacer(),
                        ],
                      ),
                    );
                  case AuthenticationStatus.unauthenticated:
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25, top: 2,),
                          child: _EmailInput(),
                        ),

                        //
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25, top: 2),
                          child: _PasswordInput(),
                        ),
                        //

                        const SizedBox(height: 32.0),
                        SizedBox(
                          child: Column(children: [
                            //const Spacer(),
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
                            //const Spacer(),
                          ],),
                        ),
                      ],
                    );
                }
              },
            ),
            const Spacer(),

          ],
        ),
      )
    );
  }

  _oldUI() => Align(
    //padding: EdgeInsets.all(0),
    child: Column(
      //mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16.0),
        BlocBuilder<AuthenticationBloc, AuthState>(
          builder: (context, state){
            switch(state.status){
              case AuthenticationStatus.authenticated:
                return Column(
                  children: [
                    //const Spacer(),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text("You're already signed in with : "
                          "[${state.user.email}]",
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: (){
                          GoRouter
                              .of(context)
                              .pushReplacement(HomeScreen.routeName);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text('Continue'),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    //const Spacer(),
                  ],
                );
              case AuthenticationStatus.unauthenticated:
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, top: 2,),
                      child: _EmailInput(),
                    ),

                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, top: 2),
                      child: _PasswordInput(),
                    ),
                    //
                    SizedBox(
                      child: Column(children: [
                        //const Spacer(),
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
                        //const Spacer(),
                      ],),
                    ),
                  ],
                );
            }
          },
        ),

        //_GoToSignUpPageTextButton(),
        //_ContinueWithOutButton(),
      ],
    ),
  );
}