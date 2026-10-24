import 'package:flutter/material.dart';

import 'package:knote/ui/core/themes/app_colors.dart';

/// The app theme. Only dark exists for now; the colors of a light theme
/// would go in another [AppColors] instance.
abstract final class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.cyan.shade700,
    primaryColorDark: Colors.grey[600],
    cardTheme: CardThemeData(color: Colors.grey.shade800),
    scaffoldBackgroundColor: AppColors.dark.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      // Material 3 tints the app bar with the primary color when content
      // scrolls under it; the design keeps it transparent.
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: AppColors.dark.text),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
      accentColor: Colors.cyan,
    ),
    extensions: const [AppColors.dark],
  );
}
