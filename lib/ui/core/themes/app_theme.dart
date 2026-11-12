import 'package:flutter/material.dart';

import 'package:knote/ui/core/themes/app_colors.dart';

/// The app theme: Material widgets styled after Microsoft's Fluent design.
///
/// Fluent's look comes from a few rules, applied here to every component so
/// pages don't restyle them one by one: 4 dp corners on controls and 8 dp on
/// surfaces (cards, dialogs, menus, sheets), hairline strokes instead of
/// shadows, one accent color, semibold titles, and a quiet highlight in
/// place of the ink ripple.
///
/// Only dark exists for now; the colors of a light theme would go in another
/// [AppColors] instance.
abstract final class AppTheme {
  /// Corner radius of controls: buttons, text fields, list rows, chips.
  static const controlRadius = 4.0;

  /// Corner radius of surfaces: cards, dialogs, menus, sheets.
  static const surfaceRadius = 8.0;

  static final dark = _build(AppColors.dark);

  static ThemeData _build(AppColors colors) {
    // Fills of controls at rest and under the pointer, as in Fluent.
    final controlFill = colors.text.withValues(alpha: 0.06);
    final controlHover = colors.text.withValues(alpha: 0.09);

    final controlBorder = BorderRadius.circular(controlRadius);
    final controlShape = RoundedRectangleBorder(borderRadius: controlBorder);
    final strokedControlShape = RoundedRectangleBorder(
      borderRadius: controlBorder,
      side: BorderSide(color: colors.stroke),
    );
    final surfaceShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(surfaceRadius),
      side: BorderSide(color: colors.stroke),
    );

    final selected =
        Color.alphaBlend(colors.accent.withValues(alpha: 0.24), colors.surface);
    final scheme = ColorScheme.dark(
      primary: colors.accent,
      onPrimary: colors.onAccent,
      primaryContainer: selected,
      onPrimaryContainer: colors.text,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      secondaryContainer: selected,
      onSecondaryContainer: colors.text,
      tertiary: colors.link,
      onTertiary: colors.onAccent,
      error: colors.danger,
      onError: colors.onAccent,
      surface: colors.background,
      onSurface: colors.text,
      onSurfaceVariant: colors.textMuted,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surface,
      surfaceContainerHighest: colors.surfaceHigh,
      outline: colors.textMuted,
      outlineVariant: colors.stroke,
      // Material 3 tints raised surfaces with the primary color; Fluent
      // keeps them neutral.
      surfaceTint: Colors.transparent,
    );

    // The border of a text field: a hairline at rest, the accent color
    // when focused.
    final inputBorderSide = WidgetStateBorderSide.resolveWith((states) {
      final focused = states.contains(WidgetState.focused);
      final Color color;
      if (states.contains(WidgetState.error)) {
        color = colors.danger;
      } else if (focused) {
        color = colors.accent;
      } else {
        color = colors.stroke;
      }
      return BorderSide(color: color, width: focused ? 2 : 1);
    });

    const semibold = FontWeight.w600;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      primaryColor: colors.accent,
      primaryColorDark: colors.surfaceHigh,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surfaceHigh,
      cardColor: colors.surface,
      dividerColor: colors.stroke,
      disabledColor: colors.textMuted,
      // No ripple: a control answers the pointer by changing its fill.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: controlFill,
      hoverColor: controlFill,
      focusColor: controlHover,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: semibold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: semibold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: semibold),
        titleSmall: TextStyle(fontSize: 14, fontWeight: semibold),
        labelLarge: TextStyle(fontSize: 14, fontWeight: semibold),
      ),
      iconTheme: IconThemeData(color: colors.text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.text,
        elevation: 0.0,
        // Material 3 tints the app bar with the primary color when content
        // scrolls under it; the design keeps it transparent.
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: surfaceShape,
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: surfaceShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(surfaceRadius)),
        ),
        // On a wide window a sheet is a centered panel, not a full-width bar.
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: surfaceShape,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceHigh,
        contentTextStyle: TextStyle(color: colors.text),
        actionTextColor: colors.accent,
        shape: strokedControlShape,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          borderRadius: controlBorder,
          border: Border.all(color: colors.stroke),
        ),
        textStyle: TextStyle(color: colors.text, fontSize: 12),
        waitDuration: const Duration(milliseconds: 500),
      ),
      dividerTheme: DividerThemeData(color: colors.stroke, thickness: 1),
      listTileTheme: ListTileThemeData(shape: controlShape),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accent),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(surfaceRadius)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: controlShape,
          minimumSize: const Size(64, 40),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.surfaceHigh,
          foregroundColor: colors.text,
          elevation: 0,
          shape: strokedControlShape,
          minimumSize: const Size(64, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: controlFill,
          foregroundColor: colors.text,
          side: BorderSide(color: colors.stroke),
          shape: controlShape,
          minimumSize: const Size(64, 40),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: controlShape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(controlShape)),
      ),
      chipTheme: ChipThemeData(
        shape: controlShape,
        side: BorderSide(color: colors.stroke),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: controlFill,
        hoverColor: controlHover,
        hintStyle: TextStyle(color: colors.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        // Only the shape is set here, and its color per state below: a
        // field that opts out with `border: InputBorder.none` (the search
        // bar, the editors) then really has no border.
        border: OutlineInputBorder(borderRadius: controlBorder),
        outlineBorder: inputBorderSide,
        activeIndicatorBorder: inputBorderSide,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.navigationBar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: controlHover,
        indicatorShape: controlShape,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.accent
                  : colors.text,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? semibold : FontWeight.w400,
            color: isSelected ? colors.text : colors.textMuted,
          );
        }),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: surfaceShape,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surface,
        shape: surfaceShape,
      ),
      extensions: [colors],
    );
  }
}
