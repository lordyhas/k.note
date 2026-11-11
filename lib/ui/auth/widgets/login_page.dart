import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/widgets/login_form.dart';
import 'package:knote/ui/core/widgets/responsive.dart';

class LoginPage extends StatelessWidget {
  static const routeName = "login";

  const LoginPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(top: 32.0),
          child: BlocProvider(
            create: (_) => LoginCubit(
              context.read<AuthRepository>(),
            ),
            // The form fills the window and spreads out when there is room,
            // and scrolls when there is not (a phone in landscape).
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const IntrinsicHeight(
                    child: CenteredContent(
                      maxWidth: ContentWidths.form,
                      child: LoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
