 import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/firebase_options.dart';
import 'package:knote/routing/router.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/app_bloc_observer.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/preferences_scope.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/core/themes/style_cubit.dart';
import 'package:knote/ui/settings/bloc/preferences_cubit.dart';
import 'package:knote/utils/save_in_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _activateAppCheck();
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

/// reCAPTCHA Enterprise site key for App Check on the web, passed at build
/// time: `flutter build web --dart-define=RECAPTCHA_SITE_KEY=...`.
const _recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

/// App Check proves to Firebase that requests come from this app (Play
/// Integrity on Android, reCAPTCHA Enterprise on the web). Debug builds use
/// the debug provider: register the token it logs in the Firebase console.
/// Requests are only rejected once enforcement is turned on in the console
/// (see docs/security.md).
Future<void> _activateAppCheck() async {
  if (kIsWeb && _recaptchaSiteKey.isEmpty) {
    debugPrint('App Check is off on the web: RECAPTCHA_SITE_KEY is not set.');
    return;
  }
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? const AppleDeviceCheckProvider()
          : const AppleDebugProvider(),
      providerWeb:
          kIsWeb ? ReCaptchaEnterpriseProvider(_recaptchaSiteKey) : null,
    );
  } catch (e) {
    debugPrint('App Check could not be activated: $e');
  }
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
        child: BlocProvider(
          create: (context) {
            final cubit = PreferencesCubit(
              users: _users(context.read<AuthenticationBloc>()),
              firestore: FirestoreService.user,
            );
            // The "Task reminders" preference turns notifications on or off.
            cubit.stream
                .map((preferences) => preferences.remindersEnabled)
                .distinct()
                .listen(reminderService.setEnabled);
            return cubit;
          },
          child: const AppView(),
        ),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  /// Global Key for GoRouter parent routes
  final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: "__RouterKey__");

  /// Built once: the app rebuilds when the preferences change (language),
  /// and a new router would lose the navigation stack.
  late final _router = AppRouter.routes(
    key: _navigatorKey,
    authBloc: context.read<AuthenticationBloc>(),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      /// For Mobile phone set UI System Style
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.dark.navigationBar,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
    return MultiBlocProvider(
      providers: [BlocProvider<StyleCubit>(create: (context) => StyleCubit())],
      child: BlocBuilder<PreferencesCubit, UserPreferences>(
        builder: (context, preferences) {
          final languageCode = preferences.languageCode;
          return PreferencesScope(
            preferences: preferences,
            onChanged: context.read<PreferencesCubit>().update,
            child: MaterialApp.router(
              scaffoldMessengerKey: appMessengerKey,
              debugShowCheckedModeBanner: false,
              title: 'KNOTE',
              // The device language (English or French, English otherwise),
              // unless the user chose one in the preferences.
              locale: languageCode == null ? null : Locale(languageCode),
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.dark,
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}
