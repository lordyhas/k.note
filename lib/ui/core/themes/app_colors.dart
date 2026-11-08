import 'package:flutter/material.dart';

/// The app's own color roles, on top of [ColorScheme].
///
/// Widgets read colors from here instead of hard-coding them, so the
/// palette is defined once and a light theme only needs another instance.
/// [dark] holds the colors the app has always used.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.navigationBar,
    required this.tile,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.danger,
    required this.link,
    required this.disabled,
  });

  /// Behind full-screen pages (tasks, editors).
  final Color background;

  /// Dialogs, pickers, bottom bars and default task cards.
  final Color surface;

  /// Menus and the task quick add bar, one step above [surface].
  final Color surfaceHigh;

  /// The bottom navigation bar.
  final Color navigationBar;

  /// List tiles of the bin and archive.
  final Color tile;

  final Color text;

  /// Hints, secondary text and inactive icons.
  final Color textMuted;

  /// Selected and active elements of the tasks feature.
  final Color accent;

  /// Destructive actions and overdue dates.
  final Color danger;

  /// Call-to-action buttons of the settings pages.
  final Color link;

  /// Background of disabled buttons.
  final Color disabled;

  static const dark = AppColors(
    background: Colors.black,
    surface: Color(0xFF1F1F1F),
    surfaceHigh: Color(0xFF2B2B2B),
    navigationBar: Color(0xFF212121),
    tile: Color(0xB3616161),
    text: Colors.white,
    textMuted: Colors.grey,
    accent: Colors.blueAccent,
    danger: Colors.redAccent,
    link: Colors.blue,
    disabled: Color(0xFF616161),
  );

  /// The colors of the current theme, or [dark] when the theme has none
  /// (e.g. in widget tests that pump a bare [MaterialApp]).
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? dark;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? navigationBar,
    Color? tile,
    Color? text,
    Color? textMuted,
    Color? accent,
    Color? danger,
    Color? link,
    Color? disabled,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      navigationBar: navigationBar ?? this.navigationBar,
      tile: tile ?? this.tile,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      link: link ?? this.link,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      navigationBar: Color.lerp(navigationBar, other.navigationBar, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      link: Color.lerp(link, other.link, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
}
