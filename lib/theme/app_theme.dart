import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Timing and easing shared by every transition in the app.
///
/// Pulled out so screens cannot each invent their own curve. Easings are
/// the strong variants from easing curves rather than the built-in ones,
/// which are too flat to feel deliberate at these durations.
abstract final class AppMotion {
  /// Fast response for presses and toggles.
  static const Duration press = Duration(milliseconds: 160);

  /// Default for state changes inside a screen.
  static const Duration ui = Duration(milliseconds: 200);

  /// Route transitions and sheet entrances.
  static const Duration route = Duration(milliseconds: 250);

  /// Starts fast, settles gently. Entering elements.
  static const Cubic easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Symmetric acceleration. Moving elements.
  static const Cubic easeInOut = Cubic(0.77, 0, 0.175, 1);
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme colorScheme(Brightness brightness) {
    return brightness == Brightness.light ? _lightScheme : _darkScheme;
  }

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = colorScheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: AppTypography.textTheme(scheme),
      scaffoldBackgroundColor: isLight
          ? AppColors.mintCream
          : AppColors.prussianBlue,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.mintCream : AppColors.prussianBlue,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(scheme).headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          elevation: 0,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(scheme).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          // outline, not outlineVariant: a button edge has to be findable at
          // a glance, while card borders stay faint because the fill already
          // separates them.
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(
            scheme,
          ).labelLarge?.copyWith(color: scheme.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(
            scheme,
          ).labelLarge?.copyWith(color: scheme.onSurface),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: isLight
            ? AppColors.lightSurfaceHighest
            : AppColors.darkSurfaceHighest,
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.textTheme(scheme).labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
        labelStyle: AppTypography.textTheme(scheme).labelSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + 4,
          vertical: AppSpacing.xs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTypography.textTheme(
          scheme,
        ).bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Deep Blue Sea, light: Mint Cream canvas, Regal Navy actions, Prussian
  /// Blue text. Surface containers tint the canvas up toward white so cards
  /// lift off the page without needing a shadow to say so.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.regalNavy,
    onPrimary: AppColors.mintCream,
    primaryContainer: AppColors.oxfordNavy,
    onPrimaryContainer: AppColors.mintCream,
    secondary: AppColors.powderBlue,
    onSecondary: AppColors.prussianBlue,
    secondaryContainer: AppColors.lightSurfaceHigh,
    onSecondaryContainer: AppColors.prussianBlue,
    // Tertiary wants a contrasting hue, but the palette is one hue deep, so
    // it leans on the darker navy instead of inventing an out-of-family
    // accent that the brand book would not recognise.
    tertiary: AppColors.oxfordNavy,
    onTertiary: AppColors.mintCream,
    tertiaryContainer: AppColors.lightSurfaceHighest,
    onTertiaryContainer: AppColors.prussianBlue,
    error: AppColors.error,
    onError: AppColors.mintCream,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.mintCream,
    onSurface: AppColors.prussianBlue,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.prussianBlue,
    onInverseSurface: AppColors.mintCream,
    inversePrimary: AppColors.powderBlue,
    surfaceContainerLowest: AppColors.lightSurfaceLowest,
    surfaceContainerLow: AppColors.lightSurfaceLow,
    surfaceContainer: AppColors.lightSurface,
    surfaceContainerHigh: AppColors.lightSurfaceHigh,
    surfaceContainerHighest: AppColors.lightSurfaceHighest,
  );

  /// Deep Blue Sea, dark: Prussian Blue page, Mint Cream text, Powder Blue
  /// for anything secondary. The ramp tints upward from the page and lands
  /// on Regal Navy, so raised surfaces still read as the brand rather than
  /// as lifted grey. `primary` inverts the way Material expects, keeping
  /// filled controls high-contrast in both modes.
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.mintCream,
    onPrimary: AppColors.prussianBlue,
    primaryContainer: AppColors.darkContainer,
    onPrimaryContainer: AppColors.mintCream,
    secondary: AppColors.powderBlue,
    onSecondary: AppColors.prussianBlue,
    secondaryContainer: AppColors.darkSurfaceHigh,
    onSecondaryContainer: AppColors.mintCream,
    tertiary: AppColors.powderBlue,
    onTertiary: AppColors.prussianBlue,
    tertiaryContainer: AppColors.darkSurfaceHighest,
    onTertiaryContainer: AppColors.mintCream,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: AppColors.onErrorContainer,
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.prussianBlue,
    onSurface: AppColors.mintCream,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.darkInverseSurface,
    onInverseSurface: AppColors.darkInverseOnSurface,
    inversePrimary: AppColors.regalNavy,
    surfaceContainerLowest: AppColors.darkSurfaceLowest,
    surfaceContainerLow: AppColors.darkSurfaceLow,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurfaceHigh,
    surfaceContainerHighest: AppColors.darkSurfaceHighest,
  );
}
