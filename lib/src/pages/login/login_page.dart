part of 'signup_and_login.dart';

class LoginPage extends StatelessWidget {
  static const routeName = "login";

  const LoginPage({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.all(8.0).copyWith(top:32.0),
          child: BlocProvider(
            create: (_) => LoginCubit(
              context.read<AuthRepository>(),
            ),
            child: const LoginForm(),
          ),
        ),
      ),
    );
  }
}
