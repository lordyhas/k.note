import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/splash_page.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'data/app_bloc.dart';
import 'data/authentication_repository.dart';
import 'data/database/firebase_manager.dart';
import 'data/theme_and_language_cubit.dart';
import 'data/values.dart';
import 'navigation_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FacebookSdk.sdkInitialize();
  await Firebase.initializeApp();

  EquatableConfig.stringify = kReleaseMode;
  Bloc.observer = AppBlocObserver();
  FirebaseManager.init();
  runApp(App(authenticationRepository: AuthenticationRepository()));
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authenticationRepository,
  })  : super(key: key);

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {

    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        child: AppView(),
      ),
    );
  }
}


class AppView extends StatelessWidget {

  final _navigatorKey = GlobalKey<NavigatorState>();

  AppView({Key? key}) : super(key: key);

  NavigatorState get _navigator => _navigatorKey.currentState!;

  //ObjectBoxManager objectboxManager = new ObjectBoxManager.initStore();

  final FirebaseManager firebaseManager = FirebaseManager();

  //late int themeValue;


  final String defaultSystemLocale = Platform.localeName;
  //final List<Locale> systemLocales = WidgetsBinding.instance!.window.locales;
  @override
  Widget build(BuildContext context) {
    if(!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.cyan.shade700,
        systemNavigationBarIconBrightness: Brightness.dark,

      ));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (BuildContext context) => LanguageBloc(
              LangState.values[1], defaultSystemLocale),
        ),
        BlocProvider<StyleCubit>(create: (BuildContext context) => StyleCubit(),)
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'K.NOTE',
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('fr'),
        ],
        /*
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],*/
        theme: ThemeData.dark().copyWith(
          //backgroundColor: Colors.grey[200],
          primaryColor: Colors.cyan.shade700,
          primaryColorDark: Colors.grey[600],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.cyan.shade700,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan),
          /*bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
          ),*/
          //brightness: Brightness.dark
        ),

        home: (BlocProvider.of<AuthenticationBloc>(context)
            .state.status == AuthenticationStatus.authenticated)
            ?  const NavigationHomeScreen() : null,
        //home: const LoginPage(),

        onGenerateRoute: (_) => SplashPage.route(),
        builder: (context, child) {
          return BlocListener<AuthenticationBloc, AuthenticationState>(
            child: child,
            listener: (context, state) {
              switch (state.status) {
                case AuthenticationStatus.authenticated:
                  _navigator.pushAndRemoveUntil(
                    NavigationHomeScreen.route(), (route) => false,
                  );
                  //_navigator.pushReplacement(NavigationHomeScreen.route());
                  break;
                case AuthenticationStatus.unauthenticated:
                  _navigator.pushAndRemoveUntil(
                    LoginPage.route(), (route) => false,
                  );
                  break;
                default:
                  _navigator.pushAndRemoveUntil(
                    NavigationHomeScreen.route(), (route) => false,
                  );
                  //print('AuthenticationState : AuthenticationStatus.unknown ### ###');
                  break;
              }
            },
          );
        },

      ),
    );
  }
}




