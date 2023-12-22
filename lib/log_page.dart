import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/values.dart';
import 'package:knote/src/backgound_ui.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/pages/home_screen.dart';
import 'package:utils_component/utils_component.dart';

import 'data/app_bloc/authentication/authentication_bloc.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundUI(
      index: 1,
      child: Stack(
        children: [
          const Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.black45,
                    Colors.black38,
                    Colors.black38,
                    Colors.black26,
                    Colors.black12,
                    Colors.black12,
                    Colors.black12,
                    Colors.black12,
                    Colors.transparent,
                    Colors.black12,
                    Colors.black12,
                    Colors.black12,
                    Colors.black12,
                    Colors.black26,
                    Colors.black38,
                    Colors.black38,
                    Colors.black45,
                    Colors.black54,

                  ],
                )
              ),
            ),
          ),
          Scaffold(
            body: Column(
              children: [
                const Spacer(flex: 1,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<AuthenticationBloc, AuthState>(
                    builder: (context, state){
                      return Text("Welcome to K.NOTE"
                          "${state.isAuthenticated ? " # " : "" }",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 64.0),
                  child:Image.asset(
                    imageLogoApp,
                    height: 120,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.fingerprint_outlined, size: 75,),
                ),

                const SizedBox(height: 16.0,),

                Row(
                  children: [
                    const Spacer(),
                    BlocBuilder<AuthenticationBloc, AuthState>(
                      builder: (context, state){
                        return BooleanBuilder(
                          condition: () => state.isAuthenticated,
                          ifTrue: SizedBox(
                            //dimension: 200,
                            child: ElevatedButton(
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
          ),
        ],
      ),
    );
  }
}
