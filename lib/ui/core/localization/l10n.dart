import 'package:flutter/widgets.dart';

import 'package:knote/ui/core/localization/app_localizations.dart';

export 'package:knote/ui/core/localization/app_localizations.dart';

/// Shortcut for the app's translated strings: `context.l10n.save`.
///
/// Strings live in `app_en.arb` (the template) and `app_fr.arb`; the Dart
/// classes are generated from them by `flutter gen-l10n` (also run by
/// `flutter pub get`, `run` and `build`).
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
