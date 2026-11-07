import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/data/services/reminder_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/firebase_options.dart';
import 'package:knote/routing/router.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/app_bloc_observer.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/core/themes/style_cubit.dart';
import 'package:knote/utils/save_in_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authenticationRepository = AuthRepository();
  await authenticationRepository.user.first;

  Bloc.observer = AppBlocObserver();
  final reminderService = ReminderService();
  // The notification channel is named in the device language, like the app.
  final l10n = lookupAppLocalizations(basicLocaleListResolution(
      PlatformDispatcher.instance.locales, AppLocalizations.supportedLocales));
  await reminderService.initialize(
    channelName: l10n.reminderChannelName,
    channelDescription: l10n.reminderChannelDescription,
  );
  runApp(App(
    authenticationRepository: authenticationRepository,
    reminderService: reminderService,
  ));
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authenticationRepository,
    required this.reminderService,
  });

  final AuthRepository authenticationRepository;
  final ReminderService reminderService;

  /// The signed-in user, now and whenever it changes (including once the
  /// email is verified, which the auth stream does not report).
  static Stream<User> _users(AuthenticationBloc bloc) async* {
    yield bloc.state.user;
    yield* bloc.stream.map((state) => state.user);
  }

  @override
  Widget build(BuildContext context) {
    /// Set BlocProvider <AuthenticationBloc> here
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) {
          final bloc = AuthenticationBloc(
            authRepository: authenticationRepository,
          );
          // Keeps the task reminders scheduled for as long as the app runs.
          reminderService.follow(
            _users(bloc),
            (user) => FirestoreService.user(user).watchTasks(),
          );
          return bloc;
        },
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  /// Global Key for GoRouter parent routes
  final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: "__RouterKey__");
  //final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      /// For Mobile phone set UI System Style
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.dark.navigationBar,
        //systemNavigationBarDividerColor: Colors.cyan.shade700,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
    //var user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    return MultiBlocProvider(
      providers: [BlocProvider<StyleCubit>(create: (context) => StyleCubit())],
      child: MaterialApp.router(
        scaffoldMessengerKey: appMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'KNOTE',
        // The app follows the device language (English or French), and
        // falls back to English.
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,

        /// [AppRouter] is call here
        routerConfig: AppRouter.routes(
          key: _navigatorKey,
          authBloc: BlocProvider.of<AuthenticationBloc>(context),
        ),
      ),
    );
  }
}
