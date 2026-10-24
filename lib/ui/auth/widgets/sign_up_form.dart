import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/ui/auth/bloc/sign_up_cubit.dart';
import 'package:knote/ui/auth/widgets/login_buttons.dart';




class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sign Up Failure'),
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
              padding: const EdgeInsets.all(8.0).copyWith(),
              child: Image.asset(
                imageLogoApp,
                height: 120,
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Welcome to K22D",
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor),
                    ),
                    const Text("create an account to continue"),

                  ],
                )
            ),
            const Padding(
                padding:  EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0),
                child:  Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                     Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                         Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25.0, top: 2.0),
              child: EmailSignInInput(),
            ),
            //EmailSignInInput(),
            const SizedBox(height: 8.0),
            const Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0),
                child:  Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                     Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                         Text(
                          'Password',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )
            ),

            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25.0, top: 2.0),
              child: PasswordSignInInput(),
            ),
            //PasswordSignInInput(),
            const SizedBox(height: 8.0),
            SignUpSignInButton(),
          ],
        ),
      ),
    );
  }
}
