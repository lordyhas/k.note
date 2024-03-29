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
  final authenticationRepository = AuthRepository();
  await authenticationRepository.user.first;

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

    /// Set BlocProvider <AuthenticationBloc> here
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

  /// Global Key for GoRouter parent routes
  final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: "__RouterKey__");
  //final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppView({Key? key}) : super(key: key);

  final String defaultSystemLocale = Platform.localeName;

  @override
  Widget build(BuildContext context) {
    if(!kIsWeb) {
      /// For Mobile phone set UI System Style
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light ,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey.shade900,
        //systemNavigationBarDividerColor: Colors.cyan.shade700,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
    var user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    print('AppView.build');
    print('################# User($user)');
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

        /*localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],*/
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.cyan.shade700,
          primaryColorDark: Colors.grey[600],
          //cardColor: Colors.grey.shade700,
          cardTheme: CardTheme(color: Colors.grey.shade800),
          scaffoldBackgroundColor: Colors.transparent,

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),

          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.cyan,

          ),
        ),
        /// [AppRouter] is call here
        routerConfig: AppRouter.routes(key: _navigatorKey),
      ),
    );
  }
}

