import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/sign_up_cubit.dart';
import 'package:knote/ui/auth/widgets/sign_up_form.dart';



class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Sign Up')),
      //resizeToAvoidBottomPadding: false ,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<SignUpCubit>(
          create: (_) => SignUpCubit(
            context.read<AuthRepository>(),
          ),
          child: SignUpForm(),
        ),
      ),
    );
  }
}
