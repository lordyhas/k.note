import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/values.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/pages/home_screen.dart';
import 'package:utils_component/utils_component.dart';

import 'data/app_bloc/authentication/authentication_bloc.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 1,),
          BlocBuilder<AuthenticationBloc, AuthState>(
            builder: (context, state){
              return Text("Welcome to K.NOTE"
                  "${state.isAuthenticated ? " # " : "" }",
                style: TextStyle(
                    //fontSize: 20,
                    color: Theme.of(context).primaryColor),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 64.0),
            child:Image.asset(
              imageLogoApp,
              height: 120,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              BlocBuilder<AuthenticationBloc, AuthState>(
                builder: (context, state){
                  return BooleanBuilder(
                    condition: () => state.isAuthenticated,
                    ifTrue: ElevatedButton(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text("Login"),
                      ),
                      onPressed: () {
                        //GoRouter.of(context).pushNamed(HomeScreen.routeName);
                        //GoRouter.of(context).pushReplacementNamed(HomeScreen.routeName);
                        GoRouter.of(context).pushReplacement("/r/home");
                        //GoRouter.of(context).pop();
                      },
                    ),
                    ifFalse: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,

                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text("Login",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () => GoRouter.of(context)
                          .pushReplacement("/${LoginPage.routeName}"),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
          //ComingSoon(),
          const Spacer(flex: 2,),
        ],
      ),
    );
  }
}
