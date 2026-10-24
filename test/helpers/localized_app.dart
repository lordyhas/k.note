import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:knote/ui/core/localization/l10n.dart';

const _delegates = [
  ...AppLocalizations.localizationsDelegates,
  FlutterQuillLocalizations.delegate,
];

/// A [MaterialApp] with the app's translations, in English unless [locale]
/// says otherwise.
MaterialApp localizedApp({
  Widget? home,
  Locale locale = const Locale('en'),
  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: _delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    scaffoldMessengerKey: scaffoldMessengerKey,
    home: home,
  );
}

/// [localizedApp] for a router.
MaterialApp localizedRouterApp({
  required RouterConfig<Object> routerConfig,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: _delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: routerConfig,
  );
}
