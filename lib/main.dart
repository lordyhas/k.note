import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/routes.dart';


import 'data/app_bloc.dart';
import 'data/authentication_repository.dart';
import 'data/database/firebase_manager.dart';
import 'data/values.dart';


import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = AppBlocObserver();
  FirebaseManager.init();
  runApp(App(authenticationRepository: AuthRepository()));

}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authenticationRepository,
  }) : super(key: key);

  final AuthRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {

    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authRepository: authenticationRepository,
        ),
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {

  final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: "RouterKey");
  //final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppView({Key? key}) : super(key: key);

  //NavigatorState get _navigator => _navigatorKey.currentState!;

  final String defaultSystemLocale = Platform.localeName;
  //final List<Locale> systemLocales = WidgetsBinding.instance!.window.locales;
  @override
  Widget build(BuildContext context) {
    if(!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey.shade900,
        //systemNavigationBarDividerColor: Colors.cyan.shade700,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(create: (context) => LanguageBloc()),
        BlocProvider<StyleCubit>(create: (context) => StyleCubit())
      ],
      child: MaterialApp.router(
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
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.cyan,
          ),
        ),

        routerConfig: AppRouter.routes(key: _navigatorKey),
        //home : const NavigationHomeScreen(child: SizedBox(),),


      ),
    );
  }
}

