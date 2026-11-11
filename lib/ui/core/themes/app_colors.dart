import 'package:flutter/material.dart';

/// The app's own color roles, on top of [ColorScheme].
///
/// Widgets read colors from here instead of hard-coding them, so the
/// palette is defined once and a light theme only needs another instance.
/// [dark] follows the dark palette of Microsoft's Fluent design: a
/// neutral #202020 base, slightly lighter layers above it, hairline strokes
/// instead of shadows, and one light blue accent.
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
    required this.onAccent,
    required this.stroke,
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

  /// Selected and active elements, and the primary buttons.
  final Color accent;

  /// Text and icons drawn on [accent].
  final Color onAccent;

  /// Hairline border of cards, dialogs, menus and controls.
  final Color stroke;

  /// Destructive actions and overdue dates.
  final Color danger;

  /// Call-to-action buttons of the settings pages.
  final Color link;

  /// Background of disabled buttons.
  final Color disabled;

  static const dark = AppColors(
    background: Color(0xFF202020),
    surface: Color(0xFF2C2C2C),
    surfaceHigh: Color(0xFF353535),
    navigationBar: Color(0xFF1C1C1C),
    tile: Color(0xB32C2C2C),
    text: Colors.white,
    textMuted: Color(0xFF9A9A9A),
    accent: Color(0xFF60CDFF),
    onAccent: Colors.black,
    stroke: Color(0x1FFFFFFF),
    danger: Color(0xFFFF99A4),
    link: Color(0xFF99EBFF),
    disabled: Color(0xFF434343),
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
    Color? onAccent,
    Color? stroke,
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
      onAccent: onAccent ?? this.onAccent,
      stroke: stroke ?? this.stroke,
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
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      link: Color.lerp(link, other.link, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
}
