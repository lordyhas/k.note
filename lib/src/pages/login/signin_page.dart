part of 'signup_and_login.dart';

class LoginPage extends StatelessWidget {
  static const routeName = "login";
  static const routeUrl = "/login";
  const LoginPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
    /*SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      )
    );*/
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        //appBar: AppBar(title: const Text('Login')),
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
