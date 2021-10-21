library data.app_bloc;

import 'package:flutter_bloc/flutter_bloc.dart';

export 'app_bloc/authentication/authentication_bloc.dart';
export 'app_bloc/login_bloc/login_cubit.dart';
export 'app_bloc/signup_bloc/sign_up_cubit.dart';

export 'theme_and_language_cubit.dart';

/// Custom [BlocObserver] which observes all bloc and cubit instances.
///


class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    print(bloc.toString() + " => onEvent() : $event");
    super.onEvent(bloc, event);
  }

  /*@override
  void onChange(Cubit cubit, Change change) {
    print(cubit.toString() + " => onChange() : $change");
    super.onChange(cubit, change);
  }*/

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(bloc.toString() + " => onTransition()  : $transition");
    super.onTransition(bloc, transition);
  }

/* @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print("onError()  : $error");
    //print(error);
    super.onError(bloc, error, stackTrace);
  }*/

}

