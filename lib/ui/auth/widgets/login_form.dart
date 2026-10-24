import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/auth/widgets/login_buttons.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final navigatorKey = GlobalKey<NavigatorState>(
      debugLabel: "__LoginFormBlocListener__",
    );

    return BlocListener<LoginCubit, LoginState>(
        key: navigatorKey,
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isFailure) {
            FocusScope.of(context).requestFocus(FocusNode());
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(authErrorText(l10n, state.error)),
                ),
              );
          } else if (state.status.isSuccess) {
            FocusScope.of(context).requestFocus(FocusNode());
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  content: Text(l10n.signedIn),
                ),
              );
            GoRouter.of(context).pushReplacement("/${NotesPage.routeName}");
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
                    child: Image.asset(
                      imageLogoApp,
                      height: 120,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Column(
                        children: <Widget>[
                          BlocBuilder<AuthenticationBloc, AuthState>(
                            builder: (context, state) {
                              return Text(
                                l10n.welcome,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                          Text(l10n.signInToContinue),
                        ],
                      )),
                ],
              ),
              const Spacer(),
              BlocBuilder<AuthenticationBloc, AuthState>(
                builder: (context, state) {
                  switch (state.status) {
                    case AuthenticationStatus.authenticated:
                      //GoRouter.of(context).pushReplacement(NotesPage.routeName);
                      return Center(
                        child: Column(
                          children: [
                            //const Spacer(),
                            const SizedBox(height: 32.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                l10n.alreadySignedIn(state.user.email),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            OutlinedButton(onPressed: (){
                              GoRouter.of(context).pushReplacement("/${NotesPage.routeName}");
                            }, child: Text(l10n.goToHome)),
                            //const CircularProgressIndicator(), // Show loading while redirecting
                          ],
                        ),
                      );
                    case AuthenticationStatus.unauthenticated:
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 2,
                            ),
                            child: EmailInput(),
                          ),

                          //
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 2),
                            child: PasswordInput(),
                          ),
                          //

                          const SizedBox(height: 32.0),
                          SizedBox(
                            child: Column(
                              children: [
                                //const Spacer(),
                                LoginButton(),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  //color: Colors.green,
                                  //width: 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 1,
                                        width: 70,
                                        color: colors.textMuted,
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        l10n.or,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Container(
                                        height: 1,
                                        width: 70,
                                        color: colors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                                GoogleLoginButton(),
                                const SizedBox(
                                  height: 16.0,
                                ),
                                FacebookLoginButton(),
                                //const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      );
                  }
                },
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
