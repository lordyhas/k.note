import 'package:flutter/widgets.dart';

/// Tells the pages inside the shell whether the web side drawer is shown,
/// so they can leave out the entries it already has.
///
/// Kept apart from `app_shell.dart`, which imports the pages: a page
/// importing the shell back makes an import cycle that crashes the
/// incremental web compiler (`flutter run -d chrome`).
class SideNavigationScope extends InheritedWidget {
  const SideNavigationScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  /// Whether the shell around [context] shows the side drawer; false
  /// outside a shell.
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SideNavigationScope>()
          ?.enabled ??
      false;

  @override
  bool updateShouldNotify(SideNavigationScope oldWidget) =>
      enabled != oldWidget.enabled;
}
